------------------------------------------------------------------------------

--  This package provides an interactive analog sensor calibration routine that
--  works with any NXT analog sensor (hence the use of NXT_Analog_Sensor'Class
--  in the formal parameter).

--  NB: this package implementation uses the LCD_Std_Out package and the blue
--  user button. Not all STM32F4xxx Discovery boards have an LCD. Moreover, the
--  STM32F4 Disco board used for some demos has the blue user button disabled
--  by removing a solder bridge.

with Analog_Sensor_Type;         use Analog_Sensor_Type;
with Ada.Real_Time;              use Ada.Real_Time;

package Analog_Sensor_Calibration_LCD is

   procedure Calibrate_Analog_Sensor
     (Sensor            : in out Analog_Sensor_T'Class;
      Sampling_Interval : Time_Span;
      Successful        : in out Boolean)
     with
       Pre => Enabled (Sensor);
private
   DeadLine : Time := Time_First;

end Analog_Sensor_Calibration_LCD;
