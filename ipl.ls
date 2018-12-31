OUTPUT_FORMAT("binary");
IPLBASE = 0x7c00;

SECTIONS {
	. = IPLBASE;
	.text	: {*(.text)}
	.data	: {*(.data)}
	. = IPLBASE + 510;
	.sign	: {SHORT(0xaa55)}
}
