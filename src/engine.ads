------------------------------------------------------------------------------
--                                                                          --
--                Copyright (C) 2017-2019, AdaCore                          --
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
--     3. Neither the name of the copyright holder nor the names of its     --
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

--  This package provides interface for                                     --
--  physical 12V DC motor. Allowing client to control it                    --
------------------------------------------------------------------------------
with Beta_Types;
with STM32;
with STM32.Device;
with STM32.GPIO;
with STM32.PWM;
with STM32.Timers;

with Midero;
with Quadrature_Encoders;

pragma elaborate_all (STM32);

package Engine is
   use Midero;
   use Beta_Types;
   use STM32.Device;
   use STM32.GPIO;
   use STM32.Timers;
   use STM32.PWM;
   use Quadrature_Encoders;

   type    Motor is tagged limited private;
   type    Motors_Array is array (Positive range 1 .. 4) of Motor;
   type    Directions is (Forward, Backward);
   type    Motor_Encoder_Counts is range -(2**31) .. +(2**31 - 1);
   subtype Power_Level is Integer range 0 .. 100;
   ----------------------
   --  Motor utilities --
   ----------------------
   function Throttle (This :  Motor) return Power_Level;
   function Rotation_Direction (This : Motor) return Directions;
   Encoder_Count_Per_Revolution :  constant Revolution;

   procedure Engage (This : in out Motor; Direction : Directions;
                     Power : Power_Level) with
     Post => Throttle (This) = Power;
   procedure Stop (This : in out Motor) with
     Post => Throttle (This) = 100;
   --  Full stop immediatly and actively lock motor position

   procedure Coast (This : in out Motor) with
     Post => Throttle (This) = 0;
   --  Gradual stop without locking motor position
   function  Encoder_Count (This : Motor) return Motor_Encoder_Counts;
   procedure Reset_Encoder_Count (This : in out Motor) with
     Post => Encoder_Count (This) = 0;

   procedure Initialize
     (This                 : in out Motor;
      --  motor encoder
      Encoder_Input1       : GPIO_Point;
      Encoder_Input2       : GPIO_Point;
      Encoder_Timer        : not null access Timer;
      Encoder_AF           : STM32.GPIO_Alternate_Function;
      --  motor power control
      PWM_Timer            : not null access Timer;
      PWM_Output_Frequency : UInt32; -- in Hertz
      PWM_AF               : STM32.GPIO_Alternate_Function;
      PWM_Output           : GPIO_Point;
      PWM_Output_Channel   : Timer_Channel;
      --  discrete outputs to H-Bridge that control direction and stopping
      Polarity1            : GPIO_Point;
      Polarity2            : GPIO_Point)
     with
       Pre  => Has_32bit_Counter (Encoder_Timer.all) and then
               Bidirectional (Encoder_Timer.all),
       Post => Encoder_Count (This) = 0 and then
               Throttle (This) = 0;

private
   Encoder_Count_Per_Revolution : constant Revolution := 720;
   type Motor is tagged limited
      record
         Encoder           : Rotary_Encoder;
         Power_Plant       : PWM_Modulator;
         Power_Channel     : Timer_Channel;
         H_Bridge1         : GPIO_Point;
         H_Bridge2         : GPIO_Point;
      end record;
end Engine;
