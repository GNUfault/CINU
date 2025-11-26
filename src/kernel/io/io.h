#ifndef IO_H
#define IO_H

extern unsigned char inb(unsigned short port);
extern unsigned short inw(unsigned short port);
extern unsigned int inl(unsigned short port);

extern void outb(unsigned short port, unsigned char val);
extern void outw(unsigned short port, unsigned short val);
extern void outl(unsigned short port, unsigned int val);

#endif
