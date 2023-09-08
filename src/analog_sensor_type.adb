pragma Ada_2012;
with STM32.Device;                use STM32.Device;

package body Analog_Sensor_Type is

   ----------------
   -- Assign_ADC --
   ----------------

   procedure Assign_ADC
     (This          : in out Analog_Sensor_T;
      Converter     : access Analog_To_Digital_Converter;
      Input_Channel : Analog_Input_Channel;
      Input_Pin     : GPIO_Point)
   is
   begin
      This.Converter     := Converter;
      This.Input_Channel := Input_Channel;
      This.Input_Pin     := Input_Pin;
   end Assign_ADC;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize (This : in out Analog_Sensor_T) is
   begin
      Enable_Clock (This.Input_Pin);
      This.Input_Pin.Configure_IO ((Mode_Analog, Resistors => Floating));

      Enable_Clock (This.Converter.all);
      Configure_Unit (This.Converter.all,
                      Resolution => Sensor_ADC_Resolution,
                      Alignment => Right_Aligned);
   end Initialize;

   -------------------
   -- Get_Intensity --
   -------------------

   procedure Get_Intensity
     (This       : in out Analog_Sensor_T;
      Reading    : out Intensity;
      Successful : out Boolean)
   is
      Raw    : Integer;
      Scaled : Integer;
   begin
      Get_Raw_Reading (Analog_Sensor_T'Class (This), Raw, Successful);
      if not Successful then
         Reading := 0;
         return;
      end if;
      Raw     := As_Varying_Directly (Raw);
      Scaled  := Mapped (Raw, This.Low, This.High, Intensity'First, Intensity'Last);
      Reading := Constrained (Scaled, Intensity'First, Intensity'Last);
   end Get_Intensity;

   ------------
   -- Enable --
   ------------

   procedure Enable (This : in out Analog_Sensor_T) is
   begin
      STM32.ADC.Enable (This.Converter.all);
   end Enable;

   -------------
   -- Disable --
   -------------

   procedure Disable (This : in out Analog_Sensor_T) is
   begin
      STM32.ADC.Disable (This.Converter.all);
   end Disable;

   -------------
   -- Enabled --
   -------------

   function Enabled (This : Analog_Sensor_T) return Boolean is
     (STM32.ADC.Enabled (This.Converter.all));

   ---------------------
   -- Set_Calibration --
   ---------------------

   procedure Set_Calibration
     (This     : in out Analog_Sensor_T;
      Least    : Varying_Directly;
      Greatest : Varying_Directly)
   is
   begin
      This.Low  := Least;
      This.High := Greatest;
   end Set_Calibration;

   -----------------
   -- Calibration --
   -----------------

   function Calibration (This : Analog_Sensor_T) return Sensor_Calibration is
     (This.Low, This.High);


end Analog_Sensor_Type;
