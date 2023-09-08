pragma Ada_2012;
with LCD_Std_Out;            use LCD_Std_Out;
with Analog_Sensor_Type;     use Analog_Sensor_Type;

package body Collision_Detection is

   function Moving_Forward
     (Current_Direction : Remote_Control.Travel_Directions;
      Current_Power     : Remote_Control.Percentage)
      return Boolean
     with Inline;

   function Exclusion_Zone_Violated
     (Sonar_Reading : Centimeters) return Boolean
        with Inline;

   -----------
   -- Check --
   -----------

   procedure Check
     (Current_Direction  : Remote_Control.Travel_Directions;
      Current_Power      : Remote_Control.Percentage;
      Collision_Imminent : out Boolean)
   is
      Reading       : Centimeters;
      IO_Successful : Boolean := True;
   begin
      Collision_Imminent := False;  --  Default
      if Moving_Forward (Current_Direction, Current_Power) then
         Vehicle.Sonar.Get_Distance (Reading       => Reading,
                                   IO_Successful => IO_Successful);
         if not IO_Successful then
            return;
         else
            Collision_Imminent := Exclusion_Zone_Violated (Reading);
         end if;
      end if;
   end Check;

   --------------------
   -- Moving_Forward --
   --------------------

   function Moving_Forward
     (Current_Direction : Remote_Control.Travel_Directions;
      Current_Power     : Remote_Control.Percentage)
      return Boolean
   is
      use Remote_Control;
   begin
      return Current_Direction = Forward and Current_Power > 0;
   end Moving_Forward;

   -----------------------------
   -- Exclusion_Zone_Violated --
   -----------------------------

   function Exclusion_Zone_Violated
     (Sonar_Reading : Centimeters) return Boolean
   is
      Min_Distance : constant Analog_Sensor_Type.Centimeters
        := 15 + Vehicle.Sonar_Offset_From_Front;
      --  The minimum value read from the sensor indicating an obastacle
      --  ahead that will require us to stop to avoid a collision.
   begin
      if Sonar_Reading = Analog_Sensor_Type.GP2Y0A21YK0F_Nothing_Detected then
         return False;
      else
         return Sonar_Reading <= Min_Distance;
      end if;
   end Exclusion_Zone_Violated;

end Collision_Detection;
