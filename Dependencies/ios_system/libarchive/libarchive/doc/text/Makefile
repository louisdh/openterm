
default: all


archive_entry.3.txt: ../../libarchive/archive_entry.3
	nroff -mdoc ../../libarchive/archive_entry.3 | col -b > archive_entry.3.txt

archive_read.3.txt: ../../libarchive/archive_read.3
	nroff -mdoc ../../libarchive/archive_read.3 | col -b > archive_read.3.txt

archive_read_disk.3.txt: ../../libarchive/archive_read_disk.3
	nroff -mdoc ../../libarchive/archive_read_disk.3 | col -b > archive_read_disk.3.txt

archive_util.3.txt: ../../libarchive/archive_util.3
	nroff -mdoc ../../libarchive/archive_util.3 | col -b > archive_util.3.txt

archive_write.3.txt: ../../libarchive/archive_write.3
	nroff -mdoc ../../libarchive/archive_write.3 | col -b > archive_write.3.txt

archive_write_disk.3.txt: ../../libarchive/archive_write_disk.3
	nroff -mdoc ../../libarchive/archive_write_disk.3 | col -b > archive_write_disk.3.txt

cpio.5.txt: ../../libarchive/cpio.5
	nroff -mdoc ../../libarchive/cpio.5 | col -b > cpio.5.txt

libarchive-formats.5.txt: ../../libarchive/libarchive-formats.5
	nroff -mdoc ../../libarchive/libarchive-formats.5 | col -b > libarchive-formats.5.txt

libarchive.3.txt: ../../libarchive/libarchive.3
	nroff -mdoc ../../libarchive/libarchive.3 | col -b > libarchive.3.txt

libarchive_internals.3.txt: ../../libarchive/libarchive_internals.3
	nroff -mdoc ../../libarchive/libarchive_internals.3 | col -b > libarchive_internals.3.txt

mtree.5.txt: ../../libarchive/mtree.5
	nroff -mdoc ../../libarchive/mtree.5 | col -b > mtree.5.txt

tar.5.txt: ../../libarchive/tar.5
	nroff -mdoc ../../libarchive/tar.5 | col -b > tar.5.txt

bsdtar.1.txt: ../../tar/bsdtar.1
	nroff -mdoc ../../tar/bsdtar.1 | col -b > bsdtar.1.txt

bsdcpio.1.txt: ../../cpio/bsdcpio.1
	nroff -mdoc ../../cpio/bsdcpio.1 | col -b > bsdcpio.1.txt
all: archive_entry.3.txt archive_read.3.txt archive_read_disk.3.txt archive_util.3.txt archive_write.3.txt archive_write_disk.3.txt cpio.5.txt libarchive-formats.5.txt libarchive.3.txt libarchive_internals.3.txt mtree.5.txt tar.5.txt bsdtar.1.txt bsdcpio.1.txt
