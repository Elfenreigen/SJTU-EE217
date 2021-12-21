LIBRARY ieee;
   USE ieee.std_logic_1164.all;
   USE ieee.std_logic_unsigned.all;
   USE IEEE.Std_Logic_Arith.ALL;

--Attention
--!!! 
--this VHDL code file refer to a Verilog code file which attain the same function
--!!!

ENTITY LCDRGB IS

   --the constant used in project
   GENERIC (
      INIT_DEPTH     : INTEGER := 73;
      
      IDLE           : INTEGER := 0;
      MAIN           : INTEGER := 1;
      INIT           : INTEGER := 2;
      SCAN           : INTEGER := 3;
      WRITE          : INTEGER := 4;
      DELAY          : INTEGER := 5;
      
      LOW            : STD_LOGIC :='0';
      HIGH           : STD_LOGIC :='1'
   );

   --the port used
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
END LCDRGB;

ARCHITECTURE behave OF LCDRGB IS

   --define the type convenient for command and data storage
   TYPE memery_setxy IS ARRAY (10 DOWNTO 0) OF STD_LOGIC_VECTOR(8 DOWNTO 0);
   TYPE memery_initial IS ARRAY (72 DOWNTO 0) OF STD_LOGIC_VECTOR(8 DOWNTO 0);
   
   --define the color of background and typeface
   SIGNAL color_t        : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL color_b        : STD_LOGIC_VECTOR(15 DOWNTO 0);
   
   --define the auxiliary variable
   SIGNAL x_cnt          : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL y_cnt          : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL ram_data_r     : STD_LOGIC_VECTOR(131 DOWNTO 0);
   
   SIGNAL data_reg       : STD_LOGIC_VECTOR(8 DOWNTO 0);
   SIGNAL reg_setxy      : memery_setxy;
   SIGNAL reg_init       : memery_initial;
   SIGNAL cnt_main       : STD_LOGIC_VECTOR(2 DOWNTO 0);
   SIGNAL cnt_init       : STD_LOGIC_VECTOR(2 DOWNTO 0);
   SIGNAL cnt_scan       : STD_LOGIC_VECTOR(2 DOWNTO 0);
   SIGNAL cnt_write      : STD_LOGIC_VECTOR(5 DOWNTO 0);
   SIGNAL cnt_delay      : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL num_delay      : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL cnt            : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL high_word      : STD_LOGIC;
   SIGNAL state          : STD_LOGIC_VECTOR(2 DOWNTO 0) := conv_std_logic_vector(IDLE, 3);
   SIGNAL state_back     : STD_LOGIC_VECTOR(2 DOWNTO 0) := conv_std_logic_vector(IDLE, 3);

   SIGNAL high_byte : STD_LOGIC_VECTOR(8 DOWNTO 0);
   SIGNAL low_byte : STD_LOGIC_VECTOR(8 DOWNTO 0);
