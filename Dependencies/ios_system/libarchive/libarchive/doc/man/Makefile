
default: all


archive_entry.3: ../mdoc2man.awk ../../libarchive/archive_entry.3
	awk -f ../mdoc2man.awk < ../../libarchive/archive_entry.3 > archive_entry.3

archive_read.3: ../mdoc2man.awk ../../libarchive/archive_read.3
	awk -f ../mdoc2man.awk < ../../libarchive/archive_read.3 > archive_read.3

archive_read_disk.3: ../mdoc2man.awk ../../libarchive/archive_read_disk.3
	awk -f ../mdoc2man.awk < ../../libarchive/archive_read_disk.3 > archive_read_disk.3

archive_util.3: ../mdoc2man.awk ../../libarchive/archive_util.3
	awk -f ../mdoc2man.awk < ../../libarchive/archive_util.3 > archive_util.3

archive_write.3: ../mdoc2man.awk ../../libarchive/archive_write.3
	awk -f ../mdoc2man.awk < ../../libarchive/archive_write.3 > archive_write.3

archive_write_disk.3: ../mdoc2man.awk ../../libarchive/archive_write_disk.3
	awk -f ../mdoc2man.awk < ../../libarchive/archive_write_disk.3 > archive_write_disk.3

cpio.5: ../mdoc2man.awk ../../libarchive/cpio.5
	awk -f ../mdoc2man.awk < ../../libarchive/cpio.5 > cpio.5

libarchive-formats.5: ../mdoc2man.awk ../../libarchive/libarchive-formats.5
	awk -f ../mdoc2man.awk < ../../libarchive/libarchive-formats.5 > libarchive-formats.5

libarchive.3: ../mdoc2man.awk ../../libarchive/libarchive.3
	awk -f ../mdoc2man.awk < ../../libarchive/libarchive.3 > libarchive.3

libarchive_internals.3: ../mdoc2man.awk ../../libarchive/libarchive_internals.3
	awk -f ../mdoc2man.awk < ../../libarchive/libarchive_internals.3 > libarchive_internals.3

mtree.5: ../mdoc2man.awk ../../libarchive/mtree.5
	awk -f ../mdoc2man.awk < ../../libarchive/mtree.5 > mtree.5

tar.5: ../mdoc2man.awk ../../libarchive/tar.5
	awk -f ../mdoc2man.awk < ../../libarchive/tar.5 > tar.5

bsdtar.1: ../mdoc2man.awk ../../tar/bsdtar.1
	awk -f ../mdoc2man.awk < ../../tar/bsdtar.1 > bsdtar.1

bsdcpio.1: ../mdoc2man.awk ../../cpio/bsdcpio.1
	awk -f ../mdoc2man.awk < ../../cpio/bsdcpio.1 > bsdcpio.1
all: archive_entry.3 archive_read.3 archive_read_disk.3 archive_util.3 archive_write.3 archive_write_disk.3 cpio.5 libarchive-formats.5 libarchive.3 libarchive_internals.3 mtree.5 tar.5 bsdtar.1 bsdcpio.1
