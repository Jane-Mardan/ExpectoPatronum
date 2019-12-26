#!Makefile
C_SOURCE = $(shell find . -name "*.c")
C_OBJECTS = $(patsubst %.c, %.o, $(C_SOURCE))
S_SOURCE = $(shell find . -name "*.s")
S_OBJECTS  = $(patsubst %.s, %.o, $(S_SOURCE))

CC = gcc
LD = ld
ASM = nasm

C_FLAGS = -c -Wall -m32 -ggdb -gstabs+ -nostdinc -fno-pic -fno-builtin -fno-stack-protector -I include
LD_FLAGS = -T ./scripts/kernel.ld -m elf_i386 -nostdlib
ASM_FLAGS = -f elf -g -F stabs

all: $(S_OBJECTS) $(C_OBJECTS) link update_image

.c.o: 
	@echo compiling codefiles $< ...
	$(CC) $(C_FLAGS) $< -o $@

.s.o: 
	@echo compling conpilation files $< ...
	$(ASM) $(ASM_FLAGS) $< 

link: 
	@echo linking core files $< ...
	$(LD) $(LD_FLAGS) $(S_OBJECTS) $(C_OBJECTS) -o ExpectroPatronum_kernal

.PHONY:clean
clean:
	$(RM) $(S_OBJECTS) $(C_OBJECTS) ExpectroPatronum_kernal

.PHONY:update_image
update_image:
	sudo mount floppy.image /mnt/kernel
	sudo cp ExpectroPatronum_kernal /mnt/kernal/ExpectroPatronum_kernal 
	sleep 1
	sudo unmount /mnt/kernal

.PHONY:mount_image
mount_image:
	sudo mount floppy.img /mnt/kernel

.PHONY:umount_image
umount_image:
	sudo umount /mnt/kernel

.PHONY:qemu
qemu:
	qemu -fda floppy.img -boot a

.PHONY:bochs
bochs:
	bochs -f tools/bochsrc.txt

.PHONY:debug
debug:
	qemu -S -s -fda floppy.img -boot a &
	sleep 1
	cgdb -x tools/gdbinit
