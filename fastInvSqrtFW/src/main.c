#include <stdint.h>
#include <bsp_printf.h>
#include <bsp_mem_map.h>
#include <bsp_version.h>
#include <psp_api.h>


#define WRITE_ADDR(dir, value) { (*(volatile unsigned int*)dir) = (value); }
#define READ_ADDR(dir) (*(volatile unsigned int*)dir)

#define FAST_INV_SQRT_INPUT_ADDR 0x80003100
#define FAST_INV_SQRT_OUTPUT_ADDR 0x80003104

void delay()
{
	for (int i=0;i<500000000;i++){};	// Delay
}

int main(void)
{
	unsigned int x = 8; // 0.5 in q12.4 (0000_0000_0000_1000)

	WRITE_ADDR(FAST_INV_SQRT_INPUT_ADDR, x);

	// WRITE_ADDR(0x80003104, x);


	// delay();
	unsigned int y = READ_ADDR(FAST_INV_SQRT_OUTPUT_ADDR);

	// x = 24; // 1.5 in q12.4 (0000_0000_0001_1000)
	// WRITE_ADDR(FAST_INV_SQRT_INPUT_ADDR, x);

	// y = READ_ADDR(FAST_INV_SQRT_OUTPUT_ADDR);

	// x = 375; // 23.4375 in q12.4 (0000_0001_0111_0111)
	// WRITE_ADDR(FAST_INV_SQRT_INPUT_ADDR, x);

	return 0;
}