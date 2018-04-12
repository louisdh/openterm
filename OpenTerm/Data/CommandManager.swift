//
//  CommandManager.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 09/04/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

class CommandManager {
	
	let documentManager: DocumentManager
	
	var fileManager: FileManager {
		return documentManager.fileManager
	}

	static let shared = CommandManager(documentManager: .shared)

	init(documentManager: DocumentManager) {
		
		self.documentManager = documentManager
		
	}
	
	var scriptCommands: [String] {
		
		do {
			
			let documentsURLs = try fileManager.contentsOfDirectory(at: documentManager.scriptsURL, includingPropertiesForKeys: [], options: .skipsPackageDescendants)
			
			let pridelandURLs = documentsURLs.filter({ $0.pathExtension.lowercased() == "prideland" })
			
			return pridelandURLs.map({ ($0.lastPathComponent as NSString).deletingPathExtension })
			
		} catch {
			
			return []
		}
		
	}
	
	func script(named name: String) -> PridelandDocument? {
		
		guard scriptCommands.contains(name) else {
			return nil
		}
		
		let documentURL = documentManager.scriptsURL.appendingPathComponent("\(name).prideland")
		
		guard let fileWrapper = try? FileWrapper(url: documentURL, options: []) else {
			return nil
		}
		
		let document = PridelandDocument(fileURL: documentURL)
		
		do {
			try document.load(fromContents: fileWrapper, ofType: "prideland")
		} catch {
			return nil
		}
		
		return document
	}
	
	func description(for command: String) -> String? {
		
		if let scriptDocument = script(named: command) {
			return scriptDocument.metadata?.description ?? ""
		}
		
		return CommandManager.descriptions[command]
	}
	
	static private let descriptions = ["awk": "a powerful method for processing or analyzing text files",
									   "cat": "read files",
									   "cd": "change the current directory",
									   "chflags": "change a file or folder's flags",
									   "chksum": "display file checksums and block counts",
									   "compress": "compress files",
									   "cp": "copy a file or folder",
									   "credits": "display the OpenTerm credits",
									   "cub": "execute a Cub script",
									   "curl": "transfer data from or to a server",
									   "date": "get the current date and time",
									   "dig": "a flexible tool for interrogating DNS name servers",
									   "du": "display disk usage statistics",
									   "echo": "display message on screen",
									   "egrep": "search file(s) for specific text",
									   "env": "list or set environment variables and optionally run a utility",
									   "fgrep": "searches for fixed-character strings in a file or files",
									   "grep": "search file(s) for specific text",
									   "gunzip": "compress or decompress files",
									   "gzip": "compress or decompress files",
									   "host": "perform DNS lookups",
									   "link": "make hard links and symbolic links",
									   "ln": "make hard links and symbolic links",
									   "ls": "list directory contents",
									   "mkdir": "create a directory",
									   "mv": "move files and/or folders",
									   "nc": "read and write data across networks - arbitrary TCP and UDP connections and listens",
									   "nslookup": "query Internet name servers interactively for information",
									   "open-url": "open a different app, optionally with a callback",
									   "pbcopy": "copy data to the clipboard",
									   "pbpaste": "paste data from the clipboard",
									   "ping": "test a network connection",
									   "printenv": "list the names and values of all environment variables",
									   "pwd": "print working directory, the absolute pathname of the current folder – tells you where you are",
									   "readlink": "display the status of a file",
									   "rlogin": "starts a terminal session on a remote host",
									   "rm": "delete files and folders",
									   "rmdir": "remove directory – delete folders",
									   "say": "convert text to audible speech",
									   "scp": " copy files across an ssh connection",
									   "sed": "perform basic text transformations on an input stream",
									   "setenv": "adds or changes the value of an environment variable",
									   "sftp": "transfer files securely over a network connection",
									   "share": "share text or a file using a native share sheet",
									   "ssh": "provides a secure encrypted connection between two hosts over an insecure network",
									   "ssh-keygen": "creates a key pair for public key authentication",
									   "stat": "display the status of a file",
									   "sum": "display file checksums and block counts",
									   "tar": "create, add files to, or extract files from an archive file in gnutar format, called a tarfile",
									   "tee": "redirect output to multiple files",
									   "telnet": "allows interactive communication with another host using the TELNET protocol",
									   "touch": "change file timestamps, or create a file",
									   "tr": "translate, squeeze, and/or delete characters",
									   "uname": "print operating system name",
									   "uncompress": "uncompresses files that have been compressed using the compress command",
									   "unlink": "remove a hard link to a file",
									   "unsetenv": "removes the value of an environment variable",
									   "uptime": "shows how long system has been running",
									   "wc": "word count, line, character, and byte count",
									   "whoami": "print the current user name",
									   "help": "display all available commands",
									   "clear": "clear the screen"]
	
}
