//
//  ssh_main.c
//  ios_system
//
//  Created by Nicolas Holzschuch on 23/01/2018.
//  Copyright © 2018 Nicolas Holzschuch. All rights reserved.
//
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include "libssh2.h"
#include <sys/fcntl.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/syslimits.h>
#include <dirent.h>
#include <getopt.h>
#include <netdb.h>
#include <sys/poll.h>
#include <sys/select.h>
#include <sys/time.h>
#include "ios_error.h"

static int ssh_waitsocket(int socket_fd, LIBSSH2_SESSION *session) {
    struct timeval timeout;
    int rc;
    fd_set fd;
    fd_set *writefd = NULL;
    fd_set *readfd = NULL;
    int dir;
    
    timeout.tv_sec = 10;
    timeout.tv_usec = 0;
    
    FD_ZERO(&fd);
    
    FD_SET(socket_fd, &fd);
    
    /* now make sure we wait in the correct direction */
    dir = libssh2_session_block_directions(session);
    
    if (dir & LIBSSH2_SESSION_BLOCK_INBOUND)
        readfd = &fd;
    
    if (dir & LIBSSH2_SESSION_BLOCK_OUTBOUND)
        writefd = &fd;
    
    rc = select(socket_fd + 1, readfd, writefd, NULL, &timeout);
    return rc;
}

static int ssh_verify_host(char* addr, LIBSSH2_SESSION* _session, char* hostname, int port) {
    LIBSSH2_KNOWNHOSTS *kh;
    const char *key;
    size_t key_len;
    int key_type;
    char *type_str;
    
    if (!(kh = libssh2_knownhost_init(_session))) {
        return -1;
    }
    
    // Path = getenv(SSH_HOME) or ~/Documents
    char path[PATH_MAX];
    if (getenv("SSH_HOME")) strcpy(path, getenv("SSH_HOME"));
    else sprintf(path, "%s/Documents/", getenv("HOME"));
    char khFilePath[PATH_MAX];
    // known_hosts is shared with Blink
    sprintf(khFilePath, "%s/known_hosts", path);
    libssh2_knownhost_readfile(kh, khFilePath, LIBSSH2_KNOWNHOST_FILE_OPENSSH);
    
    key = libssh2_session_hostkey(_session, &key_len, &key_type);
    int kh_key_type = (key_type == LIBSSH2_HOSTKEY_TYPE_RSA) ? LIBSSH2_KNOWNHOST_KEY_SSHRSA : LIBSSH2_KNOWNHOST_KEY_SSHDSS;
    type_str = strdup((key_type == LIBSSH2_HOSTKEY_TYPE_RSA) ? "RSA" : "DSS");
    
    int succ = 0;
    if (key) {
        struct libssh2_knownhost *knownHost;
        int check = libssh2_knownhost_checkp(kh, hostname, port, key, key_len,
                                             LIBSSH2_KNOWNHOST_TYPE_PLAIN | LIBSSH2_KNOWNHOST_KEYENC_RAW | kh_key_type,
                                             &knownHost);
        if (check == LIBSSH2_KNOWNHOST_CHECK_FAILURE) {
            fprintf(thread_stderr, "Known host check failed\n");
        } else if (check == LIBSSH2_KNOWNHOST_CHECK_NOTFOUND) {
            fprintf(thread_stderr, "The authenticity of host %.200s (%s) can't be established.\n", hostname, addr);
        } else if (check == LIBSSH2_KNOWNHOST_CHECK_MISMATCH) {
            fprintf(thread_stderr, "@@@@@@ REMOTE HOST IDENTIFICATION HAS CHANGED @@@@@@\n%s host key for %.200s (%s) has changed.\nThis might be due to someone doing something nasty or just a change in the host.\n", type_str, hostname, addr);
        } else if (check == LIBSSH2_KNOWNHOST_CHECK_MATCH) {
            succ = 1;
        }
        free(type_str);
    }
    // Automatically add host to list of authorized hosts
    if (!succ) {
        // [self authorize_new_key:key length:key_len type:kh_key_type knownHosts:kh filePath:khFilePath];
        // Add key to the server
        int rc = libssh2_knownhost_addc(kh, hostname,
                                        NULL, // No hashed addr, no salt
                                        key, key_len,
                                        NULL, 0,                                                                // No comment
                                        LIBSSH2_KNOWNHOST_TYPE_PLAIN | LIBSSH2_KNOWNHOST_KEYENC_RAW | LIBSSH2_KNOWNHOST_KEY_SSHRSA, // kh_key_type,
                                        NULL);                                                                  // No pointer to the stored structure
        if (rc < 0) {
            char *errmsg;
            libssh2_session_last_error(_session, &errmsg, NULL, 0);
            fprintf(thread_stderr, "Error adding to the list of known hosts: %s\n", errmsg);
        }
        
        rc = libssh2_knownhost_writefile(kh, khFilePath, LIBSSH2_KNOWNHOST_FILE_OPENSSH);
        if (rc < 0) {
            char *errmsg;
            libssh2_session_last_error(_session, &errmsg, NULL, 0);
            fprintf(thread_stderr, "Error writing known host: %s\n", errmsg);
        } else {
            fprintf(thread_stderr, "Permanently added key for %s to list of known hosts.\n", hostname);
        }
    }
    libssh2_knownhost_free(kh);
    return succ;
}

