pragma Ada_2012;
package body Analog_Sensor_Utils is

   -------------------------
   -- Get_Average_Reading --
   -------------------------

   procedure Get_Average_Reading
     (Sensor     : in out Analog_Sensor_T'Class;
      Interval   : Time_Span;
      Result     : out Integer;
      Successful : out Boolean)
   is
      Deadline : constant Time := Clock + Interval;
      Reading  : Integer;
      Total    : Integer := 0;
      Count    : Integer := 0;
   begin
      while Clock <= Deadline loop
         Get_Raw_Reading (Sensor, Reading, Successful);
         if not Successful then
            Result := 0;
         end if;
         --  Reading is in range 0 .. ADC_Conversion_Max_Value, (0 .. 1023)
         Total := Total + Reading;
         Count := Count + 1;
      end loop;
      Result := Total / Count;

   end Get_Average_Reading;

end Analog_Sensor_Utils;
