#define SCREEN_WIDTH 1024
#define SCREEN_HEIGHT 768
#define CHAR_WIDTH 8
#define CHAR_HEIGHT 16
#define BYTES_PER_PIXEL 3
#define CHARS_PER_LINE (SCREEN_WIDTH / CHAR_WIDTH)
#define LINES_PER_SCREEN (SCREEN_HEIGHT / CHAR_HEIGHT)

unsigned int cursor_x = 0;
unsigned int cursor_y = 0;
static unsigned char *framebuffer = 0;

extern unsigned char _binary_font_bin_start[];

static void init_framebuffer(void) {
    if (!framebuffer) {
        framebuffer = (unsigned char *)(*(unsigned int *)0x5000);
    }
}

static void scroll_screen(void) {
    init_framebuffer();
    
    unsigned int line_size = SCREEN_WIDTH * CHAR_HEIGHT * BYTES_PER_PIXEL;
    unsigned int total_size = line_size * (LINES_PER_SCREEN - 1);
    
    unsigned char *src = framebuffer + line_size;
    unsigned char *dst = framebuffer;
    
    for (unsigned int i = 0; i < total_size; i++) {
        dst[i] = src[i];
    }
    
    dst = framebuffer + line_size * (LINES_PER_SCREEN - 1);
    for (unsigned int i = 0; i < line_size; i++) {
        dst[i] = 0;
    }
    
    cursor_y--;
}

static void draw_char(unsigned char c) {
    init_framebuffer();
    
    if (cursor_y >= LINES_PER_SCREEN) {
        scroll_screen();
    }
    
    unsigned char *glyph = &_binary_font_bin_start[c * CHAR_HEIGHT];
    
    unsigned int y_offset = cursor_y * CHAR_HEIGHT * SCREEN_WIDTH * BYTES_PER_PIXEL;
    unsigned int x_offset = cursor_x * CHAR_WIDTH * BYTES_PER_PIXEL;
    unsigned char *dest = framebuffer + y_offset + x_offset;
    
    for (int row = 0; row < CHAR_HEIGHT; row++) {
        unsigned char bits = glyph[row];
        
        for (int col = 0; col < CHAR_WIDTH; col++) {
            if (bits & 0x80) {
                // VGA Light Grey (RGB: 192, 192, 192) in BGR format
                dest[0] = 0xC0;  // Blue
                dest[1] = 0xC0;  // Green
                dest[2] = 0xC0;  // Red
            } else {
                dest[0] = 0x00;  // Black background
                dest[1] = 0x00;
                dest[2] = 0x00;
            }
            bits <<= 1;
            dest += BYTES_PER_PIXEL;
        }
        
        dest += SCREEN_WIDTH * BYTES_PER_PIXEL - CHAR_WIDTH * BYTES_PER_PIXEL;
    }
    
    cursor_x++;
    if (cursor_x >= CHARS_PER_LINE) {
        cursor_x = 0;
        cursor_y++;
    }
}

void printk(const char *str) {
    init_framebuffer();
    
    while (*str) {
        unsigned char c = *str++;
        
        if (c == '\n') {
            cursor_x = 0;
            cursor_y++;
            if (cursor_y >= LINES_PER_SCREEN) {
                scroll_screen();
            }
        } else if (c >= 32 && c <= 126) {
            draw_char(c);
        }
    }
}
