# PIC16_blink

Upgraded code from the original remote_e code by coding the blink part in the main.

## Programmed on terminal by:
```
gpasm remote_e_b.asm   
gcc ser_icsp6_prog_e.c -o ser_icsp6_prog_e
sudo cp ser_icsp6_prog_e /usr/local/bin
xc32-gcc -O2 -std=gnu99 -mprocessor=32MZ2048ECG100 -Wall -o icsp_ser.elf icsp_ser.c
xc32-bin2hex icsp_ser.elf
sudo pic32prog icsp_ser.hex
sudo ser_icsp6_prog_e /dev/ttyUSB0 remote_e_b.hex
```
We use icsp_ser.hex on the PIC32 for PIC16 programming mode and use ser_icsp6_prog_e for programing our code to the PIC16 (KME on this case)