static int ssh_set_nonblock(int fd) {
    int arg;
    if ((arg = fcntl(fd, F_GETFL, NULL)) < 0) {
        fprintf(thread_stderr, "Error fcntl(..., F_GETFL) (%s)\n", strerror(errno));
        return -1;
    }
    arg |= O_NONBLOCK;
    if (fcntl(fd, F_SETFL, arg) < 0) {
        fprintf(thread_stderr, "Error fcntl(..., F_GETFL) (%s)\n", strerror(errno));
        return -1;
    }
    return 0;
}

static int ssh_unset_nonblock(int fd) {
    int arg;
    
    if ((arg = fcntl(fd, F_GETFL, NULL)) < 0) {
        fprintf(thread_stderr, "Error fcntl(..., F_GETFL) (%s)\n", strerror(errno));
        return -1;
    }
    arg &= (~O_NONBLOCK);
    if (fcntl(fd, F_SETFL, arg) < 0) {
        fprintf(thread_stderr, "Error fcntl(..., F_GETFL) (%s)\n", strerror(errno));
        return -1;
    }
    return 0;
}

static int ssh_client_loop(LIBSSH2_SESSION *_session, LIBSSH2_CHANNEL *_channel, int _sock) {
    int numfds = 2;
    struct pollfd pfds[numfds];
    ssize_t rc;
    char inputbuf[BUFSIZ];
    char streambuf[BUFSIZ];
    
    ssh_set_nonblock(_sock);
    ssh_set_nonblock(fileno(thread_stdin));
    
    libssh2_channel_set_blocking(_channel, 0);
    
    memset(pfds, 0, sizeof(struct pollfd) * numfds);
    
    pfds[0].fd = _sock;
    pfds[0].events = 0;
    pfds[0].revents = 0;
    
    pfds[1].fd = fileno(thread_stdin);
    pfds[1].events = POLLIN;
    pfds[1].revents = 0;
    
    // Wait for stream->in or socket while not ready for reading
    do {
        if (!pfds[0].events || pfds[0].revents & (POLLIN)) {
            // Read from socket
            do {
                rc = libssh2_channel_read(_channel, inputbuf, BUFSIZ);
                if (rc > 0) {
                    fwrite(inputbuf, rc, 1, thread_stdout);
                    fflush(thread_stdout);
                    pfds[0].events = 0;
                } else if (rc == LIBSSH2_ERROR_EAGAIN) {
                    // Request the socket for input
                    pfds[0].events = POLLIN;
                }
                memset(inputbuf, 0, BUFSIZ);
            } while (LIBSSH2_ERROR_EAGAIN != rc && rc > 0);
            
            do {
                rc = libssh2_channel_read_stderr(_channel, inputbuf, BUFSIZ);
                if (rc > 0) {
                    fwrite(inputbuf, rc, 1, thread_stderr);
                    pfds[0].events |= 0;
                } else if (rc == LIBSSH2_ERROR_EAGAIN) {
                    pfds[0].events = POLLIN;
                }
                
                memset(inputbuf, 0, BUFSIZ);
                
            } while (LIBSSH2_ERROR_EAGAIN != rc && rc > 0);
        }
        if (rc < 0 && LIBSSH2_ERROR_EAGAIN != rc) {
            fprintf(thread_stderr, "error reading from socket. exiting...\n");
            break;
        }
        
        if (libssh2_channel_eof(_channel)) {
            break;
        }
        
        rc = poll(pfds, numfds, 15000);
        if (-1 == rc) {
            break;
        }
        
        ssize_t towrite = 0;
        
        if (!thread_stdin || feof(thread_stdin)) {
            // Propagate the EOF to the other end
            libssh2_channel_send_eof(_channel);
            break;
        }
        // Input from stream
        if (pfds[1].revents & POLLIN) {
            towrite = fread(streambuf, 1, BUFSIZ, thread_stdin);
            rc = 0;
            do {
                rc = libssh2_channel_write(_channel, streambuf + rc, towrite);
                if (rc > 0) {
                    towrite -= rc;
                }
            } while (LIBSSH2_ERROR_EAGAIN != rc && rc > 0 && towrite > 0);
            memset(streambuf, 0, BUFSIZ);
        }
        if (rc < 0 && LIBSSH2_ERROR_EAGAIN != rc) {
            char *errmsg;
            libssh2_session_last_error(_session, &errmsg, NULL, 0);
            fprintf(thread_stderr, "%s\n", errmsg);
            fprintf(thread_stderr, "error writing to socket. exiting...\n");
            break;
        }
    } while (1);
    
    // We got out of the main loop.
    // Free resources and try to cleanup
    ssh_unset_nonblock(_sock);
    if (thread_stdin) {
        ssh_unset_nonblock(fileno(thread_stdin));
    }
    
    while ((rc = libssh2_channel_close(_channel)) == LIBSSH2_ERROR_EAGAIN)
        ssh_waitsocket(_sock, _session);

    // close files if it's not a pipe. Could move to ios_system.
    if (fileno(thread_stdin) != fileno(stdin)) { fclose(thread_stdin);}
    if (fileno(thread_stdout) != fileno(stdout)) { fclose(thread_stdout);}
    if (fileno(thread_stderr) != fileno(stderr)) { fclose(thread_stderr);}

    if (rc < 0) {
        return -1;
    }
    return 0;
}

