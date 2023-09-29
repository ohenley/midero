--  Task periods and priorities

with System;    use System;

package System_Configuration is

   --  These constants are the priorities of the tasks in the system, defined
   --  here for ease of setting with the big picture in view.

   Main_Priority           : constant Priority := Priority'First; -- lowest
   Scanner_Priority        : constant Priority := Main_Priority + 1;
   Vehicle_Priority        : constant Priority := Scanner_Priority + 1;
   Sonar_Priority          : constant Priority := Vehicle_Priority + 1;
   RF_Priority             : constant Priority := Sonar_Priority + 1;
   Scheduler_Priority      : constant Priority := RF_Priority + 1;

   Highest_Priority : Priority renames Scheduler_Priority;
   --  whichever is highest. All the tasks call into the global initialization
   --  PO to await completion before doing anything interesting, so the PO
   --  requires the highest of those caller priorities.

   --  These constants are the tasks' periods, defined here for ease of setting
   --  with the big picture in view. They are merely numbers rather than values
   --  of type Time_Span.

   Scanner_Period          : constant := 2000;    -- seconds
   Vehicle_Period          : constant := 200;
   Sonar_Period            : constant := 150;     -- milliseconds
   RF_Period               : constant := 100;


end System_Configuration;
