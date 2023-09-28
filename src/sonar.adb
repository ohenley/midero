pragma Ada_2012;

with Ada.Real_Time;             use Ada.Real_Time;
--with LCD_Std_Out;               use LCD_Std_Out;
with Hardware_Configuration;    use Hardware_Configuration;
with Global_Initialization;
with System_Configuration;


package body Sonar is
   
   Period : constant Time_Span := 
     Milliseconds (System_Configuration.Sonar_Period);
   
   Sensor : SharpIR (GP2Y0A21YK0F);
   
   procedure Set_Up_ADC_General_Settings;
   --  Does ADC general setup for al ADC units.

   protected Critical_Sonar is
      procedure Set_Distance (Reading : Integer);
      procedure Get_Distance (Reading : out Integer);
   private
      Distance : Integer;
   end Critical_Sonar;
   ------------------------------
   -- Protected Critical_Sonar --
   ------------------------------
   
   protected body Critical_Sonar is
      -------------------
      -- Set_Distance --
      ------------------
      procedure Set_Distance (Reading : Integer) is
      begin
         Distance := Reading;
      end Set_Distance;
      ------------------
      -- Get_Distance --
      ------------------
      procedure Get_Distance (Reading : out Integer) is
      begin
         Reading := Distance;
      end Get_Distance;
   end Critical_Sonar;
   
   -----------------
   -- Controller --
   ----------------
   task Controller with
     Priority => System_Configuration.Sonar_Priority;
   
   task body Controller is
      Next_Release : Time;
      Reading      : Integer;
      Successful   : Boolean;
   begin
      Global_Initialization.Critical_Instant.Wait (Epoch => Next_Release);
      loop
         Next_Release := Next_Release + Period;
         delay until Next_Release;
         
         Sensor.Do_Reading_On_ADC (Reading       => Reading,
                                   IO_Successful => Successful);
         if Successful then
            Critical_Sonar.Set_Distance (Reading => Reading);
            --Clear_Screen;
            --Put_Line("Dist= " & Reading'Img & "cm");
         else
            Critical_Sonar.Set_Distance (Reading => 0);
         end if;
      end loop;
   end Controller;
   
   ----------------
   -- Assign_ADC --
   ----------------
   procedure Assign_ADC
     (This          : in out SharpIR;
      Converter     : access Analog_To_Digital_Converter;
      Input_Channel : Analog_Input_Channel;
      Input_Pin     : GPIO_Point);

   procedure Assign_ADC
     (This          : in out SharpIR;
      Converter     : access Analog_To_Digital_Converter;
      Input_Channel : Analog_Input_Channel;
      Input_Pin     : GPIO_Point)
   is
   begin
      This.Converter     := Converter;
      This.Input_Channel := Input_Channel;
      This.Input_Pin     := Input_Pin;
   end Assign_ADC;
   ---------------------------------
   -- Set_Up_ADC_General_Settings --
   ---------------------------------

   procedure Set_Up_ADC_General_Settings is
   begin
      Reset_All_ADC_Units;
      Configure_Common_Properties
        (Mode           => Independent,
         Prescalar      => PCLK2_Div_2,
         DMA_Mode       => Disabled,  -- this is multi-dma mode
         Sampling_Delay => Sampling_Delay_5_Cycles);
   end Set_Up_ADC_General_Settings;
   ----------------
   -- Initialize --
   ----------------

   procedure Initialize (This : in out SharpIR) is
   begin
      Set_Up_ADC_General_Settings;
      Sensor.Assign_ADC (Selected_ADC_Unit'Access,
                         Input_Channel => Selected_Input_Channel,
                         Input_Pin     => Input_Pin);
      
      Enable_Clock (This.Input_Pin);
      This.Input_Pin.Configure_IO ((Mode_Analog, Resistors => Floating));

      Enable_Clock (This.Converter.all);
      Configure_Unit (This.Converter.all,
                      Resolution => Sensor_ADC_Resolution,
                      Alignment => Right_Aligned);
      
      Configure_Regular_Conversions
        (This        => This.Converter.all,
         Continuous  => False,
         Trigger     => Software_Triggered,
         Enable_EOC  => True,
         Conversions => Regular_Conversion (This.Input_Channel));
      Enable (This.Converter.all);
   end Initialize;

   ---------------------
   -- Get_Raw_Reading --
   ---------------------

   procedure Get_Raw_Reading
     (This       : in out SharpIR;
      Reading    : out Natural;
      Successful : out Boolean)
   is
   begin
      Start_Conversion (This.Converter.all);
      Poll_For_Status (This.Converter.all, Regular_Channel_Conversion_Complete,
                       Successful);
      if not Successful then
         Reading := 0;
      else
         Reading := Integer (Conversion_Value (This.Converter.all));
      end if;
   end Get_Raw_Reading;
   -----------------------
   -- Do_Reading_On_ADC --
   -----------------------

   procedure Do_Reading_On_ADC
     (This          : in out SharpIR;
      Reading       : out Integer;
      IO_Successful : out Boolean)
   is
      Direct_Reading : Natural;
      ADC_Successful : Boolean;
   begin

      This.Get_Raw_Reading (Direct_Reading, ADC_Successful);
      --  Call ADC to get readings from Sharp IR sensor

      if not ADC_Successful then
         Reading := 0;
         IO_Successful := False;
      end if;

      --  Because of polymorphism of This, we check the kind of sensor
      --  before computing This.Distance
      case This.Kind is
         when GP2Y0A41SK0F =>
            Reading :=
              (Natural (This.GP2Y0A41_Num) /
               (Direct_Reading - This.GP2Y0A41_Offset));
         when GP2Y0A21YK0F =>
            Reading :=
              (Natural (This.GP2Y0A21_Num) /
               (Direct_Reading - This.GP2Y0A21_Offset));
         when GP2Y0A02YK0F =>
            Reading :=
              (Natural (This.GP2Y0A02_Num) /
               (Direct_Reading - This.GP2Y0A02_Offset));
      end case;

      --  Once This.Distance is computed then we bound it.
      case This.Kind is

         when GP2Y0A41SK0F =>
            if Reading >= 30 then
               Reading := GP2Y0A41SK0F_Nothing_Detected;
            elsif Reading <= 4 then
               Reading := 3;
            end if;

         when GP2Y0A21YK0F =>
            if Reading >= 80 then
               Reading := GP2Y0A21YK0F_Nothing_Detected;
            elsif Reading <= 10 then
               Reading := 9;
            end if;

         when GP2Y0A02YK0F =>
            if Reading >= 150 then
               Reading := GP2Y0A41SK0F_Nothing_Detected;
            elsif Reading <= 20 then
               Reading := 19;
            end if;
      end case;

      --  Reading := This.Distance;
      IO_Successful := True;
   end Do_Reading_On_ADC;
   
   function Measure_Distance return Integer is
      Distance : Integer;
   begin
      Critical_Sonar.Get_Distance (Reading => Distance);
      return Distance;
   end Measure_Distance;
   
begin
   Sensor.Initialize;
end Sonar;
