with Ada.Real_Time;           use Ada.Real_Time;

with Global_Initialization;
with System_Configuration;
with Vehicle;                 pragma Unreferenced (Vehicle);
with Sonar;                   pragma Unreferenced (Sonar);


procedure Midero_bot is
   pragma Priority (System_Configuration.Main_Priority);
begin
   Vehicle.Initialize;
   Global_Initialization.Critical_Instant.Signal (Epoch => Clock);
   loop
      delay until Time_Last;
   end loop;
end Midero_bot;
