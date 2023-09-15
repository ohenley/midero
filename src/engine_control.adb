with Ada.Real_Time;               use Ada.Real_Time;
with LCD_Std_Out;                 use LCD_Std_Out;

with Collision_Detection;
with Global_Initialization;

package body Engine_Control is

   Period : constant Time_Span :=
     Milliseconds (System_Configuration.Engine_Control_Period);
   ----------------
   -- Controller --
   ----------------

   task body Controller is
      Next_Release : Time;
      Collision    : Boolean;
   begin
      Global_Initialization.Critical_Instant.Wait (Epoch => Next_Release);
      Next_Release := Clock + Period;

      loop
         Clear_Screen;

         delay until Next_Release;
         Next_Release := Next_Release + Period;

         Collision_Detection.Check (Collision_Imminent => Collision);
      end loop;
   end Controller;

end Engine_Control;

