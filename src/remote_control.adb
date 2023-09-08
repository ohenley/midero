with Ada.Real_Time;              use Ada.Real_Time;

with Global_Initialization;
with Midero.Hardware_Configuration;
with System_Configuration;

package body Remote_Control is

   Period : constant Time_Span :=
     Milliseconds (System_Configuration.Remote_Control_Period);

   Current_Vector : Travel_Vector := (50, Forward, False);

   ----------------------
   -- Requested_Vector --
   ----------------------

   function Requested_Vector return Travel_Vector is
     (Current_Vector);

end Remote_Control;
