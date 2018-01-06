#! /bin/sh

# edit for latest version numbers:
file=file_cmds-272
libutil=libutil-51
libinfo=Libinfo-517
shell=shell_cmds-203
text=text_cmds-99
archive=libarchive-54
curl=curl-105

find . -name .DS_Store -exec rm {} \; -print

# get source for file_cmds
echo "Getting file_cmds"
curl https://opensource.apple.com/tarballs/file_cmds/$file.tar.gz -O
tar xfz $file.tar.gz
rm $file.tar.gz
echo "Creating file_cmds.patch"
diff -Naur $file file_cmds > file_cmds.patch
rm -rf $file

# get source for shell_cmds:
echo "Getting shell_cmds"
curl https://opensource.apple.com/tarballs/shell_cmds/$shell.tar.gz -O
tar xfz $shell.tar.gz
rm $shell.tar.gz
echo "Creating shell_cmds.patch"
diff -Naur $shell shell_cmds > shell_cmds.patch
rm -rf $shell

# get source for text_cmds:
echo "Getting text_cmds"
curl https://opensource.apple.com/tarballs/text_cmds/$text.tar.gz -O
tar xfz $text.tar.gz
rm $text.tar.gz 
echo "Creating text_cmds.patch"
diff -Naur $text text_cmds > text_cmds.patch
rm -rf $text

# get source for BSD-tar: (not gnu-tar because licensing issues).
curl https://opensource.apple.com/tarballs/libarchive/$archive.tar.gz -O
tar xfz $archive.tar.gz
rm $archive.tar.gz
echo "Creating libarchive.patch"
diff -Naur $archive libarchive > libarchive.patch
rm -rf $archive

# get source for curl. This one requires OpenSSH + libssl
curl https://opensource.apple.com/tarballs/curl/$curl.tar.gz -O
tar xfz $curl.tar.gz
rm $curl.tar.gz
echo "Creating curl.patch"
diff -Naur $curl curl > curl.patch
rm -rf $curl

