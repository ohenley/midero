--  This package provides a synchronization mechanism used to signal to the
--  various tasks that the critical instant has arrived and that, as a result,
--  their periodic executon can now commence (with the Time value specified for
--  the epoch).

with System_Configuration;
with Ada.Real_Time;         use Ada.Real_Time;

package Global_Initialization is

   protected Critical_Instant
     with Priority => System_Configuration.Highest_Priority
   is
      procedure Signal (Epoch : Time);
      entry Wait (Epoch : out Time);

   private
      Signalled : Boolean := False;
      Global_Epoch : Time := Time_First;
   end Critical_Instant;

end Global_Initialization;
