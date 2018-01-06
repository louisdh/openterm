
default: all


ManPageArchiveEntry3.wiki: ../mdoc2wiki.awk ../../libarchive/archive_entry.3
	awk -f ../mdoc2wiki.awk < ../../libarchive/archive_entry.3 > ManPageArchiveEntry3.wiki

ManPageArchiveRead3.wiki: ../mdoc2wiki.awk ../../libarchive/archive_read.3
	awk -f ../mdoc2wiki.awk < ../../libarchive/archive_read.3 > ManPageArchiveRead3.wiki

ManPageArchiveReadDisk3.wiki: ../mdoc2wiki.awk ../../libarchive/archive_read_disk.3
	awk -f ../mdoc2wiki.awk < ../../libarchive/archive_read_disk.3 > ManPageArchiveReadDisk3.wiki

ManPageArchiveUtil3.wiki: ../mdoc2wiki.awk ../../libarchive/archive_util.3
	awk -f ../mdoc2wiki.awk < ../../libarchive/archive_util.3 > ManPageArchiveUtil3.wiki

ManPageArchiveWrite3.wiki: ../mdoc2wiki.awk ../../libarchive/archive_write.3
	awk -f ../mdoc2wiki.awk < ../../libarchive/archive_write.3 > ManPageArchiveWrite3.wiki

ManPageArchiveWriteDisk3.wiki: ../mdoc2wiki.awk ../../libarchive/archive_write_disk.3
	awk -f ../mdoc2wiki.awk < ../../libarchive/archive_write_disk.3 > ManPageArchiveWriteDisk3.wiki

ManPageCpio5.wiki: ../mdoc2wiki.awk ../../libarchive/cpio.5
	awk -f ../mdoc2wiki.awk < ../../libarchive/cpio.5 > ManPageCpio5.wiki

ManPageLibarchiveFormats5.wiki: ../mdoc2wiki.awk ../../libarchive/libarchive-formats.5
	awk -f ../mdoc2wiki.awk < ../../libarchive/libarchive-formats.5 > ManPageLibarchiveFormats5.wiki

ManPageLibarchive3.wiki: ../mdoc2wiki.awk ../../libarchive/libarchive.3
	awk -f ../mdoc2wiki.awk < ../../libarchive/libarchive.3 > ManPageLibarchive3.wiki

ManPageLibarchiveInternals3.wiki: ../mdoc2wiki.awk ../../libarchive/libarchive_internals.3
	awk -f ../mdoc2wiki.awk < ../../libarchive/libarchive_internals.3 > ManPageLibarchiveInternals3.wiki

ManPageMtree5.wiki: ../mdoc2wiki.awk ../../libarchive/mtree.5
	awk -f ../mdoc2wiki.awk < ../../libarchive/mtree.5 > ManPageMtree5.wiki

ManPageTar5.wiki: ../mdoc2wiki.awk ../../libarchive/tar.5
	awk -f ../mdoc2wiki.awk < ../../libarchive/tar.5 > ManPageTar5.wiki

ManPageBsdtar1.wiki: ../mdoc2wiki.awk ../../tar/bsdtar.1
	awk -f ../mdoc2wiki.awk < ../../tar/bsdtar.1 > ManPageBsdtar1.wiki

ManPageBsdcpio1.wiki: ../mdoc2wiki.awk ../../cpio/bsdcpio.1
	awk -f ../mdoc2wiki.awk < ../../cpio/bsdcpio.1 > ManPageBsdcpio1.wiki
all: ManPageArchiveEntry3.wiki ManPageArchiveRead3.wiki ManPageArchiveReadDisk3.wiki ManPageArchiveUtil3.wiki ManPageArchiveWrite3.wiki ManPageArchiveWriteDisk3.wiki ManPageCpio5.wiki ManPageLibarchiveFormats5.wiki ManPageLibarchive3.wiki ManPageLibarchiveInternals3.wiki ManPageMtree5.wiki ManPageTar5.wiki ManPageBsdtar1.wiki ManPageBsdcpio1.wiki
