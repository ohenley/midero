with Midero;           use Midero;
with System_Configuration;

package rf_controller is

   -- Package Interface
   function Get_RF_Power return Integer;
   function Get_RF_Direction return Direction;
   
   task Controller with 
     Priority => System_Configuration.RF_Priority;

end rf_controller;
