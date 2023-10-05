with Ada.Real_Time;                  use Ada.Real_Time;

with Global_Initialization;
with Hardware_Configuration;         use Hardware_Configuration;
with Sonar;

package body Vehicle is

   Period : constant Time_Span := 
     Milliseconds (System_Configuration.Vehicle_Period);
   
   Exclusion_Zone : constant Integer := 10;
   Limited_Zone  : constant Integer := 70;
   ----------------
   -- Controller --
   ----------------
   task body Controller is
      Next_Release : Time;
   begin
      Global_Initialization.Critical_Instant.Wait (Epoch => Next_Release);
      loop
         Next_Release := Next_Release + Period;
         if Sonar.Measure_Distance < Exclusion_Zone then
            Motor_Top_Left.Engage (False);
            Motor_Top_Right.Engage (False);
            Motor_Bottom_Left.Engage (False);
            Motor_Bottom_Right.Engage (False);
         elsif Sonar.Measure_Distance > Exclusion_Zone then
            Motor_Top_Left.Engage (True);
            Motor_Top_Right.Engage (True);
            Motor_Bottom_Left.Engage (True);
            Motor_Bottom_Right.Engage (True);
         end if;

         delay until Next_Release;
      end loop;
   end Controller;
   
   procedure Initialize_Motors (M1, M2, M3, M4 : in out Basic_Motor);
   --  Initializes the fours motors. This must be done before any software
   --  commands or accesses to those motors.
   
   -----------------------
   -- Initialize_Motors --
   -----------------------
   procedure Initialize_Motors (M1, M2, M3, M4 : in out Basic_Motor) is
   begin
      --  Motor Bottom Right
      M1.Initialize 
        (PWM_Timer            => Motor1_PWM_Engine_TMR,
         PWM_Output_Frequency => Motor_PWM_Freq,
         PWM_AF               => Motor1_PWM_Output_AF,
         PWM_Output           => Motor1_PWM_Engine,
         PWM_Output_Channel   => Motor1_PWM_Channel,
         Polarity1            => Motor1_Polarity1,
         Polarity2            => Motor1_Polarity2);
      -- Motor Bottom Left  
      M2.Initialize 
        (PWM_Timer            => Motor2_PWM_Engine_TMR,
         PWM_Output_Frequency => Motor_PWM_Freq,
         PWM_AF               => Motor2_PWM_Output_AF,
         PWM_Output           => Motor2_PWM_Engine,
         PWM_Output_Channel   => Motor2_PWM_Channel,
         Polarity1            => Motor2_Polarity1,
         Polarity2            => Motor2_Polarity2);
      --  Motor Top Left
      M3.Initialize 
        (PWM_Timer            => Motor3_PWM_Engine_TMR,
         PWM_Output_Frequency => Motor_PWM_Freq,
         PWM_AF               => Motor3_PWM_Output_AF,
         PWM_Output           => Motor3_PWM_Engine,
         PWM_Output_Channel   => Motor3_PWM_Channel,
         Polarity1            => Motor3_Polarity1,
         Polarity2            => Motor3_Polarity2);
      --  Motor Top Right
      M4.Initialize 
        (PWM_Timer            => Motor4_PWM_Engine_TMR,
         PWM_Output_Frequency => Motor_PWM_Freq,
         PWM_AF               => Motor4_PWM_Output_AF,
         PWM_Output           => Motor4_PWM_Engine,
         PWM_Output_Channel   => Motor4_PWM_Channel,
         Polarity1            => Motor4_Polarity1,
         Polarity2            => Motor4_Polarity2);
   end Initialize_Motors;
   ----------------
   -- Initialize --
   ----------------
   procedure Initialize is
   begin
      Initialize_Motors (M1 => Motor_Bottom_Right, M2 => Motor_Bottom_Left,
                         M3 => Motor_Top_Left,     M4 => Motor_Top_Right);
   end Initialize;
end Vehicle;