static int ssh_timeout_connect(int _sock, const struct sockaddr *addr, socklen_t len, int * timeoutp) {
    struct timeval tv;
    fd_set fdset;
    int res;
    int valopt = 0;
    socklen_t lon;
    
    if (ssh_set_nonblock(_sock) != 0) {
        return -1;
    }
    
    // Trying to initiate connection as nonblock
    res = connect(_sock, addr, len);
    if (res == 0) {
        return ssh_unset_nonblock(_sock);
    }
    if (errno != EINPROGRESS) {
        return -1;
    }
    
    do {
        // Set timeout params
        tv.tv_sec = *timeoutp;
        tv.tv_usec = 0;
        FD_ZERO(&fdset);
        FD_SET(_sock, &fdset);
        // Try to select it to write
        res = select(_sock + 1, NULL, &fdset, NULL, &tv);
        
        if (res != -1 || errno != EINTR) {
            //fprintf(thread_stderr, "Error connecting %d - %s\n", errno, strerror(errno));
            break;
        }
    } while (1);
    
    switch (res) {
        case 0:
            // Timed out message
            errno = ETIMEDOUT;
            return -1;
        case -1:
            // Select failed
            return -1;
        case 1:
            // Completed or failed. Socket selected for write
            valopt = 0;
            lon = sizeof(valopt);
            
            lon = sizeof(int);
            if (getsockopt(_sock, SOL_SOCKET, SO_ERROR, &valopt, &lon) == -1) {
                return -1;
            }
            if (valopt != 0) {
                errno = valopt;
                return -1;
            }
            return ssh_unset_nonblock(_sock);
            
        default:
            return -1;
    }
}

static void ssh_usage() {
    fprintf(thread_stderr, "usage: ssh [-q] user@host command\n");
    pthread_exit(NULL);
}

