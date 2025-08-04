#include <errno.h>
#include <string.h>
#include <stdio.h>

#include <avr/io.h>
#include <util/delay.h>

#define BAUD 9600
#define UBRR_VALUE (((F_CPU / (BAUD * 16UL))) - 1)

void uart_init(void) {
    // Set baud rate
    UBRR0H = (unsigned char)(UBRR_VALUE >> 8);
    UBRR0L = (unsigned char)UBRR_VALUE;

    // Enable receiver and transmitter
    UCSR0B = (1 << RXEN0) | (1 << TXEN0);

    // Set frame format: 8 data, 1 stop bit
    UCSR0C = (3 << UCSZ00);
}

void uart_putchar(char c) {
    // Wait for empty transmit buffer
    while (!(UCSR0A & (1 << UDRE0)));

    // Put data into buffer, sends the data
    UDR0 = c;
}

void uart_puts(const char *s) {
    while (*s) {
        uart_putchar(*s++);
    }
}

int main(void) {
    uart_init();
    uart_puts("Hello World!\r\nThank you!\r\n");

    while (1) {}
    return 0;
}
