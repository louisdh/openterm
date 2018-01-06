#! /bin/sh

# edit for latest version numbers:
file=file_cmds-272
libutil=libutil-51
libinfo=Libinfo-517
shell=shell_cmds-203
text=text_cmds-99
archive=libarchive-54
curl=curl-105

# Cleanup:
rm -rf file_cmds shell_cmds text_cmds libutil libinfo libarchive curl
rm -rf $file $libutil $libinfo $shell $text $archive $curl 

# get source for file_cmds
echo "Getting file_cmds"
curl https://opensource.apple.com/tarballs/file_cmds/$file.tar.gz -O
tar xfz $file.tar.gz
rm $file.tar.gz
# move to position independent of version number
# so Xcode project stays valid
mv $file file_cmds 
(cd file_cmds ; patch -p1 < ../file_cmds.patch ; cd ..)

# get source for libutil:
echo "Getting libutil"
curl https://opensource.apple.com/tarballs/libutil/$libutil.tar.gz -O
tar xfz $libutil.tar.gz
rm $libutil.tar.gz
mv $libutil libutil

# get source for libInfo:
echo "Getting libinfo"
curl https://opensource.apple.com/tarballs/Libinfo/$libinfo.tar.gz -O
tar xfz $libinfo.tar.gz
rm $libinfo.tar.gz 
mv $libinfo libinfo

# get source for shell_cmds:
echo "Getting shell_cmds"
curl https://opensource.apple.com/tarballs/shell_cmds/$shell.tar.gz -O
tar xfz $shell.tar.gz
rm $shell.tar.gz
mv $shell shell_cmds
(cd shell_cmds ; patch -p1 < ../shell_cmds.patch ; cd ..)

# get source for text_cmds:
echo "Getting text_cmds"
curl https://opensource.apple.com/tarballs/text_cmds/$text.tar.gz -O
tar xfz $text.tar.gz
rm $text.tar.gz 
mv $text text_cmds
(cd text_cmds ; patch -p1 < ../text_cmds.patch ; cd ..)

# get source for BSD-tar: (not gnu-tar because licensing issues).
curl https://opensource.apple.com/tarballs/libarchive/$archive.tar.gz -O
tar xfz $archive.tar.gz
rm $archive.tar.gz
mv $archive libarchive
(cd libarchive ; patch -p1 < ../libarchive.patch ; cd ..)

# get source for curl. This one requires OpenSSH + libssl
curl https://opensource.apple.com/tarballs/curl/$curl.tar.gz -O
tar xfz $curl.tar.gz
rm $curl.tar.gz
mv $curl curl
(cd curl ; patch -p1 < ../curl.patch ; cd ..)


