--  Task periods and priorities

with System;    use System;

package System_Configuration is

   --  These constants are the priorities of the tasks in the system, defined
   --  here for ease of setting with the big picture in view.

   Main_Priority           : constant Priority := Priority'First; -- lowest
   Engine_Monitor_Priority : constant Priority := Main_Priority + 1;
   Remote_Priority         : constant Priority := Engine_Monitor_Priority + 1;
   Engine_Control_Priority : constant Priority := Remote_Priority + 1;
   Steering_Priority       : constant Priority := Engine_Control_Priority + 1;

   --  The engine control priority needs high priority because it calls the
   --  sonar sensor via the collision detection module, and that sonar object

   Highest_Priority : Priority renames Steering_Priority;
   --  whichever is highest. All the tasks call into the global initialization
   --  PO to await completion before doing anything interesting, so the PO
   --  requires the highest of those caller priorities.

   --  These constants are the tasks' periods, defined here for ease of setting
   --  with the big picture in view. They are merely numbers rather than values
   --  of type Time_Span.

   Steering_Control_Period : constant := 300;     -- milliseconds
   Engine_Control_Period   : constant := 250;     -- milliseconds
   Engine_Monitor_Period   : constant := 200;     -- milliseconds
   Remote_Control_Period   : constant := 100;     -- milliseconds

end System_Configuration;
