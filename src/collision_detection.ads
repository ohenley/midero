with Remote_Control;
with Vehicle;
with Analog_Sensor_Type.Polling;

package Collision_Detection is

   pragma Unevaluated_Use_Of_Old (Allow);

   procedure Check
     (Current_Direction  : Remote_Control.Travel_Directions;
      Current_Power      : Remote_Control.Percentage;
      Collision_Imminent : out Boolean)
     with
       Pre => Vehicle.Sonar.Enabled;

end Collision_Detection;
