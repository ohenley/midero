pragma Ada_2012;
with LCD_Std_Out;            use LCD_Std_Out;
with Analog_Sensor_Type;     use Analog_Sensor_Type;
with Vehicle;

package body Collision_Detection is

   function Exclusion_Zone_Violated
     (Sonar_Reading : Centimeters) return Boolean
        with Inline;

   -----------
   -- Check --
   -----------

   procedure Check
     (Collision_Imminent : out Boolean)
   is
      Reading       : Centimeters;
   begin
      Collision_Imminent := False;  --  Default
      Reading := Centimeters (Vehicle.Get_Measured_Distance);
      Collision_Imminent := Exclusion_Zone_Violated (Reading);
   end Check;

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
