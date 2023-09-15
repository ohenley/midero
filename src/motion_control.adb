pragma Ada_2012;

with Ada.Real_Time;           use Ada.Real_Time;
with LCD_Std_Out;             use LCD_Std_Out;

with Global_Initialization;
with Engine_Control;
with Vehicle;

package body Motion_Control is

   Period : constant Time_Span :=
     Milliseconds (System_Configuration.Steering_Control_Period);

   ---------------
   -- Controler --
   ---------------

   task body Controler is
      Next_Release : Time;
      Collision_State : Boolean;
   begin
      --Global_Initialization.Critical_Instant.Wait (Epoch => Next_Release);
      Next_Release := Clock + Period;

      loop
         Clear_Screen;
         delay until Next_Release;
         Next_Release := Next_Release + Period;

         Collision_State := Engine_Control.Get_Collision_Controler_State;
      end loop;

   end Controler;

end Motion_Control;
