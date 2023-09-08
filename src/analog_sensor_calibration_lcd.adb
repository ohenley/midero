pragma Ada_2012;

with LCD_Std_Out;              use LCD_Std_Out;

with Analog_Sensor_Utils;      use Analog_Sensor_Utils;

package body Analog_Sensor_Calibration_LCD is

   procedure AvoidBurstRead;
   --  wait for sensor's sampling time

   --------------------
   -- AvoidBurstRead --
   --------------------

   procedure AvoidBurstRead is
      Period  : constant Time_Span := Milliseconds (100);
   begin
      loop
         exit when Clock >= DeadLine + Period;
      end loop;
      DeadLine := Clock;
   end AvoidBurstRead;

   -----------------------------
   -- Calibrate_Analog_Sensor --
   -----------------------------

   procedure Calibrate_Analog_Sensor
     (Sensor            : in out Analog_Sensor_T'Class;
      Sampling_Interval : Time_Span;
      Successful        : in out Boolean)
   is
      Low_Bound  : Integer;
      High_Bound : Integer;
   begin
      Clear_Screen;

      Put_Line ("--Min levels--");
      AvoidBurstRead;
      Put_Line ("Sampling ...");
      Get_Average_Reading (Sensor, Sampling_Interval, Low_Bound, Successful);

      if not Successful then
         Put_Line ("Read failed");
         return;
      end if;

      Put_Line ("--Max levels--");
      AvoidBurstRead;
      Put_Line ("Sampling...");
      Get_Average_Reading (Sensor, Sampling_Interval, High_Bound, Successful);

      if not Successful then
         Put_Line ("Read failed");
         return;
      end if;

      Low_Bound  := As_Varying_Directly (Low_Bound);
      High_Bound := As_Varying_Directly (High_Bound);

      Put_Line ("--Results--");
      Put_Line ("Min:"  & Low_Bound'Img);
      Put_Line ("Max:"  & High_Bound'Img);

      if Low_Bound = High_Bound then
         Put_Line ("Min = Max!");
         Successful := False;
         return;
      end if;

      if Low_Bound > High_Bound then
         Put_Line ("Min > Max!!");
         Successful := False;
         return;
      end if;

      Sensor.Set_Calibration (Least    => Low_Bound,
                              Greatest => High_Bound);
      AvoidBurstRead;

   end Calibrate_Analog_Sensor;

end Analog_Sensor_Calibration_LCD;
