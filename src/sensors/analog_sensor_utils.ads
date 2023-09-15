--------------------------------------------------------------
--  This package provides some utility routines for working
--  with analog senors.

with Analog_Sensor_Type;     use Analog_Sensor_Type;
with Ada.Real_Time;          use Ada.Real_Time;

package Analog_Sensor_Utils is

   procedure Get_Average_Reading
     (Sensor     : in out Analog_Sensor_T'Class;
      Interval   : Time_Span;
      Result     : out Integer;
      Successful : out Boolean);
   --  Return the average of the raw, inversely varying sensed input values
   --  acquired via Get_Raw_Reading (Sensor) during the sampling interval.
   --  If any call to Get_Raw_Reading fails to acquire a value from the ADC
   --  Result is 0 and Successful is False.
end Analog_Sensor_Utils;
