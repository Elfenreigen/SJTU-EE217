LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY ADC_I2C IS
   GENERIC (
      CNT_NUM : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000011110";

      IDLE : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
      MAIN : STD_LOGIC_VECTOR(2 DOWNTO 0) := "001";
      START : STD_LOGIC_VECTOR(2 DOWNTO 0) := "010";
      WRITE : STD_LOGIC_VECTOR(2 DOWNTO 0) := "011";
      READ : STD_LOGIC_VECTOR(2 DOWNTO 0) := "100";
      ACK_R : STD_LOGIC_VECTOR(2 DOWNTO 0) := "101";--读响应
      ACK_T : STD_LOGIC_VECTOR(2 DOWNTO 0) := "110";--写响应
      STOP : STD_LOGIC_VECTOR(2 DOWNTO 0) := "111"
   );
   PORT (
      clk_in : IN STD_LOGIC;
      rst_n_in : IN STD_LOGIC;
      scl_out : OUT STD_LOGIC;
      sda_out : INOUT STD_LOGIC;
      adc_done : OUT STD_LOGIC;
      adc_data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
   );
END ADC_I2C;

ARCHITECTURE trans OF ADC_I2C IS
   SIGNAL clk_200khz : STD_LOGIC;
   SIGNAL cnt_200khz : STD_LOGIC_VECTOR(9 DOWNTO 0);

   SIGNAL adc_data_r : STD_LOGIC_VECTOR(7 DOWNTO 0);

   SIGNAL scl_out_r : STD_LOGIC;
   SIGNAL sda_out_r : STD_LOGIC;
   SIGNAL cnt_main : STD_LOGIC_VECTOR(3 DOWNTO 0);
   SIGNAL data_wr : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL cnt_start : STD_LOGIC_VECTOR(1 DOWNTO 0);
   SIGNAL cnt_write : STD_LOGIC_VECTOR(4 DOWNTO 0);
   SIGNAL cnt_read : STD_LOGIC_VECTOR(4 DOWNTO 0);
   SIGNAL cnt_ack_r : STD_LOGIC_VECTOR(1 DOWNTO 0);
   SIGNAL cnt_ack_t : STD_LOGIC_VECTOR(1 DOWNTO 0);
   SIGNAL cnt_stop : STD_LOGIC_VECTOR(1 DOWNTO 0);
   SIGNAL state : STD_LOGIC_VECTOR(2 DOWNTO 0) := IDLE;
   SIGNAL state_back : STD_LOGIC_VECTOR(2 DOWNTO 0) := IDLE;
