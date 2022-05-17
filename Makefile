all:
	as -g -o main.o tp3.S
	ld --oformat binary -o main.img -T link.ld main.o
	qemu-system-x86_64 -drive file=main.img,format=raw
clean:
	rm *.o *.img