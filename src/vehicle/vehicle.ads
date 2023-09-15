-------------------------------------------------------------------------------
--  This package represents the physical plant, ie the car itself. As such,   -
--  it contains the declarations for the four DC motors.                      -
--  The motors are used for propulsion and steering. Other physical artifacts -
--  are also provided here, such as the mapping of turning directions to motor-
--  rotation direction, the wheel size and gear ratio, and so forth.          -
--  Finally, the package provides runtime information about the car, such as  -
--  the current speed (in centimeters/sec).                                   -
-------------------------------------------------------------------------------

with Engine;
with Analog_Sensor_Type;                  use Analog_Sensor_Type;
with Analog_Sensor_Type.Polling;          use Analog_Sensor_Type.Polling;

package Vehicle is
   pragma Elaborate_Body;
   use Engine;
   
   --  Those are robot motor as physically connected
   Motor_Top_Left     : Motor;
   Motor_Top_Right    : Motor;
   Motor_Bottom_Left  : Motor;
   Motor_Bottom_Right : Motor;
   
   Sonar_Offset_From_Front : constant Centimeters := 2;
   --  The offset of the sharp IR sensor from the front of the vehicle as
   --  physically built.
   
   -----------------------
   -- Vehicle utilities --
   -----------------------
   procedure Initialize;
   procedure Test_Engage;
   procedure Test_Stop;
   function  Get_Measured_Distance return Integer;
   
end Vehicle;
