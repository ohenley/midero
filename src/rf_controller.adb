with Ada.Real_Time;        use Ada.Real_Time;
with Global_Initialization;

package body rf_controller is

   Period : constant Time_Span := 
     Milliseconds (System_Configuration.RF_Period);
   
   protected Critical_RF is
      --  Motor power
      procedure Set_Power (Reading : Integer);
      procedure Get_Power (Reading : out Integer);
      --  Motor rotation direction
      procedure Set_Direction (Reading : Direction);
      procedure Get_Direction (Reading : out Direction);
   private
      RF_Power : Integer;
      RF_Direction : Direction;
   end Critical_RF;
   ------------------
   -- Critical_RF --
   -----------------
   protected body Critical_RF is
      ---------------
      -- Set_Power --
      ---------------
      procedure Set_Power (Reading : Integer) is
      begin
         RF_Power := Reading;
      end Set_Power;
      ---------------
      -- Get_Power --
      ---------------
      procedure Get_Power (Reading : out Integer) is
      begin
         Reading := RF_Power;
      end Get_Power;
      -------------------
      -- Set_Direction --
      -------------------
      procedure Set_Direction (Reading : Direction) is
      begin
         RF_Direction := Reading;
      end Set_Direction;
      -------------------
      -- Get_Direction --
      -------------------
      procedure Get_Direction (Reading : out Direction) is
      begin
         Reading := RF_Direction;
      end Get_Direction;
   end Critical_RF;
   ---------------------
   -- Task Controller --
   ---------------------
   
   task body Controller is
      Next_Release : Time;
      Dir : Direction;
   begin
      Global_Initialization.Critical_Instant.Wait (Epoch => Next_Release);
      loop
         Next_Release := Next_Release + Period;
         delay until Next_Release;
         
         Critical_RF.Set_Power (50);
         Critical_RF.Set_Direction (Forward);
         
         Critical_RF.Get_Direction (Reading => Dir);
         if Dir = Forward then
            Critical_RF.Set_Direction (Reading => Backward);
         else
            Critical_RF.Set_Direction (Reading => Forward);
         end if;
      end loop;
      
   end Controller;
   
   ------------------
   -- Get_RF_Power --
   ------------------
   
   function Get_RF_Power return Integer is
      Power : Integer;
   begin
      Critical_RF.Get_Power (Reading => Power);
      return Power;
   end Get_RF_Power;
   
   ----------------------
   -- Get_RF_Direction --
   ----------------------
   function Get_RF_Direction return Direction is
      Dir : Direction;
   begin
      Critical_RF.Get_Direction (Reading => Dir);
      return Dir;
   end Get_RF_Direction;

end rf_controller;
