--------------------------------------------------------------------------
--  This package provides some utility routines for working
--  with analog sensor. Sharp IR sensor add obstacle avoidance to 
--  the robot. GPY0A21YKOF Sharp sensor provide accurate distance 
--  measurements. This particular Sharp sensor will detect distances 
--  in a range of 9 -81 cm.
--  The GPY0A21YKOF uses a 3-pin JST PH connector that works with 
--  our 3-pin JST PH cables for Sharp distance sensors.
--------------------------------------------------------------------------

with STM32.Device;         use STM32.Device;
with STM32.ADC;            use STM32.ADC;
with STM32.GPIO;           use STM32.GPIO;

package Sonar is

   pragma Elaborate_Body;
   
   type SharpIRSensor is (GP2Y0A41SK0F, GP2Y0A21YK0F, GP2Y0A02YK0F);
   --  The acquisition of distance data from Sharp IR Sensors depends on
   --  the sensor type
   
   type SharpIR (Kind : SharpIRSensor) is tagged private;

   procedure Initialize (This : in out SharpIR);
   --  Initialize the input port/pin and the basics for the ADC itself, such
   --  as the resolution and alignment, but does not do anything else bc
   --  that will vary with the subclasses.
   
   procedure Get_Raw_Reading
     (This : in out SharpIR;
      Reading : out Natural;
      Successful : out Boolean);
   --  This version initiates an ADC conversion and then polls for completion.
   --  if the conversion times out, Reading is zero and Successful is False.
   --  The timeout is set to one second.
   
   type Centimeters is range 0 .. 400;
   
   GP2Y0A41SK0F_Nothing_Detected : constant Integer := 31;
   GP2Y0A21YK0F_Nothing_Detected : constant Integer := 81;
   GP2Y0A02YK0F_Nothing_Detected : constant Integer := 151;
   
   
   procedure Do_Reading_On_ADC
     (This          : in out SharpIR;
      Reading       : out Integer;
      IO_Successful : out Boolean);
   
   function Measure_Distance return Integer;

private
   
   Sensor_ADC_Resolution : constant ADC_Resolution := ADC_Resolution_10_Bits;

   Max_For_Resolution : constant Integer :=
     (case Sensor_ADC_Resolution is
         when ADC_Resolution_12_Bits => 4095,
         when ADC_Resolution_10_Bits => 1023,
         when ADC_Resolution_8_Bits  => 255,
         when ADC_Resolution_6_Bits  => 63);
   
   type SharpIRNumerator is range 2076 .. 9462;

   type SharpIR (Kind : SharpIRSensor) is tagged record
      Converter     : access Analog_To_Digital_Converter;
      Input_Channel : Analog_Input_Channel;
      Input_Pin     : GPIO_Point;
      High          : Natural := Max_For_Resolution;
      Low           : Natural := 0;
      Distance      : Integer;
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
   
   function Regular_Conversion (Channel : Analog_Input_Channel)
                                return Regular_Channel_Conversions is
     (1 => (Channel, Sample_Time => Sample_144_Cycles));

end Sonar;
