pragma Ada_2012;

package body Motor is

   Power : Power_Level := 30;   
   Internal_Direction  : Direction := Forward;

   type State_T is (Run, Not_Run);
   Internal_State : State_T := Not_Run;
   
   procedure Stop (This : out Basic_Motor);
   procedure Turn_Motor (This : out Basic_Motor; Intensity : Power_Level);
   procedure Change_Direction (This : out Basic_Motor; Dir : Direction);
   procedure Configure_Polarity_Control (This : GPIO_Point);
   ----------
   -- Stop --
   ----------
   procedure Stop (This : out Basic_Motor) is
   begin
      Clear (This.H_Bridge1); -- 0
      Clear (This.H_Bridge2); -- 0
      This.Power_Plant.Set_Duty_Cycle (100); -- Full power to Lock position 
   end Stop;
   
   ------------
   -- Engage --
   ------------
   procedure Engage (This : out Basic_Motor; State : State_T) is
   begin
      if State /= Internal_State then
         if Internal_State = Run then
            This.Turn_Motor (Power);
            This.Change_Direction (Dir => Internal_Direction);
         else
            This.Stop;
         end if;
         Internal_State := State
      en dif;

      --if not State then
      --   This.Stop;
      --else
      --   This.Turn_Motor (Power);
      --   This.Change_Direction (Dir => Internal_Direction);
      --end if;
   end Engage;
   ----------------
   -- Turn_Motor --
   ----------------
   procedure Turn_Motor (This : out Basic_Motor; Intensity : Power_Level) is
   begin
      This.Power_Plant.Set_Duty_Cycle (Integer (Intensity));
   end Turn_Motor;
   ----------------------
   -- Change_Direction --
   ----------------------
   procedure Change_Direction (This : out Basic_Motor; Dir : Direction) is
   begin
      case Dir is
         when Forward =>
            Toggle (This.H_Bridge1);
            Clear (This.H_Bridge2);
         when Backward =>
            Toggle (This.H_Bridge2);
            Clear (This.H_Bridge1);
      end case;
   end Change_Direction;
   ---------------
   -- Set_Power --
   ---------------
   procedure Set_Power (Intensity : Power_Level) is
   begin
      Power := Intensity;
   end Set_Power;
   -------------------
   -- Set_Direction --
   -------------------
   procedure Set_Direction  (External_Direction : Direction) is
   begin
      Internal_Direction := External_Direction;
   end Set_Direction;
   ----------------
   -- Initialize --
   ----------------
   procedure Initialize 
     (This                 : out Basic_Motor;
      PWM_Timer            : not null access Timer;
      PWM_Output_Frequency : BT.UInt32; -- in Hertz
      PWM_AF               : STM32.GPIO_Alternate_Function;
      PWM_Output           : GPIO_Point;
      PWM_Output_Channel   : Timer_Channel;
      --  discrete outputs to H-Bridge that control direction and stopping
      Polarity1            : GPIO_Point;
      Polarity2            : GPIO_Point) is
   begin
      --  First set up the PWM for the motors' power control.
      --  We do this configuration here because we are not sharing the timer
      --  across other PWM generation clients
      Configure_PWM_Timer (PWM_Timer, PWM_Output_Frequency);

      This.Power_Plant.Attach_PWM_Channel (PWM_Timer,  PWM_Output_Channel,
                                           PWM_Output, PWM_AF);
      This.Power_Plant.Enable_Output;
      This.Power_Channel := PWM_Output_Channel;
      --  Finally, configure the output points for controlling the H-Bridge
      --  circuits that control the rotation direction as well as stopping
      --  the rotation entirely (via procedure Stop)
      This.H_Bridge1 := Polarity1;
      This.H_Bridge2 := Polarity2;

      Enable_Clock (Point => This.H_Bridge1);
      Enable_Clock (Point => This.H_Bridge2);

      Configure_Polarity_Control (This.H_Bridge1);
      Configure_Polarity_Control (This.H_Bridge2);
   end Initialize;
   --------------------------------
   -- Configure_Polarity_Control --
   --------------------------------
   procedure Configure_Polarity_Control (This : GPIO_Point) is
      Config : GPIO_Port_Configuration;
   begin
      Config := (Mode           => Mode_Out,
                 Output_Type    => Push_Pull,
                 Resistors      => Floating,
                 Speed          => Speed_100MHz);
      This.Configure_IO (Config => Config);
      This.Lock;      -- Lock the current configuration of Pin until reset.
   end Configure_Polarity_Control;
end Motor;
