pragma Ada_2012;
package body Math_Utilities is

   -----------------------------
   -- Range_To_Domain_Mapping --
   -----------------------------

   function Range_To_Domain_Mapping
     (Value, Range_Min, Range_Max, Domain_Min, Domain_Max : T) return T is
     ((Value - Range_Min) * (Domain_Max - Domain_Min) /
      (Range_Max - Range_Min) + Domain_Min);

   ---------------------------
   -- Bounded_Integer_Value --
   ---------------------------

   function Bounded_Integer_Value (Value, Low, High : T) return T is
     (if Value < Low then Low elsif Value > High then High else Value);

   -------------------------
   -- Bound_Integer_Value --
   -------------------------

   procedure Bound_Integer_Value (Value : in out T; Low, High : T) is
   begin
      if Value < Low then
         Value := Low;
      elsif Value > High then
         Value := High;
      end if;
   end Bound_Integer_Value;

   ----------------------------
   -- Bounded_Floating_Value --
   ----------------------------

   function Bounded_Floating_Value (Value, Low, High : T) return T is
     (if Value < Low then Low elsif Value > High then High else Value);

   --------------------------
   -- Bound_Floating_Value --
   --------------------------

   procedure Bound_Floating_Value (Value : in out T; Low, High : T) is
   begin
      if Value < Low then
         Value := Low;
      elsif Value > High then
         Value := High;
      end if;
   end Bound_Floating_Value;

end Math_Utilities;
