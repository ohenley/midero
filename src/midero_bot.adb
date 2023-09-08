with Ada.Real_Time;                 use Ada.Real_Time;
with Engine_Control;                pragma Unreferenced (Engine_Control);
with Remote_Control;                pragma Unreferenced (Remote_Control);
with Vehicle;                       pragma Unreferenced (Vehicle);
with Global_Initialization;
with System_Configuration;

procedure Midero_bot is
   pragma Priority (System_Configuration.Main_Priority);
begin
   Vehicle.Initialize;   
   --  Allow the tasks to start doing their post-initialization work,  ie the
   --  epoch starts for their periodic loops with the value passed
   Global_Initialization.Critical_Instant.Signal (Epoch => Clock);
   loop
      delay until Time_Last;
   end loop;
end Midero_bot;
