-------------------------------------------------------------------------------
--  This package represents the physical plant, ie the car itself. As such,   -
--  it contains the declarations for the four DC motors.                      -
--  The motors are used for propulsion and steering. Other physical artifacts -
--  are also provided here, such as the mapping of turning directions to motor-
--  rotation direction.						   												-
-------------------------------------------------------------------------------

with System_Configuration;
with Motor;                             use Motor;

package Vehicle is
   
   pragma Elaborate_Body;
      
   procedure Initialize;
   --  Those are robot motor as physically connected
   Motor_Top_Left     : Basic_Motor;
   Motor_Top_Right    : Basic_Motor;
   Motor_Bottom_Left  : Basic_Motor;
   Motor_Bottom_Right : Basic_Motor;
   
   task Controller with
     Priority => System_Configuration.Vehicle_Priority;
end Vehicle;
