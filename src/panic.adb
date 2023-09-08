with STM32.Board;   use STM32.Board;

procedure Panic (Blink_Interval : Time_Span := Milliseconds (250)) is
begin
   Initialize_LEDs;
   loop
      All_LEDs_Off;
      delay until Clock + Blink_Interval;
      All_LEDs_On;
      delay until Clock + Blink_Interval;
   end loop;
end Panic;
