with STM32.Device;         use STM32.Device;

package Analog_Sensor_Type.Polling is

   type SharpIRSensor is (GP2Y0A41SK0F, GP2Y0A21YK0F, GP2Y0A02YK0F);
   --  The acquisition of distance data from Sharp IR Sensors depends on
   --  the sensor type

   type SharpIR (Kind : SharpIRSensor) is
     new Analog_Sensor_T with private;

   overriding
   procedure Initialize (This : in out SharpIR)
     with Post => Enabled (This);

   overriding
   procedure Get_Raw_Reading
     (This : in out SharpIR;
      Reading : out Natural;
      Successful : out Boolean);
   --  This version initiates an ADC conversion and then polls for completion.
   --  if the conversion times out, Reading is zero and Successful is False.
   --  The timeout is set to one second.

   procedure Get_Distance
     (This          : in out SharpIR;
      Reading       : out Centimeters;
      IO_Successful : out Boolean);

private

   type SharpIRNumerator is range 2076 .. 9462;

   type SharpIR (Kind : SharpIRSensor) is
     new Analog_Sensor_T with record
      Distance : Centimeters;
      case Kind is
         when GP2Y0A41SK0F =>
            GP2Y0A41_Num : SharpIRNumerator := 2076;
            GP2Y0A41_Offset : Natural := 11;
         when GP2Y0A21YK0F =>
            GP2Y0A21_Num : SharpIRNumerator := 4800;
            GP2Y0A21_Offset : Natural := 20;
         when GP2Y0A02YK0F =>
            GP2Y0A02_Num : SharpIRNumerator := 9462;
            GP2Y0A02_Offset : Natural := 17;
      end case;
   end record;

end Analog_Sensor_Type.Polling;
