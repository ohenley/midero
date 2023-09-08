-------------------------------------------------------------------------------
--  This package represents the interface for types used by this package     --
--  children.Types are declared here to avoid circular dependency between    --
--  others packages.                                                         --
-------------------------------------------------------------------------------
package Midero is 
	pragma pure;
	
   type Polarity is (ONE, TWO);
   type Frequency is new Integer range 0 .. 50_000_000;
   type Revolution is new Integer range 0 .. 1_000;
   
end Midero;
