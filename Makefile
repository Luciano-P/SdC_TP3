gdb: main.img
	qemu-system-i386 -fda main.img -boot a -s -S -monitor stdio

qemu: main.img
	qemu-system-x86_64 -drive file=main.img,format=raw

main.img: tp3.S
	as -g -o main.o tp3.S
	ld --oformat binary -o main.img -T link.ld main.o
	
clean:
	rm *.o *.img