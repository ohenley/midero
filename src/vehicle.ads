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
with Remote_Control;
with System_Configuration;
with Analog_Sensor_Type;                  use Analog_Sensor_Type;
with Analog_Sensor_Type.Polling;          use Analog_Sensor_Type.Polling;

package Vehicle is
   pragma Elaborate_Body;
   use Engine;
   
   type Centimeters_Access is access all Centimeters;
   --  Those are robot motor as physically connected
   Motor_Top_Left     : Motor;
   Motor_Top_Right    : Motor;
   Motor_Bottom_Left  : Motor;
   Motor_Bottom_Right : Motor;
   
   Sonar : SharpIR (Kind => GP2Y0A21YK0F);
   --  This sensor doesn't require 10K pull up resistor. It require 5V power
   --  supply
   
   Sonar_Offset_From_Front : constant Centimeters := 2;
   --  The offset of the sharp IR sensor from the front of the vehicle as
   --  physically built.
   
   Power : Remote_Control.Percentage := 50;
   -----------------------
   -- Vehicle utilities --
   -----------------------
   procedure Initialize
     with
       Post => Enabled (Sonar);
   
   procedure Test_Engage 
     with 
       Pre => 
         (Encoder_Count (Motor_Bottom_Left) = 0 and then 
            Throttle (Motor_Bottom_Left) = 0) or else 
         (Encoder_Count (Motor_Bottom_Right) = 0 and then 
            Throttle (Motor_Bottom_Right) = 0);
   procedure Test_Stop;
   
   function Distance return Centimeters with Inline;
   
private
   
   task Engine_Monitor
     with 
       Storage_Size => 1 * 1024,
       Priority => System_Configuration.Engine_Monitor_Priority;
   
end Vehicle;
