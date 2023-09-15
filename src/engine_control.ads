with System_Configuration;

package Engine_Control is
   pragma Elaborate_Body;
   task Controller
     with
       Priority => System_Configuration.Engine_Control_Priority;

end Engine_Control;

