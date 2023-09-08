pragma Ada_2012;
package body Global_Initialization is

   ----------------------
   -- Critical_Instant --
   ----------------------

   protected body Critical_Instant is

      ------------
      -- Signal --
      ------------

      procedure Signal (Epoch : Time) is
      begin
         Signalled := True;
         Global_Epoch := Epoch;
      end Signal;

      ----------
      -- Wait --
      ----------

      entry Wait (Epoch : out Time) when Signalled is
      begin
         Epoch := Global_Epoch;
      end Wait;

   end Critical_Instant;

end Global_Initialization;
