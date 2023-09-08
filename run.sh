#!/bin/bash

echo "************* Alire build *****************"
alr build
echo "************* Openocd ********************"
sudo openocd -f /usr/local/share/openocd/scripts/board/stm32f429disc1.cfg -c "program bin/midero verify reset"
echo "******************************************"
