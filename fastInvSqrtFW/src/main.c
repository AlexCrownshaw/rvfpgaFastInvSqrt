#include <stdint.h>

#define WRITE_ADDR(dir, value) { (*(volatile unsigned int*)dir) = (value); }
#define FAST_INV_SQRT_INPUT_ADDR 0x80003100

int main(void)
{
	unsigned int x = 24; // 1.5 in q12.4 (0000_0000_0001_1000)
	WRITE_ADDR(FAST_INV_SQRT_INPUT_ADDR, x);

	return 0;
}