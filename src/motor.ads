---------------------------------------------------------------
--  This package provides interface for physical 12V DC motor, 
--  allowing client to control it.
---------------------------------------------------------------

with Beta_Types;
with Midero;            use Midero;

with STM32;
with STM32.Device;
with STM32.GPIO;
with STM32.PWM;
with STM32.Timers;

package Motor is   
   use STM32.Device;
   use STM32.GPIO;
   use STM32.Timers;
   use STM32.PWM;
   
   package BT renames Beta_Types;

   type Basic_Motor is tagged limited private;
   ---------------------
   -- Motor Utilities --
   ---------------------
   procedure Initialize 
     (This                 : out Basic_Motor;
      PWM_Timer            : not null access Timer;
      PWM_Output_Frequency : BT.UInt32; -- in Hertz
      PWM_AF               : STM32.GPIO_Alternate_Function;
      PWM_Output           : GPIO_Point;
      PWM_Output_Channel   : Timer_Channel;
      --  discrete outputs to H-Bridge that control direction and stopping
      Polarity1            : GPIO_Point;
      Polarity2            : GPIO_Point);
   procedure Engage         (This : out Basic_Motor; State : Boolean);
   procedure Set_Power      (Intensity : Power_Level);
   procedure Set_Direction  (External_Direction : Direction);
private
   type Basic_Motor is tagged limited 
      record
         Power_Plant       : PWM_Modulator;
         Power_Channel     : Timer_Channel;
         H_Bridge1         : GPIO_Point;
         H_Bridge2         : GPIO_Point;
   end record;
end Motor;
