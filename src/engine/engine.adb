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

with Ada.Unchecked_Conversion;

package body Engine is

   procedure Configure_Polarity_Control (This : GPIO_Point);
   --  Configures the GPIO port/pin pair as a discrete output to the L298N
   --  Shield. These outputs control the polarity of the power provided to the
   --  motors, thereby controlling their direction, as well as whether they
   --  coast to a stop or come to an immediate halt
   --------------
   -- Throttle --
   --------------
   function Throttle (This : Motor) return Power_Level is
     (This.Power_Plant.Current_Duty_Cycle);
   -------------------------
   --  Rotation_Direction --
   -------------------------
   function Rotation_Direction (This : Motor) return Directions is
   begin
      case Current_Direction (This.Encoder) is
         when Up   => return Forward;
         when Down => return Backward;
      end case;
   end Rotation_Direction;
   ------------
   -- Engage --
   ------------
   procedure Engage (This : in out Motor; Direction : Directions;
                     Power : Power_Level) is
   begin
      case Direction is
         when Forward =>
            Toggle   (This.H_Bridge1);
            Clear    (This.H_Bridge2);
         when Backward =>
            Clear    (This.H_Bridge1);
            Toggle   (This.H_Bridge2);
      end case;
      This.Power_Plant.Set_Duty_Cycle (Power);
   end Engage;
   ----------
   -- Stop --
   ----------
   procedure Stop (This : in out Motor) is
   begin
      Clear (This.H_Bridge1);
      Clear (This.H_Bridge2);
      This.Power_Plant.Set_Duty_Cycle (100);   -- Full power to Lock position
   end Stop;
   -----------
   -- Coast --
   -----------
   procedure Coast (This : in out Motor) is
   begin
      Clear (This.H_Bridge1);
      Clear (This.H_Bridge2);
      This.Power_Plant.Set_Duty_Cycle (0); -- Do not lock position
   end Coast;
   -------------------------
   -- Reset_Encoder_Count --
   -------------------------
   procedure Reset_Encoder_Count (This : in out Motor) is
   begin
      Reset_Count (This.Encoder);
   end Reset_Encoder_Count;
   -------------------
   -- Encoder_Count --
   -------------------
   function Encoder_Count (This : Motor) return Motor_Encoder_Counts is
      function As_Motor_Encoder_Counts is
        new Ada.Unchecked_Conversion (Source => UInt32,
                                      Target => Motor_Encoder_Counts);
   begin
      return As_Motor_Encoder_Counts (Current_Count (This.Encoder));
   end Encoder_Count;
   ----------------
   -- Initialize --
   ----------------
   procedure Initialize
     (This                 : in out Motor;
      Encoder_Input1       : GPIO_Point;
      Encoder_Input2       : GPIO_Point;
      Encoder_Timer        : not null access Timer;
      Encoder_AF           : STM32.GPIO_Alternate_Function;
      PWM_Timer            : not null access Timer;
      PWM_Output_Frequency : UInt32;
      PWM_AF               : STM32.GPIO_Alternate_Function;
      PWM_Output           : GPIO_Point;
      PWM_Output_Channel   : Timer_Channel;
      Polarity1            : GPIO_Point;
      Polarity2            : GPIO_Point) is
   begin
      --  First set up the PWM for the motors' power control.
      --  We do this configuration here because we are not sharing the timer
      --  across other PWM generation clients
      Configure_PWM_Timer (PWM_Timer, PWM_Output_Frequency);

      This.Power_Plant.Attach_PWM_Channel (PWM_Timer,  PWM_Output_Channel,
                                           PWM_Output, PWM_AF);
      This.Power_Plant.Enable_Output;
      This.Power_Channel := PWM_Output_Channel;

      --  Now set up the motor encoder
      --  Initialize_Encoder (This.Encoder, Encoder_Input1, Encoder_Input2,
      --                    Encoder_Timer, Encoder_AF);
      --  Reset_Count (This.Encoder);

      --  Finally, configure the output points for controlling the H-Bridge
      --  circuits that control the rotation direction as well as stopping
      --  the rotation entirely (via procedure Stop)
      This.H_Bridge1 := Polarity1;
      This.H_Bridge2 := Polarity2;

      Enable_Clock (Point => This.H_Bridge1);
      Enable_Clock (Point => This.H_Bridge2);

      Configure_Polarity_Control (This.H_Bridge1);
      Configure_Polarity_Control (This.H_Bridge2);
   end Initialize;
   --------------------------------
   -- Configure_Polarity_Control --
   --------------------------------
   procedure Configure_Polarity_Control (This : GPIO_Point) is
      Config : GPIO_Port_Configuration;
   begin
      Config := (Mode           => Mode_Out,
                 Output_Type    => Push_Pull,
                 Resistors      => Floating,
                 Speed          => Speed_100MHz);
      This.Configure_IO (Config => Config);
      This.Lock;      -- Lock the current configuration of Pin until reset.
   end Configure_Polarity_Control;
begin
   null;
end Engine;