BEGIN
   PROCESS (clk_in, rst_n_in)
   BEGIN
      IF ((rst_n_in = '0')) THEN
         cnt_200khz <= "0000000000";
         clk_200khz <= '0';
      ELSIF (rising_edge(clk_in)) THEN
         IF (cnt_200khz >= CNT_NUM - "0000000001") THEN
            cnt_200khz <= "0000000000";
            clk_200khz <= NOT(clk_200khz);
         ELSE
            cnt_200khz <= cnt_200khz + "0000000001";
         END IF;
      END IF;
   END PROCESS;

   PROCESS (clk_200khz, rst_n_in)
   BEGIN
      IF (rst_n_in = '0') THEN
         scl_out_r <= '1';	
         sda_out_r <= '1';
         cnt_main <= "0000";
         cnt_start <= "00";
         cnt_write <= "00000";
         cnt_read <= "00000";
         cnt_ack_r <= "00";
         cnt_ack_t <= "00";
         cnt_stop <= "00";
         adc_done <= '0';
         state <= IDLE;
         state_back <= IDLE;
      ELSIF (rising_edge(clk_200khz)) THEN
         CASE state IS
            WHEN IDLE =>
               scl_out_r <= '1';
               sda_out_r <= '1';
               cnt_main <= "0000";
               cnt_start <= "00";
               cnt_write <= "00000";
               cnt_read <= "00000";
               cnt_ack_r <= "00";
               cnt_ack_t <= "00";
               cnt_stop <= "00";
               adc_done <= '0';
               state <= MAIN;
               state_back <= MAIN;
            WHEN MAIN =>
               IF (cnt_main >= "1011") THEN
                  cnt_main <= "0110";
               ELSE
                  cnt_main <= cnt_main + "0001";
               END IF;
               CASE cnt_main IS
                  WHEN "0000" =>
                     state <= START;--开始
                  WHEN "0001" =>
                     data_wr <= "10010000";
                     state <= WRITE;--写寻址
                  WHEN "0010" =>
                     state <= ACK_R;--读响应
                  WHEN "0011" =>
                     data_wr <= "01000000";
                     state <= WRITE;--写配置数据
                  WHEN "0100" =>
                     state <= ACK_R;--读响应
                  WHEN "0101" =>
                     state <= STOP;--结束
                  WHEN "0110" =>
                     state <= START;--开始
                  WHEN "0111" =>
                     data_wr <= "10010001";
                     state <= WRITE;--写寻址
                  WHEN "1000" =>
                     state <= ACK_R;--读响应
                  WHEN "1001" =>
                     state <= READ;--读ADC数据
                     adc_done <= '0';
                  WHEN "1010" =>
                     state <= ACK_T;--写响应
                     adc_done <= '1';
                  WHEN "1011" =>
                     state <= STOP;--结束
                  WHEN "1100" =>
                     state <= MAIN;
                  WHEN OTHERS =>
                     state <= IDLE;
               END CASE;
            WHEN START =>
               IF (cnt_start >= "10") THEN
                  cnt_start <= "00";
               ELSE
                  cnt_start <= cnt_start + "01";
               END IF;
               CASE cnt_start IS
                  WHEN "00" =>
                     sda_out_r <= '1';
                     scl_out_r <= '1';
                  WHEN "01" =>
                     sda_out_r <= '0';
                  WHEN "10" =>
                     scl_out_r <= '0';
                     state <= MAIN;
                  WHEN OTHERS =>
                     state <= IDLE;
               END CASE;
            WHEN WRITE =>
               IF (cnt_write >= "10000") THEN
                  cnt_write <= "00000";
               ELSE
                  cnt_write <= cnt_write + "00001";
               END IF;
               CASE cnt_write IS
                  WHEN "00000" =>
                     sda_out_r <= data_wr(7);
                     scl_out_r <= '0';
                  WHEN "00001" =>
                     scl_out_r <= '1';
                  WHEN "00010" =>
                     sda_out_r <= data_wr(6);
                     scl_out_r <= '0';
                  WHEN "00011" =>
                     scl_out_r <= '1';
                  WHEN "00100" =>
                     sda_out_r <= data_wr(5);
                     scl_out_r <= '0';
                  WHEN "00101" =>
                     scl_out_r <= '1';
                  WHEN "00110" =>
                     sda_out_r <= data_wr(4);
                     scl_out_r <= '0';
                  WHEN "00111" =>
                     scl_out_r <= '1';
                  WHEN "01000" =>
                     sda_out_r <= data_wr(3);
                     scl_out_r <= '0';
                  WHEN "01001" =>
                     scl_out_r <= '1';
                  WHEN "01010" =>
                     sda_out_r <= data_wr(2);
                     scl_out_r <= '0';
                  WHEN "01011" =>
                     scl_out_r <= '1';
                  WHEN "01100" =>
                     sda_out_r <= data_wr(1);
                     scl_out_r <= '0';
                  WHEN "01101" =>
                     scl_out_r <= '1';
                  WHEN "01110" =>
                     sda_out_r <= data_wr(0);
                     scl_out_r <= '0';
                  WHEN "01111" =>
                     scl_out_r <= '1';
                  WHEN "10000" =>
                     scl_out_r <= '0';
                     state <= MAIN;
                  WHEN OTHERS =>
                     state <= IDLE;
               END CASE;
            WHEN READ =>
               IF (cnt_read >= "10001") THEN
                  cnt_read <= "00000";
               ELSE
                  cnt_read <= cnt_read + "00001";
               END IF;
               CASE cnt_read IS
                  WHEN "00000" =>
                     scl_out_r <= '0';
                     sda_out_r <= 'Z';
                  WHEN "00001" =>
                     scl_out_r <= '1';
                     adc_data_r(7) <= sda_out;
                  WHEN "00010" =>
                     scl_out_r <= '0';
                  WHEN "00011" =>
                     scl_out_r <= '1';
                     adc_data_r(6) <= sda_out;
                  WHEN "00100" =>
                     scl_out_r <= '0';
                  WHEN "00101" =>
                     scl_out_r <= '1';
                     adc_data_r(5) <= sda_out;
                  WHEN "00110" =>
                     scl_out_r <= '0';
                  WHEN "00111" =>
                     scl_out_r <= '1';
                     adc_data_r(4) <= sda_out;
                  WHEN "01000" =>
                     scl_out_r <= '0';
                  WHEN "01001" =>
                     scl_out_r <= '1';
                     adc_data_r(3) <= sda_out;
                  WHEN "01010" =>
                     scl_out_r <= '0';
                  WHEN "01011" =>
                     scl_out_r <= '1';
                     adc_data_r(2) <= sda_out;
                  WHEN "01100" =>
                     scl_out_r <= '0';
                  WHEN "01101" =>
                     scl_out_r <= '1';
                     adc_data_r(1) <= sda_out;
                  WHEN "01110" =>
                     scl_out_r <= '0';
                  WHEN "01111" =>
                     scl_out_r <= '1';
                     adc_data_r(0) <= sda_out;
                  WHEN "10000" =>
                     scl_out_r <= '0';
                  WHEN "10001" =>
                     adc_data <= adc_data_r;
                     state <= MAIN;
                  WHEN OTHERS =>
                     state <= IDLE;
               END CASE;
            WHEN ACK_R =>
               IF (cnt_ack_r >= "11") THEN
                  cnt_ack_r <= "00";
               ELSE
                  cnt_ack_r <= cnt_ack_r + "01";
               END IF;
               CASE cnt_ack_r IS
                  WHEN "00" =>
                     sda_out_r <= 'Z';
                  WHEN "01" =>
                     scl_out_r <= '1';
                  WHEN "10" =>
                     IF (sda_out = '1') THEN
                        state <= IDLE;
                     ELSE
                        state <= state;
                     END IF;
                  WHEN "11" =>
                     scl_out_r <= '0';
                     state <= MAIN;
                  WHEN OTHERS =>
                     state <= IDLE;
               END CASE;
            WHEN ACK_T =>
               IF (cnt_ack_t >= "10") THEN
                  cnt_ack_t <= "00";
               ELSE
                  cnt_ack_t <= cnt_ack_t + "01";
               END IF;
               CASE cnt_ack_t IS
                  WHEN "00" =>
                     sda_out_r <= '1';
                  WHEN "01" =>
                     scl_out_r <= '1';
                  WHEN "10" =>
                     scl_out_r <= '0';
                     state <= MAIN;
                  WHEN OTHERS =>
                     state <= IDLE;
               END CASE;
            WHEN STOP =>
               IF (cnt_stop >= "10") THEN
                  cnt_stop <= "00";
               ELSE
                  cnt_stop <= cnt_stop + "01";
               END IF;
               CASE cnt_stop IS
                  WHEN "00" =>
                     sda_out_r <= '0';
                  WHEN "01" =>
                     scl_out_r <= '1';
                  WHEN "10" =>
                     sda_out_r <= '1';
                     state <= MAIN;
                  WHEN OTHERS =>
                     state <= IDLE;
               END CASE;
         END CASE;
      END IF;
   END PROCESS;
   
   scl_out <= scl_out_r;
   sda_out <= sda_out_r;

END trans;