# PIC16_debouncing-test

## debouncer_spi.asm and debouncer_kmw.asm codes

Code for PIC16 (KMW), on AXIOM Remote, to execute a debouncing test.

debouncer_spi.asm performes a debouncing for the bounces sent via SPI from PIC32 (on RB6), and for the button P13 (RB5), returning the output to PIC32 via USART.

debouncer_kmw.asm includes the rest of the buttons of KMW. Finally, this code tests the bounce on RB6 (SPI), RB5 (P13), RB2 (TS1A), RB3 (TS1B), RA4 (S1A), RA3 (S1B), RC2 (TS2A) and RC3 (TS2B).

### Programmed on terminal by:
```
gcc ser_icsp6_prog_w.c -o ser_icsp6_prog_w
sudo cp ser_icsp6_prog_w /usr/local/bin

xc32-gcc -O2 -std=gnu99 -mprocessor=32MZ2048ECG100 -Wall -o icsp_ser.elf ser_dbg.c
xc32-bin2hex ser_dbg.elf
sudo pic32prog ser_dbg.hex

gpasm debouncer_kmw.asm
sudo ser_icsp6_prog_e /dev/ttyUSB0 debouncer_kmw.hex
```
We use ser_dbg.hex on the PIC32 for PIC16 programming mode and use ser_icsp6_prog_e for programing our code to the PIC16 (KME on this case)

## comm.sh bash script

Script used to run the debouncing code. It is can be used to read the sequence from the terminal or having it on the script as it is (changing the commented lines).
It initializes the required configuration for the SPI communication (with ?0=1=- ) and sends the stablished hexadecimal words, for it to be pulses in binary, each bit of 1us. This allows you to simulate bounces to test the debouncing code.

### on terminal:
```
sudo ./comm.sh
```
To test the code you can also check minicom:
```
sudo minicom -b 1000000 -con USB0
```
When oppening minicom should be written ?0=1=-
