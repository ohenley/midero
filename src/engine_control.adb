with Ada.Real_Time;               use Ada.Real_Time;
with LCD_Std_Out;                 use LCD_Std_Out;
with Global_Initialization;
--  with Engine;                      use Engine;
with Remote_Control;              use Remote_Control;
with Collision_Detection;
with Vehicle;                     use Vehicle;
with Analog_Sensor_Type.Polling;  use Analog_Sensor_Type.Polling;

package body Engine_Control is

   Period : constant Time_Span :=
     Milliseconds (System_Configuration.Engine_Control_Period);

   Vector : Remote_Control.Travel_Vector;
   --  We must declare this here, and access it as shown in the task body

   procedure Indicate_Emergency_Stopped;
   procedure Emergency_Stop;
   procedure Apply
     (Direction : Remote_Control.Travel_Directions;
      Power     : Remote_Control.Percentage);

   type Controller_States is (Running, Braked, Awaiting_Reversal);

   ----------------
   -- Controller --
   ----------------

   task body Controller is
      Current_State       : Controller_States := Running;
      Next_Release        : Time;
      Requested_Direction : Remote_Control.Travel_Directions;
      Requested_Braking   : Boolean;
      Requested_Power     : Remote_Control.Percentage;
      Collision_Imminent  : Boolean;
      Current_Power       : Percentage;
   begin
      Global_Initialization.Critical_Instant.Wait (Epoch => Next_Release);

      --  In the following loop, the call to get the requested vector does not
      --  block awaiting some change of input. The vectors are received as a
      --  continuous stream of values, often not changing from their previous
      --  values, rather than as a set of discrete commanded changes sent only
      --  when a new vector is commanded by the user.
      loop
         pragma Loop_Invariant (Enabled (Vehicle.Sonar));
         Clear_Screen;

         Vector := Remote_Control.Requested_Vector;
         Requested_Direction := Vector.Direction;
         Requested_Braking   := Vector.Emergency_Braking;
         Requested_Power     := Vector.Power;
         Current_Power       := Vehicle.Power;

         case Current_State is
            when Running =>
               Collision_Detection.Check (Requested_Direction,
                                          Current_Power,
                                          Collision_Imminent);
               --Put_Line ("Collision : " & Collision_Imminent'Image);
               if Collision_Imminent then
                  Emergency_Stop;
                  Current_State := Awaiting_Reversal;
               elsif Requested_Braking then
                  Emergency_Stop;
                  Current_State := Braked;
               else
                  Clear_Screen;
                  Put_Line ("Applying power");
                  Apply (Requested_Direction, Requested_Power);
               end if;

            when Braked =>
               if not Requested_Braking then
                  Current_State := Running;
               end if;
            when Awaiting_Reversal =>
               if Requested_Direction = Backward then
                  Current_State := Running;
               end if;
         end case;

         Next_Release := Next_Release + Period;
         delay until Next_Release;
      end loop;
   end Controller;

   --------------------
   -- Emergency_Stop --
   --------------------

   procedure Emergency_Stop is
   begin
      Vehicle.Test_Stop;
      Indicate_Emergency_Stopped;
   end Emergency_Stop;

   -----------
   -- Apply --
   -----------

   procedure Apply
     (Direction : Remote_Control.Travel_Directions;
      Power     : Remote_Control.Percentage)
   is
      pragma Unreferenced (Power);
   begin
      if Direction /= Neither then
         Vehicle.Test_Engage;
      else
         Vehicle.Test_Stop;
      end if;
      --  Indicate_Running;
   end Apply;

   --------------------------------
   -- Indicate_Emergency_Stopped --
   --------------------------------

   procedure Indicate_Emergency_Stopped is
   begin
      null;
   end Indicate_Emergency_Stopped;

end Engine_Control;
