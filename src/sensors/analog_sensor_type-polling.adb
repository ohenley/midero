pragma Ada_2012;

with Ada.Real_Time;    use Ada.Real_Time;
with Panic;

package body Analog_Sensor_Type.Polling is

   ----------------
   -- Initialize --
   ----------------

   overriding procedure Initialize (This : in out SharpIR) is
   begin
      Initialize (Analog_Sensor_T (This));
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

   overriding procedure Get_Raw_Reading
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

   ------------------
   -- Get_Distance --
   ------------------

   procedure Get_Distance
     (This          : in out SharpIR;
      Reading       : out Centimeters;
      IO_Successful : out Boolean)
   is
      Direct_Reading : Natural;
      ADC_Successful : Boolean;
   begin

      This.Get_Raw_Reading (Direct_Reading, ADC_Successful);
      --  Call ADC to get readings from Sharp IR sensor

      if not ADC_Successful then
         Panic;
         Reading := 0;
         IO_Successful := False;
      end if;

      --  Because of polymorphism of This, we check the kind of sensor
      --  before computing This.Distance
      case This.Kind is
         when GP2Y0A41SK0F =>
            Reading :=
              Centimeters (Natural (This.GP2Y0A41_Num) /
                           (Direct_Reading - This.GP2Y0A41_Offset));
         when GP2Y0A21YK0F =>
            Reading :=
              Centimeters (Natural (This.GP2Y0A21_Num) /
                           (Direct_Reading - This.GP2Y0A21_Offset));
         when GP2Y0A02YK0F =>
            Reading :=
              Centimeters (Natural (This.GP2Y0A02_Num) /
                           (Direct_Reading - This.GP2Y0A02_Offset));
      end case;

      --  Once This.Distance is computed then we bound it.
      case This.Kind is

         when GP2Y0A41SK0F =>
            if Reading >= 30 then
               Reading := Analog_Sensor_Type.GP2Y0A41SK0F_Nothing_Detected;
            elsif Reading <= 4 then
               Reading := 3;
            end if;

         when GP2Y0A21YK0F =>
            if Reading >= 80 then
               Reading := Analog_Sensor_Type.GP2Y0A21YK0F_Nothing_Detected;
            elsif Reading <= 10 then
               Reading := 9;
            end if;

         when GP2Y0A02YK0F =>
            if Reading >= 150 then
               Reading := Analog_Sensor_Type.GP2Y0A41SK0F_Nothing_Detected;
            elsif Reading <= 20 then
               Reading := 19;
            end if;
      end case;

      --  Reading := This.Distance;
      IO_Successful := True;
   end Get_Distance;

end Analog_Sensor_Type.Polling;