BEGIN

   --assign the color of background and typeface
   color_t <= "0000000000000000";
   color_b <= "1111111111111111";
   
   --convert the state of a pixel (background or typeface) to real color which is needed by LCD.
   high_byte <= ('0' & color_t(15 DOWNTO 8)) WHEN ((ram_data_r(conv_integer(x_cnt))) = '1') ELSE
              ('0' & color_b(15 DOWNTO 8));
   low_byte <= ('0' & color_t(7 DOWNTO 0)) WHEN ((ram_data_r(conv_integer(x_cnt))) = '1') ELSE
              ('0' & color_b(7 DOWNTO 0));

   PROCESS (clk_in, rst_n_in)
   BEGIN
      
      --reset examination
      IF ((NOT(rst_n_in)) = '1') THEN
         x_cnt <= "00000000";
         y_cnt <= "00000000";
         ram_lcd_clk_en <= '0';
         ram_lcd_addr <= "00000000";
         cnt_main <= "000";
         cnt_init <= "000";
         cnt_scan <= "000";
         cnt_write <= "000000";
         cnt_delay <= "0000000000000000";
         num_delay <= "0000000000110010";
         cnt <= "0000000000000000";
         high_word <= '1';
         lcd_bl_out <= LOW;
         state <= conv_std_logic_vector(IDLE, 3);
         state_back <= conv_std_logic_vector(IDLE, 3);
      ELSIF (clk_in'EVENT AND clk_in = '1') THEN
         --state machine
         CASE state IS
            --IDLE state
            WHEN conv_std_logic_vector(IDLE, 3) =>
               x_cnt <= "00000000";
               y_cnt <= "00000000";
               ram_lcd_clk_en <= '0';
               ram_lcd_addr <= "00000000";
               cnt_main <= "000";
               cnt_init <= "000";
               cnt_scan <= "000";
               cnt_write <= "000000";
               cnt_delay <= "0000000000000000";
               num_delay <= "0000000000110010";
               cnt <= "0000000000000000";
               high_word <= '1';
               state <= conv_std_logic_vector(MAIN, 3);
               state_back <= conv_std_logic_vector(MAIN, 3);
            
            --MAIN state
            WHEN conv_std_logic_vector(MAIN, 3) =>
               CASE cnt_main IS
                  WHEN "000" =>
                     state <= conv_std_logic_vector(INIT, 3);
                     cnt_main <= cnt_main + "001";
                  WHEN "001" =>
                     state <= conv_std_logic_vector(SCAN, 3);
                     cnt_main <= cnt_main + "001";
                  WHEN "010" =>
                     cnt_main <= "001";
                  WHEN OTHERS =>
                     state <= conv_std_logic_vector(IDLE, 3);
               END CASE;

            --INIT state
            WHEN conv_std_logic_vector(INIT, 3) =>
               CASE cnt_init IS
                  WHEN "000" =>
                     lcd_rst_n_out <= '0';
                     cnt_init <= cnt_init + "001";
                  WHEN "001" =>
                     num_delay <= "0000101110111000";
                     state <= conv_std_logic_vector(DELAY, 3);
                     state_back <= conv_std_logic_vector(INIT, 3);
                     cnt_init <= cnt_init + "001";
                  WHEN "010" =>
                     lcd_rst_n_out <= '1';
                     cnt_init <= cnt_init + "001";
                  WHEN "011" =>
                     num_delay <= "0000101110111000";
                     state <= conv_std_logic_vector(DELAY, 3);
                     state_back <= conv_std_logic_vector(INIT, 3);
                     cnt_init <= cnt_init + "001";
                  WHEN "100" =>
                     IF (cnt >= conv_std_logic_vector(INIT_DEPTH, 16)) THEN
                        cnt <= "0000000000000000";
                        cnt_init <= cnt_init + "001";
                     ELSE
                        data_reg <= reg_init(conv_integer(cnt));
                        IF (cnt = "0000000000000000") THEN
                           num_delay <= "1100001101010000";
                        ELSE
                           num_delay <= "0000000000110010";
                        END IF;
                        cnt <= cnt + "0000000000000001";
                        state <= conv_std_logic_vector(WRITE, 3);
                        state_back <= conv_std_logic_vector(INIT, 3);
                     END IF;
                  WHEN "101" =>
                     cnt_init <= "000";
                     state <= conv_std_logic_vector(MAIN, 3);
                  WHEN OTHERS =>
                     state <= conv_std_logic_vector(IDLE, 3);
               END CASE;

            --SCAN state
            WHEN conv_std_logic_vector(SCAN, 3) =>
               CASE cnt_scan IS
                  WHEN "000" =>
                     IF (cnt >= "0000000000001011") THEN
                        cnt <= "0000000000000000";
                        cnt_scan <= cnt_scan + "001";
                     ELSE
                        data_reg <= reg_setxy(conv_integer(cnt));
                        cnt <= cnt + "0000000000000001";
                        num_delay <= "0000000000110010";
                        state <= conv_std_logic_vector(WRITE, 3);
                        state_back <= conv_std_logic_vector(SCAN, 3);
                     END IF;
                  WHEN "001" =>
                     ram_lcd_clk_en <= HIGH;
                     ram_lcd_addr <= y_cnt;
                     cnt_scan <= cnt_scan + "001";
                  WHEN "010" =>
                     cnt_scan <= cnt_scan + "001";
                  WHEN "011" =>
                     ram_lcd_clk_en <= LOW;
                     ram_data_r <= ("0000" & ram_lcd_data);
                     cnt_scan <= cnt_scan + "001";
                  WHEN "100" =>
                     IF (x_cnt >= ("0000000" & "10000100")) THEN
                        x_cnt <= "00000000";
                        IF (y_cnt >= ("0000000" & "10100010")) THEN
                           y_cnt <= "00000000";
                           cnt_scan <= cnt_scan + "001";
                        ELSE
                           y_cnt <= y_cnt + "00000001";
                           cnt_scan <= "001";
                        END IF;
                     ELSE
                        IF (high_word = '1') THEN
                           data_reg <= ('1' & (high_byte(7 DOWNTO 0)));
                        ELSE
                           data_reg <= ('1' & (low_byte(7 DOWNTO 0)));
                           x_cnt <= x_cnt + "00000001";
                        END IF;
                        high_word <= NOT(high_word);
                        num_delay <= "0000000000110010";
                        state <= conv_std_logic_vector(WRITE, 3);
                        state_back <= conv_std_logic_vector(SCAN, 3);
                     END IF;
                  WHEN "101" =>
                     cnt_scan <= "000";
                     lcd_bl_out <= HIGH;
                     state <= conv_std_logic_vector(MAIN, 3);
                  WHEN OTHERS =>
                     state <= conv_std_logic_vector(IDLE, 3);
               END CASE;

            --WRITE state
            WHEN conv_std_logic_vector(WRITE, 3) =>
               IF (cnt_write >= "010001") THEN
                  cnt_write <= "000000";
               ELSE
                  cnt_write <= cnt_write + "000001";
               END IF;
               CASE cnt_write IS
                  WHEN "000000" =>
                     lcd_dc_out <= data_reg(8);
                  WHEN "000001" =>
                     lcd_clk_out <= LOW;
                     lcd_data_out <= data_reg(7);
                  WHEN "000010" =>
                     lcd_clk_out <= HIGH;
                  WHEN "000011" =>
                     lcd_clk_out <=LOW;
                     lcd_data_out <= data_reg(6);
                  WHEN "000100" =>
                     lcd_clk_out <= HIGH;
                  WHEN "000101" =>
                     lcd_clk_out <= LOW;
                     lcd_data_out <= data_reg(5);
                  WHEN "000110" =>
                     lcd_clk_out <= HIGH;
                  WHEN "000111" =>
                     lcd_clk_out <= LOW;
                     lcd_data_out <= data_reg(4);
                  WHEN "001000" =>
                     lcd_clk_out <= HIGH;
                  WHEN "001001" =>
                     lcd_clk_out <= LOW;
                     lcd_data_out <= data_reg(3);
                  WHEN "001010" =>
                     lcd_clk_out <= HIGH;
                  WHEN "001011" =>
                     lcd_clk_out <= LOW;
                     lcd_data_out <= data_reg(2);
                  WHEN "001100" =>
                     lcd_clk_out <= HIGH;
                  WHEN "001101" =>
                     lcd_clk_out <= LOW;
                     lcd_data_out <= data_reg(1);
                  WHEN "001110" =>
                     lcd_clk_out <= HIGH;
                  WHEN "001111" =>
                     lcd_clk_out <= LOW;
                     lcd_data_out <= data_reg(0);
                  WHEN "010000" =>
                     lcd_clk_out <= HIGH;
                  WHEN "010001" =>
                     lcd_clk_out <= LOW;
                     state <= conv_std_logic_vector(DELAY, 3);
                  WHEN OTHERS =>
                     state <= conv_std_logic_vector(IDLE, 3);
               END CASE;

            --DELAY state
            WHEN conv_std_logic_vector(DELAY, 3) =>
               IF (cnt_delay >= num_delay) THEN
                  cnt_delay <= "0000000000000000";
                  state <= state_back;
               ELSE
                  cnt_delay <= cnt_delay + "0000000000000001";
               END IF;
            WHEN OTHERS =>
               state <= conv_std_logic_vector(IDLE, 3);
         END CASE;
      END IF;
   END PROCESS;
   
   --the command and data memory for setting display window initially
   PROCESS 
   BEGIN
      reg_setxy(0) <= ('0' & "00101010");
      reg_setxy(1) <= ('1' & "00000000");
      reg_setxy(2) <= ('1' & "00000000");
      reg_setxy(3) <= ('1' & "00000000");
      reg_setxy(4) <= ('1' & "10000011");
      reg_setxy(5) <= ('0' & "00101011");
      reg_setxy(6) <= ('1' & "00000000");
      reg_setxy(7) <= ('1' & "00000000");
      reg_setxy(8) <= ('1' & "00000000");
      reg_setxy(9) <= ('1' & "10100001");
      reg_setxy(10) <= ('0' & "00101100");
   END PROCESS;
   
   --the command and data memory for initail
   PROCESS 
   BEGIN
      reg_init(0) <= ('0' & "00010001");
      reg_init(1) <= ('0' & "10110001");
      reg_init(2) <= ('1' & "00000101");
      reg_init(3) <= ('1' & "00111100");
      reg_init(4) <= ('1' & "00111100");
      reg_init(5) <= ('0' & "10110010");
      reg_init(6) <= ('1' & "00000101");
      reg_init(7) <= ('1' & "00111100");
      reg_init(8) <= ('1' & "00111100");
      reg_init(9) <= ('0' & "10110011");
      reg_init(10) <= ('1' & "00000101");
      reg_init(11) <= ('1' & "00111100");
      reg_init(12) <= ('1' & "00111100");
      reg_init(13) <= ('1' & "00000101");
      reg_init(14) <= ('1' & "00111100");
      reg_init(15) <= ('1' & "00111100");
      reg_init(16) <= ('0' & "10110100");
      reg_init(17) <= ('1' & "00000011");
      reg_init(18) <= ('0' & "11000000");
      reg_init(19) <= ('1' & "00101000");
      reg_init(20) <= ('1' & "00001000");
      reg_init(21) <= ('1' & "00000100");
      reg_init(22) <= ('0' & "11000001");
      reg_init(23) <= ('1' & "11000000");
      reg_init(24) <= ('0' & "11000010");
      reg_init(25) <= ('1' & "00001101");
      reg_init(26) <= ('1' & "00000000");
      reg_init(27) <= ('0' & "11000011");
      reg_init(28) <= ('1' & "10001101");
      reg_init(29) <= ('1' & "00101010");
      reg_init(30) <= ('0' & "11000100");
      reg_init(31) <= ('1' & "10001101");
      reg_init(32) <= ('1' & "11101110");
      reg_init(32) <= ('0' & "11000101");
      reg_init(33) <= ('1' & "00011010");
      reg_init(34) <= ('0' & "00110110");
      reg_init(35) <= ('1' & "11000000");
      reg_init(36) <= ('0' & "11100000");
      reg_init(37) <= ('1' & "00000100");
      reg_init(38) <= ('1' & "00100010");
      reg_init(39) <= ('1' & "00000111");
      reg_init(40) <= ('1' & "00001010");
      reg_init(41) <= ('1' & "00101110");
      reg_init(42) <= ('1' & "00110000");
      reg_init(43) <= ('1' & "00100101");
      reg_init(44) <= ('1' & "00101010");
      reg_init(45) <= ('1' & "00101000");
      reg_init(46) <= ('1' & "00100110");
      reg_init(47) <= ('1' & "00101110");
      reg_init(48) <= ('1' & "00111010");
      reg_init(49) <= ('1' & "00000000");
      reg_init(50) <= ('1' & "00000001");
      reg_init(51) <= ('1' & "00000011");
      reg_init(52) <= ('1' & "00010011");
      reg_init(53) <= ('0' & "11100001");
      reg_init(54) <= ('1' & "00000100");
      reg_init(55) <= ('1' & "00010110");
      reg_init(56) <= ('1' & "00000110");
      reg_init(57) <= ('1' & "00001101");
      reg_init(58) <= ('1' & "00101101");
      reg_init(59) <= ('1' & "00100110");
      reg_init(60) <= ('1' & "00100011");
      reg_init(61) <= ('1' & "00100111");
      reg_init(62) <= ('1' & "00100111");
      reg_init(63) <= ('1' & "00100101");
      reg_init(64) <= ('1' & "00101101");
      reg_init(65) <= ('1' & "00111011");
      reg_init(66) <= ('1' & "00000000");
      reg_init(67) <= ('1' & "00000001");
      reg_init(68) <= ('1' & "00000100");
      reg_init(69) <= ('1' & "00010011");
      reg_init(70) <= ('0' & "00111010");
      reg_init(71) <= ('1' & "00000101");
      reg_init(72) <= ('0' & "00101001");
   END PROCESS;
   
   
END behave;


