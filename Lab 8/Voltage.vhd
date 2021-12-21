

LIBRARY ieee;
   USE ieee.std_logic_1164.all;
   USE ieee.std_logic_unsigned.all;

ENTITY Voltage_Meas IS
   PORT (
      clk_in       : IN STD_LOGIC;
      rst_n_in     : IN STD_LOGIC;
       
      scl_out      : OUT STD_LOGIC;
      sda_out      : INOUT STD_LOGIC;
      mode_change_dot  : IN STD_LOGIC;

	  
	  lcd_rst_n_out  : OUT STD_LOGIC;
      lcd_bl_out     : OUT STD_LOGIC;
      lcd_dc_out     : OUT STD_LOGIC;
      lcd_clk_out    : OUT STD_LOGIC;
      lcd_data_out   : OUT STD_LOGIC;
	  
      rclk_out     : OUT STD_LOGIC;
      sclk_out     : OUT STD_LOGIC;
      sdio_out     : OUT STD_LOGIC;
      led          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
   );
END Voltage_Meas;


ARCHITECTURE trans OF Voltage_Meas IS
   
   SIGNAL adc_done       : STD_LOGIC;
   SIGNAL adc_data       : STD_LOGIC_VECTOR(7 DOWNTO 0);
   
   SIGNAL bin_code       : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL bcd_code       : STD_LOGIC_VECTOR(19 DOWNTO 0);
   
   SIGNAL trans_input    : STD_LOGIC_VECTOR(15 DOWNTO 0);
   
   SIGNAL num_disp       : STD_LOGIC_VECTOR(23 DOWNTO 0);
   

   component bin_2_BCD IS
   PORT (
      clk       : IN STD_LOGIC;
      rst       : IN STD_LOGIC;
      binary    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      BCD       : OUT STD_LOGIC_VECTOR(19 DOWNTO 0)
   );
   end component;

   component ADC_I2C IS
   PORT (
      clk_in : IN STD_LOGIC;
      rst_n_in : IN STD_LOGIC;
      scl_out : OUT STD_LOGIC;
      sda_out : INOUT STD_LOGIC;
      adc_done : OUT STD_LOGIC;
      adc_data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
   );
   end component;



   component seg_display IS
   PORT (
      clk_in : IN STD_LOGIC; 
        rst_n_in : IN STD_LOGIC; 
        num_in : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
        rclk_out : OUT STD_LOGIC; 
        sclk_out : OUT STD_LOGIC; 
        sdio_out : OUT STD_LOGIC;
        change_dot   : IN  STD_LOGIC
   );
   end component;
   
COMPONENT LCDRGB IS
PORT (
      clk_in         : IN STD_LOGIC;
      rst_n_in       : IN STD_LOGIC;
      lcd_rst_n_out  : OUT STD_LOGIC;
      lcd_bl_out     : OUT STD_LOGIC;
      lcd_dc_out     : OUT STD_LOGIC;
      lcd_clk_out    : OUT STD_LOGIC;
      lcd_data_out   : OUT STD_LOGIC;
	  ram_lcd_clk_en : out STD_LOGIC;
	  ram_lcd_addr   : out STD_LOGIC_VECTOR(7 DOWNTO 0);
	  ram_lcd_data   : in STD_LOGIC_VECTOR(127 DOWNTO 0)
   );
END COMPONENT LCDRGB;

COMPONENT ram IS
port
(
	clk : in std_logic;
	addr : in std_logic_vector(7 downto 0);
	we : in std_logic;
	din : in std_logic_vector(19 downto 0);
	dout : out std_logic_vector(127 downto 0)
);
END COMPONENT ram;

signal tmp_ram_lcd_clk_en :STD_LOGIC;
signal tmp_ram_lcd_addr :STD_LOGIC_VECTOR(7 DOWNTO 0);
signal tmp_ram_lcd_data :STD_LOGIC_VECTOR(127 DOWNTO 0);


BEGIN

   
   
   ADC_I2C1 : ADC_I2C
      PORT MAP (
         clk_in    => clk_in,
         rst_n_in  => rst_n_in,
         scl_out   => scl_out,
         sda_out   => sda_out,
         adc_done  => adc_done,
         adc_data  => adc_data
      );
   bin_code <= ('0' & adc_data & "0000000") + ("00000000" & adc_data);--adc_dataÊÇ0~255£¬bin_codeÊÇ0~33000
   PROCESS (clk_in, rst_n_in)
   BEGIN
      IF ((NOT(rst_n_in)) = '1') THEN
         led <= "00000000";
      ELSIF (clk_in'EVENT AND clk_in = '1') THEN

		 led<=not adc_data;
      END IF;
   END PROCESS;
   
   PROCESS (clk_in, rst_n_in)
   BEGIN
      IF ((NOT(rst_n_in)) = '1') THEN
         trans_input <= "0000000000000000";
      ELSIF (clk_in'EVENT AND clk_in = '1') THEN
         IF (mode_change_dot = '1') THEN
            trans_input <= bin_code;
         ELSE
            trans_input <= ("00000000" & adc_data);
         END IF;
      END IF;
   END PROCESS;
   
   
   
   bin_2_BCD1 : bin_2_BCD
      PORT MAP (
         clk     => clk_in,
         rst     => rst_n_in,
         binary  => trans_input,
         bcd     => bcd_code
      );
   num_disp <= ("0000" & bcd_code(19 DOWNTO 0));

   disp1 : seg_display
      PORT MAP (
         clk_in    => clk_in,
         rst_n_in  => rst_n_in,
         num_in    => num_disp,
         sclk_out  => sclk_out,
         rclk_out  => rclk_out,
         sdio_out  => sdio_out,
         change_dot    => mode_change_dot
      );

   LCD_driver1 : LCDRGB
PORT MAP(
  clk_in         =>clk_in,
  rst_n_in       =>rst_n_in,
  lcd_rst_n_out  =>lcd_rst_n_out,
  lcd_bl_out     =>lcd_bl_out,
  lcd_dc_out     =>lcd_dc_out,
  lcd_clk_out    =>lcd_clk_out,
  lcd_data_out   =>lcd_data_out,
  ram_lcd_clk_en =>tmp_ram_lcd_clk_en,
  ram_lcd_addr   =>tmp_ram_lcd_addr,
  ram_lcd_data   =>tmp_ram_lcd_data
);

ram1 : ram
PORT MAP(
	clk =>clk_in,
	addr =>tmp_ram_lcd_addr,
	we =>tmp_ram_lcd_clk_en,
	din =>bcd_code,
	dout =>tmp_ram_lcd_data
);
   
END trans;



