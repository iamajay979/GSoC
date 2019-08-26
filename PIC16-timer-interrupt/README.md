# PIC16-timer-interrupt

Code for PIC16 (KME), on AXIOM Remote, to execute a blink on S2A LED via timer interrupt.

## Programmed on terminal by:
```
gpasm remote_e_inttime.asm   
gcc ser_icsp6_prog_e.c -o ser_icsp6_prog_e
sudo cp ser_icsp6_prog_e /usr/local/bin
xc32-gcc -O2 -std=gnu99 -mprocessor=32MZ2048ECG100 -Wall -o icsp_ser.elf icsp_ser.c
xc32-bin2hex icsp_ser.elf
sudo pic32prog icsp_ser.hex
sudo ser_icsp6_prog_e /dev/ttyUSB0 remote_e_inttime.hex
```
We use icsp_ser.hex on the PIC32 for PIC16 programming mode and use ser_icsp6_prog_e for programing our code to the PIC16 (KME on this case)
