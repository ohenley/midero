with Ada.Real_Time;               use Ada.Real_Time;
with LCD_Std_Out;                 use LCD_Std_Out;
with Global_Initialization;
with System_Configuration;
--  with Engine;                      use Engine;
with Collision_Detection;
with Panic;

package body Engine_Control is

   Period : constant Time_Span :=
     Milliseconds (System_Configuration.Engine_Control_Period);

   protected Collision_Controler is
      procedure Get_Collision_State (Reading : out Boolean);
      procedure Set_Collision_State (Reading : Boolean);
   private
      Collision_State : Boolean;
   end Collision_Controler;

   --------------------------
   -- Collision_Coontroler --
   --------------------------

   protected body Collision_Controler is

      -------------------------
      -- Get_Collision_State --
      -------------------------

      procedure Get_Collision_State (Reading : out Boolean) is
      begin
         Reading := Collision_State;
      end Get_Collision_State;

      -------------------------
      -- Set_Collision_State --
      -------------------------

      procedure Set_Collision_State (Reading : Boolean) is
      begin
         Collision_State := Reading;
      end Set_Collision_State;
   end Collision_Controler;

   ----------------
   -- Controller --
   ----------------
   task Controller
     with
       Priority => System_Configuration.Engine_Control_Priority;

   task body Controller is
      Next_Release  : Time;
      Collision_Imminent  : Boolean;
   begin
      Global_Initialization.Critical_Instant.Wait (Epoch => Next_Release);
      Next_Release := Clock + Period;

      loop
         Clear_Screen;

         delay until Next_Release;
         Next_Release := Next_Release + Period;

         Collision_Detection.Check (Collision_Imminent);

         if Collision_Imminent then
            Panic;
         end if;

         Put_Line ("Collision= " & Collision_Imminent'Img);
         --Collision_Controler.Set_Collision_State (Collision_Imminent);
      end loop;
   end Controller;

   -----------------------------------
   -- Get_Collision_Controler_State --
   -----------------------------------

   function Get_Collision_Controler_State return Boolean is
      State : Boolean;
   begin
      Collision_Controler.Get_Collision_State (Reading => State);
      return State;
   end Get_Collision_Controler_State;

end Engine_Control;
