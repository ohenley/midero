with System;        use System;
--  with STM32.Device;  use STM32.Device;
with STM32_SVD;     use STM32_SVD;

package body Quadrature_Encoders is

   -----------------------
   -- Current_Direction --
   -----------------------
   function Current_Direction (This : Rotary_Encoder) return Counting_Direction
   is
   begin
      case Current_Counter_Mode (This.all) is
         when Up => return Up;
         when Down => return Down;
         when others => raise Program_Error;
      end case;
   end Current_Direction;
   -----------------
   -- Reset_Count --
   -----------------
   procedure Reset_Count (This : in out Rotary_Encoder) is
   begin
      Set_Counter (This.all, UInt16'(0));
   end Reset_Count;
   -------------------
   -- Current_Count --
   -------------------
   function Current_Count (This : Rotary_Encoder) return UInt32 is
     (Current_Counter (This.all));
   ------------------------
   -- Initialize_Encoder --
   ------------------------
    procedure Initialize_Encoder
     (This          : in out Rotary_Encoder;
      Encoder_TI1   : GPIO_Point;
      Encoder_TI2   : GPIO_Point;
      Encoder_Timer : not null access Timer;
      Encoder_AF    : STM32.GPIO_Alternate_Function)
   is
      Configuration : GPIO_Port_Configuration (Mode_AF);

      Debounce_Filter : constant Timer_Input_Capture_Filter := 6;
      --  See the STM32 RM, pg 561, re: ICXF, to set the input filtering.

      Period : constant UInt32 := (if Bidirectional (Encoder_Timer.all)
                                   then UInt32'Last else UInt32 (UInt16'Last));
   begin
      This := Rotary_Encoder (Encoder_Timer);
      Enable_Clock (Encoder_TI1);
      Enable_Clock (Encoder_TI2);
      Enable_Clock (Encoder_Timer.all);

      Configuration.Resistors := Pull_Up;
      Configuration.AF := Encoder_AF;
      Configuration.AF_Output_Type := Push_Pull;
      Configuration.AF_Speed := Speed_100MHz;

      Encoder_TI1.Configure_IO (Configuration);
      Encoder_TI2.Configure_IO (Configuration);

      Encoder_TI1.Lock;
      Encoder_TI2.Lock;

      Configure
          (Encoder_Timer.all,
           Prescaler     => 0,
           Period        => Period,
           Clock_Divisor => Div1,
           Counter_Mode  => Up);

      --Configure_Encoder_Interface
      --  (Encoder_Timer.all,
      --   Mode         => Encoder_Mode_TI1_TI2,
      --   IC1_Polarity => Rising,
      --   IC2_Polarity => Rising);

      --  Configure_Channel_Input
      --    (Encoder_Timer.all,
      --     Channel   => Channel_1,
      --     Polarity  => Rising,
      --     Selection => Direct_TI,
      --     Prescaler => Div1,
      --     Filter    => Debounce_Filter);
      --
      --  Configure_Channel_Input
      --    (Encoder_Timer.all,
      --     Channel   => Channel_2,
      --     Polarity  => Rising,
      --     Selection => Direct_TI,
      --     Prescaler => Div1,
      --     Filter    => Debounce_Filter);
      --
      --  Set_Autoreload (Encoder_Timer.all, Period);
      --
      --  Enable_Channel (Encoder_Timer.all, Channel_1);
      --  Enable_Channel (Encoder_Timer.all, Channel_2);
      --
      --  if Bidirectional (Encoder_Timer.all) then
      --     Set_Counter (Encoder_Timer.all, UInt32'(0));
      --  else
      --     Set_Counter (Encoder_Timer.all, UInt16'(0));
      --  end if;
      --
      --  Enable (Encoder_Timer.all);
   end Initialize_Encoder;
   -------------------
   -- Bidirectional --
   -------------------
   function Bidirectional (This : Timer) return Boolean is
     (This'Address = TIM1_Base or else
      This'Address = TIM2_Base or else
      This'Address = TIM3_Base or else
      This'Address = TIM4_Base or else
      This'Address = TIM5_Base or else
      This'Address = TIM8_Base);

end Quadrature_Encoders;
