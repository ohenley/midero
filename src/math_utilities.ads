-----------------------------------------------------------
--  This package provides useful math utility routines  ---

package Math_Utilities is
   generic
      type T is range <>;
   function Range_To_Domain_Mapping
     (Value, Range_Min, Range_Max, Domain_Min, Domain_Max : T) return T
     with
       Pre => Range_Min < Range_Max and
       Domain_Min < Domain_Max,
       Post => Range_To_Domain_Mapping'Result in Domain_Min .. Domain_Max,
       Inline;

   --  Maps the Value with the Range_Min .. Range_Max, to a Value in the
   --  domain Domain_Min .. Domain_Max

   generic
      type T is range <>;
   function Bounded_Integer_Value
     (Value, Low, High : T) return T
     with
       Pre => Low < High,
       Post => Bounded_Integer_Value'Result in Low .. High,
       Inline;
   --  Constrains the input value to the range Low ..High

   generic
      type T is range <>;
   procedure Bound_Integer_Value
     (Value : in out T; Low, High : T)
     with
       Pre => Low < High,
       Post => Value in Low .. High,
       Inline;
   --  Constrains the input value to the range Low .. High

   generic
      type T is digits <>;
   function Bounded_Floating_Value
     (Value, Low, High : T) return T
     with
       Pre => Low < High,
       Post => Bounded_Floating_Value'Result in Low .. High,
       Inline;

   generic
      type T is digits <>;
   procedure Bound_Floating_Value
     (Value : in out T; Low, High : T)
     with
       Pre => Low < High,
       Post => Value in Low .. High,
       Inline;
   --  Contrains the input value to the range Low .. High

end Math_Utilities;
