#!/bin/bash
echo "******************** ALIRE **********************"
echo "********** Import environment variables *********"
eval "$(alr printenv)"
echo "************** Build with Alire *****************"
alr build 
echo "************* GNATSTUDIO ************************"
gnatstudio midero.gpr
echo "*************************************************"

