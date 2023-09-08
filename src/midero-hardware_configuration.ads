------------------------------------------------------------------------------
--                                                                          --
--                      Copyright (C) 2018, AdaCore                         --
--                                                                          --
--  Redistribution and use in source and binary forms, with or without      --
--  modification, are permitted provided that the following conditions are  --
--  met:                                                                    --
--     1. Redistributions of source code must retain the above copyright    --
--        notice, this list of conditions and the following disclaimer.     --
--     2. Redistributions in binary form must reproduce the above copyright --
--        notice, this list of conditions and the following disclaimer in   --
--        the documentation and/or other materials provided with the        --
--        distribution.                                                     --
--     3. Neither the name of STMicroelectronics nor the names of its       --
--        contributors may be used to endorse or promote products derived   --
--        from this software without specific prior written permission.     --
--                                                                          --
--   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS    --
--   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT      --
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR  --
--   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT   --
--   HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, --
--   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT       --
--   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,  --
--   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY  --
--   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT    --
--   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE  --
--   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.   --
--                                                                          --
------------------------------------------------------------------------------
--  This package declares all the hardware devices and related values on the
--  STM32 board actually used by the application. The purpose is to specify
--  them all in one place, so that changes and/or additions can be checked
--  easily for conflicts.

with STM32;
with STM32.ADC;
with STM32.Device;
with STM32.GPIO;
with STM32.Timers;

pragma Elaborate_All (STM32);

package Midero.Hardware_Configuration is   
   use STM32;
   use STM32.ADC;
   use STM32.Device;
   use STM32.GPIO;
   use STM32.Timers;

   --  The hardware on the STM32 board used by the fours motors (on the
   --  L298N-driver)
   Motor_PWM_Freq : constant := 490;
   --  Motor 1 : Motor Bottom Right
   --  Encoder motor
   Motor1_Encoder_Input1 : GPIO_Point renames PA15;
   Motor1_Encoder_Input2 : GPIO_Point renames PB3;
   Motor1_Encoder_Timer  : constant access Timer := Timer_2'Access;
   Motor1_Encoder_AF     : constant STM32.GPIO_Alternate_Function := GPIO_AF_TIM2_1;
   --  Engine GPIO
   Motor1_PWM_Engine     : GPIO_Point renames PA6;
   Motor1_PWM_Engine_TMR : constant access Timer := Timer_3'Access;
   Motor1_PWM_Channel    : constant Timer_Channel := Channel_1;
   Motor1_PWM_Output_AF  : constant STM32.GPIO_Alternate_Function := GPIO_AF_TIM3_2;
   Motor1_Polarity1      : GPIO_Point renames PG10;
   Motor1_Polarity2      : GPIO_Point renames PG11; 
   --  Motor 2 : Motor Bottom Left
   --  Encoder motor
   Motor2_Encoder_Input1 : GPIO_Point renames PB0;
   Motor2_Encoder_Input2 : GPIO_Point renames PB1;
   Motor2_Encoder_Timer  : constant access Timer := Timer_1'Access;
   Motor2_Encoder_AF     : constant STM32.GPIO_Alternate_Function := GPIO_AF_TIM1_1; 
   -- for demo purpose
   --  Engine PWM
   Motor2_PWM_Engine     : GPIO_Point renames PA3;
   Motor2_PWM_Engine_TMR : constant access Timer := Timer_5'Access;
   Motor2_PWM_Channel    : constant Timer_Channel := Channel_4;
   Motor2_PWM_Output_AF  : constant STM32.GPIO_Alternate_Function := GPIO_AF_TIM5_2;
   Motor2_Polarity1      : GPIO_Point renames PC1;
   Motor2_Polarity2      : GPIO_Point renames PC0; 
   --  Motor 3 : Motor Top Right
   --  Encoder
   Motor3_Encoder_Input1 : GPIO_Point renames PB6;
   Motor3_Encoder_Input2 : GPIO_Point renames PB7;
   Motor3_Encoder_Timer  : constant access Timer := Timer_4'Access;
   Motor3_Encoder_AF     : constant STM32.GPIO_Alternate_Function := GPIO_AF_TIM4_2;
   --  Engine PWM
   Motor3_PWM_Engine     : GPIO_Point renames PA0;
   Motor3_PWM_Engine_TMR : constant access Timer := Timer_2'Access;
   Motor3_PWM_Channel    : constant Timer_Channel := Channel_1;
   Motor3_PWM_Output_AF  : constant STM32.GPIO_Alternate_Function := GPIO_AF_TIM2_1;
   Motor3_Polarity1      : GPIO_Point renames PC3;
   Motor3_Polarity2      : GPIO_Point renames PC2;
   --  Motor 4 : Motor Top Left
   --  Encoder
   Motor4_Encoder_Input1 : GPIO_Point renames PB14;
   Motor4_Encoder_Input2 : GPIO_Point renames PB15;
   Motor4_Encoder_Timer  : constant access Timer := Timer_8'Access;
   Motor4_Encoder_AF     : constant STM32.GPIO_Alternate_Function := GPIO_AF_TIM8_3;
   --  Engine PWM
   Motor4_PWM_Engine     : GPIO_Point renames PD12;
   Motor4_PWM_Engine_TMR : constant access Timer := Timer_4'Access;
   Motor4_PWM_Channel    : constant Timer_Channel := Channel_1;
   Motor4_PWM_Output_AF  : constant STM32.GPIO_Alternate_Function := GPIO_AF_TIM4_2;
   Motor4_Polarity1      : GPIO_Point renames PC5;
   Motor4_Polarity2      : GPIO_Point renames PC4;
   
   --  SharpIR sensors
   --  Sonar 1
   Selected_ADC_Unit      : Analog_To_Digital_Converter renames ADC_1;
   Selected_Input_Channel : constant Analog_Input_Channel := 5;
   Input_Pin              : GPIO_Point renames PA5;
   
end Midero.Hardware_Configuration;
