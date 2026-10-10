# Makefile for NoMount

# Pinned NoMount v2.1.0: c7f63e3feb4125d591b6969a33aac04feb40f8ba (500 commits).
# This code is vendored; do not use the parent kernel repository's commit count.
ccflags-y += -DNOMOUNT_COMMIT_COUNT=\"500\"

obj-$(CONFIG_NOMOUNT) += nomount.o
ccflags-y += -std=gnu11 -Wno-declaration-after-statement
