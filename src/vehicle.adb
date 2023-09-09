with Ada.Real_Time;                  use Ada.Real_Time;
with LCD_Std_Out;                    use LCD_Std_Out;

with STM32.ADC;                   
with STM32.Device;

with Analog_Sensor_Calibration_LCD;
with Global_Initialization;
with Midero.Hardware_Configuration;

with Panic;

package body Vehicle is
   Period : constant Time_Span := Milliseconds 
     (System_Configuration.Engine_Monitor_Period);
   
   Current_Distance : Centimeters := 0;
   
   procedure Initialize_Motors (M1, M2, M3, M4 : in out Motor);
   --  Initializes the fours motors. This must be done before any software
   --  commands or accesses to those motors.
   
   procedure Initialize_Sonar (Sensor : in out SharpIR)
     with
       Post => Enabled (Sensor);
   --  Initializes the Sonar on the vehicle. This must be done before any 
   --  software commands or accesses to the sensor.
   
   procedure Set_Up_ADC_General_Settings;
   --  Does ADC general setup for al ADC units.
   
   --------------
   -- Distance --
   --------------
   function Distance return Centimeters is
   begin
      return Current_Distance;
   end Distance;
   
   ---------------------
   -- Engine_Monitor ---
   ---------------------
   task body Engine_Monitor is
      Next_Release  : Time;
      IO_Successful : Boolean;
   begin
      Global_Initialization.Critical_Instant.Wait (Epoch => Next_Release);
      Clear_Screen;
      loop
         Vehicle.Test_Engage;
         Next_Release := Next_Release + Period;
         delay until Next_Release;
      end loop;
   end Engine_Monitor;
   -----------------
   -- Test_Engage --
   -----------------
   procedure Test_Engage is
      Dir   : constant Directions := Forward;
      Power : constant Power_Level := 50;
   begin
      Motor_Bottom_Left.Engage (Direction  => Dir,
                                Power      => Power);
      Motor_Bottom_Right.Engage (Direction => Dir,
                                 Power     => Power);
      Motor_Top_Left.Engage (Direction  => Dir,
                             Power      => Power);
      Motor_Top_Right.Engage (Direction => Dir,
                              Power     => Power);
   end Test_Engage;
   
   ---------------
   -- Test_Stop --
   ---------------
   
   procedure Test_Stop is
   begin
      Motor_Bottom_Left.Stop;
      Motor_Bottom_Right.Stop;
      Motor_Top_Left.Stop;
      Motor_Top_Right.Stop;
   end Test_Stop;
   
   ---------------------------------
   -- Set_Up_ADC_General_Settings --
   ---------------------------------

   procedure Set_Up_ADC_General_Settings is
      use STM32.ADC;
      use STM32.Device;
   begin
      Reset_All_ADC_Units;
      Configure_Common_Properties
        (Mode           => Independent,
         Prescalar      => PCLK2_Div_2,
         DMA_Mode       => Disabled,  -- this is multi-dma mode
         Sampling_Delay => Sampling_Delay_5_Cycles);
   end Set_Up_ADC_General_Settings;
   
   -----------------------
   -- Initialize_Motors --
   -----------------------
   
   procedure Initialize_Motors (M1, M2, M3, M4 : in out Motor) is
      use Midero.Hardware_Configuration;
   begin
      --  Motor Bottom Right
      M1.Initialize (Encoder_Input1       => Motor1_Encoder_Input1,
                     Encoder_Input2       => Motor1_Encoder_Input2,
                     Encoder_Timer        => Motor1_Encoder_Timer,
                     Encoder_AF           => Motor1_Encoder_AF,
                     PWM_Timer            => Motor1_PWM_Engine_TMR,
                     PWM_Output_Frequency => Motor_PWM_Freq,
                     PWM_AF               => Motor1_PWM_Output_AF,
                     PWM_Output           => Motor1_PWM_Engine,
                     PWM_Output_Channel   => Motor1_PWM_Channel,
                     Polarity1            => Motor1_Polarity1,
                     Polarity2            => Motor1_Polarity2);
      -- Motor Bottom Left  
      M2.Initialize (Encoder_Input1       => Motor2_Encoder_Input1,
                     Encoder_Input2       => Motor2_Encoder_Input2,
                     Encoder_Timer        => Motor2_Encoder_Timer,
                     Encoder_AF           => Motor2_Encoder_AF,
                     PWM_Timer            => Motor2_PWM_Engine_TMR,
                     PWM_Output_Frequency => Motor_PWM_Freq,
                     PWM_AF               => Motor2_PWM_Output_AF,
                     PWM_Output           => Motor2_PWM_Engine,
                     PWM_Output_Channel   => Motor2_PWM_Channel,
                     Polarity1            => Motor2_Polarity1,
                     Polarity2            => Motor2_Polarity2);
      --  Motor Top Left
      M3.Initialize (Encoder_Input1       => Motor3_Encoder_Input1,
                     Encoder_Input2       => Motor3_Encoder_Input2,
                     Encoder_Timer        => Motor3_Encoder_Timer,
                     Encoder_AF           => Motor3_Encoder_AF,
                     PWM_Timer            => Motor3_PWM_Engine_TMR,
                     PWM_Output_Frequency => Motor_PWM_Freq,
                     PWM_AF               => Motor3_PWM_Output_AF,
                     PWM_Output           => Motor3_PWM_Engine,
                     PWM_Output_Channel   => Motor3_PWM_Channel,
                     Polarity1            => Motor3_Polarity1,
                     Polarity2            => Motor3_Polarity2);
      --  Motor Top Right
      M4.Initialize (Encoder_Input1       => Motor4_Encoder_Input1,
                     Encoder_Input2       => Motor4_Encoder_Input2,
                     Encoder_Timer        => Motor4_Encoder_Timer,
                     Encoder_AF           => Motor4_Encoder_AF,
                     PWM_Timer            => Motor4_PWM_Engine_TMR,
                     PWM_Output_Frequency => Motor_PWM_Freq,
                     PWM_AF               => Motor4_PWM_Output_AF,
                     PWM_Output           => Motor4_PWM_Engine,
                     PWM_Output_Channel   => Motor4_PWM_Channel,
                     Polarity1            => Motor4_Polarity1,
                     Polarity2            => Motor4_Polarity2);
   end Initialize_Motors;
   
   ----------------------
   -- Initialize_Sonar --
   ----------------------
   
   procedure Initialize_Sonar (Sensor : in out SharpIR) is
      use Midero.Hardware_Configuration;
      use Analog_Sensor_Calibration_LCD;
      
      Successful : Boolean := False;
   begin
      Set_Up_ADC_General_Settings;
      Sensor.Assign_ADC (Selected_ADC_Unit'Access,
                        Input_Channel => Selected_Input_Channel,
                        Input_Pin     => Input_Pin);
      Sensor.Initialize;
      --  Calibrate_Analog_Sensor (Sensor            => Sensor,
      --                           Sampling_Interval => Seconds (2),
      --                           Successful        => Successful);
      --  if not Successful then
      --     Panic;
      --  end if;
   end Initialize_Sonar;
   
   ----------------
   -- Initialize --
   ----------------
   procedure Initialize is
   begin
      Initialize_Motors (M1 => Motor_Bottom_Right, M2 => Motor_Bottom_Left,
                         M3 => Motor_Top_Left,     M4 => Motor_Top_Right);
      Initialize_Sonar (Sonar);
   end Initialize;
   
end Vehicle;