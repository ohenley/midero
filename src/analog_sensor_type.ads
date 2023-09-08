------------------------------------------------------------------------------

--  This package provides an abstract base-class for analog sensors, such
--  as the sound and light sensors. An an analog sensor, it uses an ADC to
--  convert the current reading into a value.

--  Note that you must have an external pull-up resistor tied to +5V on the
--  analog input pin. A 10K resistor works well.

with STM32.ADC;               use STM32.ADC;
with STM32.GPIO;              use STM32.GPIO;

with Math_Utilities;

package Analog_Sensor_Type is

   type Analog_Sensor_T is abstract tagged limited private;
   --  The root abstract baseclass type for analog sensors

   procedure Assign_ADC
     (This : in out Analog_Sensor_T;
      Converter : access Analog_To_Digital_Converter;
      Input_Channel : Analog_Input_Channel;
      Input_Pin : GPIO_Point);

   procedure Initialize (This : in out Analog_Sensor_T);
   --  Initialize the input port/pin and the basics for the ADC itself, such
   --  as the resolution and alignment, but does not do anything else bc
   --  that will vary with the subclasses.

   subtype Varying_Directly is Natural;
   --  The raw values coming from the sensor vary inversely with the sensed
   --  input.

   subtype Intensity is Varying_Directly range 0 .. 100;
   --  Sensed values presented as a percentage of the possible Input range

   procedure Get_Intensity
     (This       : in out Analog_Sensor_T;
      Reading    : out Intensity;
      Successful : out Boolean)
   with Pre'Class => Enabled (This);
   --  Calls the Get_Raw_Reading function to get the ADC sample from
   --  This.Converter on This.Input_Channel (which is connected to
   --  This.Input_Pin) and returns that value as a percentage of the possible
   --  conversion range.
   --
   --  The returned percentage values vary directly with the magnitude of the
   --  sensed inputs.

   type Centimeters is range 0 .. 400;

   GP2Y0A41SK0F_Nothing_Detected : constant Centimeters := 31;
   GP2Y0A21YK0F_Nothing_Detected : constant Centimeters := 81;
   GP2Y0A02YK0F_Nothing_Detected : constant Centimeters := 151;

   --  Everything is working as expected but nothin is currently detected.

   procedure Get_Raw_Reading
     (This       : in out Analog_Sensor_T;
      Reading    : out Natural;
      Successful : out Boolean)
   is abstract
   with Pre'Class => Enabled (This);
   --  Interacts with the ADC indicated by This.Converter to acquire a raw
   --  sample on This.Input_Channel (which is connected to This.Input_Pin)
   --  and returns that raw value in the Reading parameter. The parameter
   --  Successful indicates whether the raw value acquisition succeeded.
   --
   --  NB: Raw values vary inversely with the brightness of the sensed light.
   --  This function does nothing to change that and simply returns the raw
   --  value sensed bythe ADC.

   procedure Enable (This : in out Analog_Sensor_T) with
     Post'Class => Enabled (This);

   procedure Disable (This : in out Analog_Sensor_T) with
     Post'Class => not Enabled (This);

   function Enabled (This : Analog_Sensor_T) return Boolean;

   --  Manual calibration  ----------------------------------------------------

   type Sensor_Calibration is record
      Least, Greatest : Varying_Directly;
   end record;

   procedure Set_Calibration
     (This     : in out Analog_Sensor_T;
      Least    : Varying_Directly;
      Greatest : Varying_Directly)
   with Pre => Least < Greatest;
   --  Set the values corresponding to the least and greatest sensed input
   --  values acquired from this ADC, e.g., darkest and brightest sensed light.
   --  The specified values vary directly with the sensed input, as opposed to
   --  those values read immediately from the sensor.

   function Calibration (This : Analog_Sensor_T) return Sensor_Calibration;
   --  Returns the values corresponding to the least and greatestest sensed
   --  inputs from the ADC. The values vary directly with the incoming sensed
   --  values.
   --
   --  NB: The returned value can be passed to Set_Calibration without any
   --  changes by the client.

   --  Utility functions  ---------------------------------------------------

   function ADC_Conversion_Max_Value return Positive;
   --  Returns the maximum value the ADC unit can provide at the device's
   --  selected resolution.

   function As_Varying_Directly (Inverse_Value : Integer) return Integer
     with Inline;
   --  The raw values coming from the sensor vary inversely with the sensed
   --  input, i.e., "higher" inputs such as brighter light correspond to
   --  numerically lower raw values. This function translates the given value,
   --  presumably one that varies inversely with the sensed input, into a value
   --  that varies directly with the sensed input. This can be useful for
   --  passing values to the Set_Calibration routine above, for example.

private

   Sensor_ADC_Resolution : constant ADC_Resolution := ADC_Resolution_10_Bits;

   Max_For_Resolution : constant Integer :=
     (case Sensor_ADC_Resolution is
          when ADC_Resolution_12_Bits => 4095,
          when ADC_Resolution_10_Bits => 1023,
          when ADC_Resolution_8_Bits  => 255,
          when ADC_Resolution_6_Bits  => 63);

   type Analog_Sensor_T is abstract tagged limited record
      Converter     : access Analog_To_Digital_Converter;
      Input_Channel : Analog_Input_Channel;
      Input_Pin     : GPIO_Point;
      High          : Varying_Directly := Max_For_Resolution;
      Low           : Varying_Directly := 0;
   end record;
   --  This is an analog device abstraction so the underlying device is an
   --  analog-to-digital converter (ADC). Therefore, the components for
   --  the sensor object are those required for ADC use.

   function Mapped is new Math_Utilities.Range_To_Domain_Mapping (Integer);
   --  Mapps a given value from the given range to the given domain. Used to
   --  scale a raw input value in the range Low .. High to the percentage value
   --  0 .. 100.

   function Constrained is new Math_Utilities.Bounded_Integer_Value (Integer);
   --  Ensures a given value is at least the value of a given low bound, and at
   --  most the value of a given high bound. Used to make sure the given value
   --  is within the range of Intensity, the percentage 0 .. 100.

   function Regular_Conversion (Channel : Analog_Input_Channel)
     return Regular_Channel_Conversions is
     (1 => (Channel, Sample_Time => Sample_144_Cycles));
   --  A convenience function for creating a regular channel conversion list
   --  for the given channel. Used by subclasses within this package hierarchy.

   function ADC_Conversion_Max_Value return Positive is
      (Max_For_Resolution);

   function As_Varying_Directly (Inverse_Value : Integer) return Integer is
      (Max_For_Resolution - Inverse_Value);

end Analog_Sensor_Type;
