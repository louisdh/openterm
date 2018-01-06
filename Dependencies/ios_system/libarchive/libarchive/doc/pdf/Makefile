
default: all


archive_entry.3.pdf: ../../libarchive/archive_entry.3
	groff -mdoc -T ps ../../libarchive/archive_entry.3 | ps2pdf - - > archive_entry.3.pdf

archive_read.3.pdf: ../../libarchive/archive_read.3
	groff -mdoc -T ps ../../libarchive/archive_read.3 | ps2pdf - - > archive_read.3.pdf

archive_read_disk.3.pdf: ../../libarchive/archive_read_disk.3
	groff -mdoc -T ps ../../libarchive/archive_read_disk.3 | ps2pdf - - > archive_read_disk.3.pdf

archive_util.3.pdf: ../../libarchive/archive_util.3
	groff -mdoc -T ps ../../libarchive/archive_util.3 | ps2pdf - - > archive_util.3.pdf

archive_write.3.pdf: ../../libarchive/archive_write.3
	groff -mdoc -T ps ../../libarchive/archive_write.3 | ps2pdf - - > archive_write.3.pdf

archive_write_disk.3.pdf: ../../libarchive/archive_write_disk.3
	groff -mdoc -T ps ../../libarchive/archive_write_disk.3 | ps2pdf - - > archive_write_disk.3.pdf

cpio.5.pdf: ../../libarchive/cpio.5
	groff -mdoc -T ps ../../libarchive/cpio.5 | ps2pdf - - > cpio.5.pdf

libarchive-formats.5.pdf: ../../libarchive/libarchive-formats.5
	groff -mdoc -T ps ../../libarchive/libarchive-formats.5 | ps2pdf - - > libarchive-formats.5.pdf

libarchive.3.pdf: ../../libarchive/libarchive.3
	groff -mdoc -T ps ../../libarchive/libarchive.3 | ps2pdf - - > libarchive.3.pdf

libarchive_internals.3.pdf: ../../libarchive/libarchive_internals.3
	groff -mdoc -T ps ../../libarchive/libarchive_internals.3 | ps2pdf - - > libarchive_internals.3.pdf

mtree.5.pdf: ../../libarchive/mtree.5
	groff -mdoc -T ps ../../libarchive/mtree.5 | ps2pdf - - > mtree.5.pdf

tar.5.pdf: ../../libarchive/tar.5
	groff -mdoc -T ps ../../libarchive/tar.5 | ps2pdf - - > tar.5.pdf

bsdtar.1.pdf: ../../tar/bsdtar.1
	groff -mdoc -T ps ../../tar/bsdtar.1 | ps2pdf - - > bsdtar.1.pdf

bsdcpio.1.pdf: ../../cpio/bsdcpio.1
	groff -mdoc -T ps ../../cpio/bsdcpio.1 | ps2pdf - - > bsdcpio.1.pdf
all: archive_entry.3.pdf archive_read.3.pdf archive_read_disk.3.pdf archive_util.3.pdf archive_write.3.pdf archive_write_disk.3.pdf cpio.5.pdf libarchive-formats.5.pdf libarchive.3.pdf libarchive_internals.3.pdf mtree.5.pdf tar.5.pdf bsdtar.1.pdf bsdcpio.1.pdf