int ssh_main(int argc, char** argv) {
    // TODO: extract options
    char* passphrase;
    int port = 22;
    int connection_timeout = 10;
    char strport[NI_MAXSERV];
    snprintf(strport, sizeof strport, "%d", port);
    char* user;
    char* host;
    char* commandLine;
    int verboseFlag = 0;
    if (argc < 3) ssh_usage();
    // Assume several arguments, making sense
    if (strcmp(argv[1], "-q") == 0) {
        verboseFlag = 0; // quiet
        argv++;
    }
    // argv[0] = ssh
    // argv[1] = user@host
    user = argv[1];
    host = strchr(user, '@') + 1;
    if ((host == NULL) || (argv[2] == NULL)) {
        ssh_usage();
    }
    *(host - 1) = 0x00; // null-terminate host
    // Concatenate all remaining options to form the command string:
    int bufferLength = 0;
    int removeQuotes = 0;
    for (int i = 2; i < argc; i++) bufferLength += strlen(argv[i]) + 1;
    if ((argv[2][0] == '\'') || (argv[2][0] == '\"')) { removeQuotes = 1; bufferLength -= 2;} // remove the quotes
    commandLine = (char*) malloc(bufferLength * sizeof(char));
    int position = 0;
    strcpy(commandLine + position, argv[2] + removeQuotes);
    position += strlen(argv[2]) + 1 - removeQuotes;
    commandLine[position - 1] = ' ';
    for (int i = 3; i < argc; i++) {
        strcpy(commandLine + position, argv[i]);
        position += strlen(argv[i]) + 1;
        commandLine[position - 1] = ' ';
    }
    commandLine[bufferLength - 1] = 0x0; // null-terminate the command
    // Does the hostname exist?
    struct addrinfo hints, *addrs;
    struct sockaddr_storage hostaddr;
    // TODO: Use Python error reporting system.
    // ssh_connect
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = PF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    int res;
    if ((res = getaddrinfo(host, strport, &hints, &addrs)) != 0) {
        fprintf(thread_stderr, "Host %s not found on port %s, error= %s.\n", host, strport, gai_strerror(res));
        if (argc > 1) free(commandLine);
        return 0;
    }
    struct addrinfo *ai;
    char ntop[NI_MAXHOST];
    int _sock = -1;
    for (ai = addrs; ai; ai = ai->ai_next) {
        if (ai->ai_family != AF_INET && ai->ai_family != AF_INET6) {continue;}
        if (getnameinfo(ai->ai_addr, ai->ai_addrlen,
                        ntop, sizeof(ntop), strport,
                        sizeof(strport), NI_NUMERICHOST | NI_NUMERICSERV) != 0) {
            fprintf(thread_stderr, "ssh_connect: getnameinfo failed\n");
            continue;
        }
        _sock = socket(ai->ai_family, ai->ai_socktype, ai->ai_protocol);
        if (_sock < 0) {
            fprintf(thread_stderr, "ssh: %s", strerror(errno));
            if (!ai->ai_next) {
                fprintf(thread_stderr, "ssh: connect to host %s port %s: %s", host, strport, strerror(errno));
                free(commandLine);
                return 0;
            }
            continue;
        }
        // TODO: check timeout_connect
        if (ssh_timeout_connect(_sock, ai->ai_addr, ai->ai_addrlen, &connection_timeout) >= 0) {
            // Successful connection. Save host address
            memcpy(&hostaddr, ai->ai_addr, ai->ai_addrlen);
            break;
        } else {
            fprintf(thread_stderr, "connect to host %s port %s: %s\n", ntop, strport, strerror(errno));
            _sock = -1;
        }
    }
    // ssh_set_session
    LIBSSH2_SESSION *_session = libssh2_session_init();
    if (!_session) {
        fprintf(thread_stderr, "Could not establish connection with %s.\n", host);
        free(commandLine);
        return 0;
    }
    libssh2_session_set_blocking(_session, 0);
    libssh2_session_set_timeout(_session, connection_timeout);
    LIBSSH2_CHANNEL *_channel;
    char *errmsg;
    int rc;
    while ((rc = libssh2_session_handshake(_session, _sock)) ==
           LIBSSH2_ERROR_EAGAIN);
    if (rc) {
        libssh2_session_last_error(_session, &errmsg, NULL, 0);
        fprintf(thread_stderr, "SSH error: %s\n", errmsg);
        free(commandLine);
        return -1;
    }
    // Set object as handler
    // void **handler = libssh2_session_abstract(_session);
    // Verify host key
    if (ssh_verify_host(ntop, _session, host, port) <= 0) {
        fprintf(thread_stderr, "Could not check host key %s.\n", host);
        free(commandLine);
        return 0;
    }
    // Connect: ssh_login
    char *userauthlist = NULL;
    int auth_type = 0;
    do {
        userauthlist = libssh2_userauth_list(_session, user, (int)strlen(user));
        if (!userauthlist) {
            if (libssh2_session_last_errno(_session) != LIBSSH2_ERROR_EAGAIN) {
                fprintf(thread_stderr, "No userauth list\n");
                free(commandLine);
                return 0;
            } else {
                ssh_waitsocket(_sock, _session); /* now we wait */
            }
        }
    } while (!userauthlist);
    if (strstr(userauthlist, "password") != NULL) {
        auth_type |= 1;
    }
    if (strstr(userauthlist, "keyboard-interactive") != NULL) {
        auth_type |= 2;
    }
    if (strstr(userauthlist, "publickey") != NULL) {
        auth_type |= 4;
    }
    if (auth_type & 4) {
        // Most common case.
        // Path = getenv(SSH_HOME) or ~/Documents
        char path[PATH_MAX];
        if (getenv("SSH_HOME")) strcpy(path, getenv("SSH_HOME"));
        else sprintf(path, "%s/Documents", getenv("HOME"));
        char keypath[PATH_MAX];
        sprintf(keypath, "%s/.ssh/", path);
        // Loop over all keys in .ssh directory
        DIR* dirp = opendir(keypath);
        if (!dirp) dirp = opendir(path);
        if (!dirp) {
            fprintf(thread_stderr, "Can't open directory %s\n", keypath);
            free(commandLine);
            return 0;
            
        }
        struct dirent *dp;
        char* suffix = ".pub";
        long suffix_len = strlen(suffix);
        while ((dp = readdir(dirp)) != NULL) {
            // does this file end in ".pub"?
            char* publickeyName = dp->d_name;
            if (strncmp( publickeyName + strlen(publickeyName) - suffix_len, suffix, suffix_len ) != 0) continue;
            // is there a file with same name, without .pub?
            char* privatekeyName = strdup(publickeyName);
            privatekeyName[strlen(publickeyName) - suffix_len] = 0x0;
            char publickeypath[PATH_MAX];
            char privatekeypath[PATH_MAX];
            sprintf(publickeypath, "%s%s", keypath, publickeyName);
            sprintf(privatekeypath, "%s%s", keypath, privatekeyName);
            if (access( privatekeypath, F_OK ) == -1) continue;
            while ((rc = libssh2_userauth_publickey_fromfile_ex(_session,
                                                                user,
                                                                strlen(user),
                                                                publickeypath,
                                                                privatekeypath, passphrase))  == LIBSSH2_ERROR_EAGAIN);
            if (rc != 0) { if (verboseFlag) fprintf(thread_stderr, "Authentification failure with passphrase.\n"); continue; } // try another key
            // We are connected
            rc = 0;
            char *errmsg;
            while ((_channel = libssh2_channel_open_session(_session)) == NULL &&
                   libssh2_session_last_error(_session, NULL, NULL, 0) == LIBSSH2_ERROR_EAGAIN) {
                ssh_waitsocket(_sock, _session);
            }
            if (_channel == NULL) {
                libssh2_session_last_error(_session, &errmsg, NULL, 0);
                fprintf(thread_stderr, "ssh: error creating channel: %s\n", errmsg);
                rc = -1;
                break;
            }
            while ((rc = libssh2_channel_exec(_channel, commandLine)) == LIBSSH2_ERROR_EAGAIN) {
                ssh_waitsocket(_sock, _session);
            }
            if (rc != 0) {
                libssh2_session_last_error(_session, &errmsg, NULL, 0);
                fprintf(thread_stderr, "ssh: error exec: %s\n", errmsg);
                rc = -1;
                break;
            }
            rc = ssh_client_loop(_session, _channel, _sock); // data transmission
            break;
        }
        // cleanup:
        (void)closedir(dirp);
        if (rc >= 0) {
            libssh2_channel_free(_channel);
            libssh2_session_free(_session);
            _channel = NULL;
            free(commandLine);
            return rc;
        }
        fprintf(thread_stderr, "Authentification with public key failed\n");
    }
    // public key auth failed
    fprintf(thread_stderr, "Password authentification not supported\n");
    // libssh2_channel_free(_channel);
    libssh2_session_free(_session);
    _channel = NULL;
    free(commandLine);
    
    return -1;
}
