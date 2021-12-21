 LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

entity seg_display is
    generic (
        CLK_DIV_PERIOD : integer := 500; --related WITH clk_div's frequency
        DELAY_PERIOD : integer := 5000; --related WITH delay TIME AND refresh frequency

        constant CLK_L : std_logic_vector(1 downto 0) := "00";
        constant CLK_H : std_logic_vector(1 downto 0) := "01";
        constant CLK_RISING_EDGE : std_logic_vector(1 downto 0) := "10";
        constant CLK_FALLING_EDGE : std_logic_vector(1 downto 0) := "11";
        constant IDLE : std_logic_vector(2 downto 0) := "000";
        constant WRITE : std_logic_vector(2 downto 0) := "001";
        constant DELAY : std_logic_vector(2 downto 0) := "010";
        constant LOW : std_logic := '0';
        constant HIGH : std_logic := '1'
    );
    port (
        clk_in : in std_logic; --
        rst_n_in : in std_logic; --active with low
        num_in : in std_logic_vector(23 downto 0);
        rclk_out : out std_logic; --74HC595 RCK
        sclk_out : out std_logic; --74HC595 SCK
        sdio_out : out std_logic;--74HC595 SER
        change_dot   : in  std_logic
    );
end seg_display;

architecture trans OF seg_display is
    type new_array is array(15 downto 0) OF std_logic_vector(7 downto 0);
    signal mem : new_array;

    signal clk_div : std_logic;
    signal clk_cnt : std_logic_vector(15 downto 0) := "0000000000000000";

    signal clk_div_state : std_logic_vector(1 downto 0) := CLK_L;

    signal shift_flag : std_logic := '0';
    signal data_reg : std_logic_vector(15 downto 0);                                                                                                                          
    signal data_state : std_logic_vector(2 downto 0) := IDLE;
    signal data_state_back : std_logic_vector(2 downto 0);
    signal data_state_cnt : std_logic_vector(3 downto 0) := "0000";
    signal shift_cnt : std_logic_vector(5 downto 0) := "000000";
    signal delay_cnt : std_logic_vector(25 downto 0) := "00000000000000000000000000";
begin
    
        mem(0) <= "00111111";
        mem(1) <= "00000110";
        mem(2) <= "01011011";
        mem(3) <= "01001111";
        mem(4) <= "01100110";
        mem(5) <= "01101101";
        mem(6) <= "01111101";
        mem(7) <= "00000111";
        mem(8) <= "01111111";
        mem(9) <= "01101111";
        mem(10) <= "01110111";
        mem(11) <= "01111100";
        mem(12) <= "00111001";
        mem(13) <= "01011110";
        mem(14) <= "01111001";
        mem(15) <= "00000000";


    process (clk_in, rst_n_in)
    begin
        if (rst_n_in = '0') then
            clk_cnt <= "0000000000000000";
        ELSif (rising_edge(clk_in)) then
            clk_cnt <= clk_cnt + "0000000000000001";
            if (clk_cnt = (CLK_DIV_PERIOD - 1)) then
                clk_cnt <= "0000000000000000";
            end if;
            if (clk_cnt < (CLK_DIV_PERIOD/2)) then
                clk_div <= '0';
            else
                clk_div <= '1';
            end if;
        end if;
    end process;

    process (clk_in, rst_n_in)
    begin
        if (rst_n_in = '0') then
            clk_div_state <= CLK_L;
        ELSif (rising_edge(clk_in)) then
            case clk_div_state is
                when CLK_L =>
                    if (clk_div = '1') then
                        clk_div_state <= CLK_RISING_EDGE;
                    else
                        clk_div_state <= CLK_L;
                    end if;
                when CLK_RISING_EDGE =>
                    clk_div_state <= CLK_H;
                when CLK_H =>
                    if (clk_div = '0') then
                        clk_div_state <= CLK_FALLING_EDGE;
                    else
                        clk_div_state <= CLK_H;
                    end if;
                when CLK_FALLING_EDGE =>
                    clk_div_state <= CLK_L;
                when others =>
            end case;
        end if;
    end process;

    process (clk_in, rst_n_in)
    begin
        if (rst_n_in = '0') then
            data_state <= IDLE;
            data_state_cnt <= "0000";
        ELSif (rising_edge(clk_in)) then
            case data_state is
                when IDLE =>
                    data_state_cnt <= data_state_cnt + "0001";
                    case data_state_cnt is
                        when "0000" =>
                            data_reg <= (mem(conv_integer(num_in(23 downto 20))) & "11111110");
                            data_state <= WRITE;
                            data_state_back <= IDLE;
                        when "0001" =>
                            case change_dot is
							when '1' =>
                                data_reg <= ((mem(conv_integer(num_in(19 downto 16)))OR"10000000") & "11111101");								
                                data_state <= WRITE;
                                data_state_back <= IDLE;
                            when '0'=>
                                data_reg <= ((mem(conv_integer(num_in(19 downto 16)))) & "11111101");								
                                data_state <= WRITE;
                                data_state_back <= IDLE;
							when others=>
							end case;
                        when "0010" =>
                            data_reg <= (mem(conv_integer(num_in(15 downto 12))) & "11111011");
                            data_state <= WRITE;
                            data_state_back <= IDLE;
                        when "0011" =>
                            data_reg <= (mem(conv_integer(num_in(11 downto 8))) & "11110111");
                            data_state <= WRITE;
                            data_state_back <= IDLE;
                        when "0100" =>
                            data_reg <= (mem(conv_integer(num_in(7 downto 4))) & "11101111");
                            data_state <= WRITE;
                            data_state_back <= IDLE;
                        when "0101" =>
                            data_reg <= (mem(conv_integer(num_in(3 downto 0))) & "11011111");
                            data_state <= WRITE;
                            data_state_back <= IDLE;
                        when "0110" =>
                            data_state <= DELAY;
                            data_state_back <= IDLE;
                        when "0111" =>
                            data_state_cnt <= "0000";
                        when others =>
                    end case;
                when WRITE =>
                    if (shift_flag = '0') then
                        if (clk_div_state = CLK_FALLING_EDGE) then
                            if (shift_cnt = "001010") then
                                rclk_out <= LOW;
                            end if;
                            if (shift_cnt = "010000") then
                                shift_cnt <= "000000";
                                rclk_out <= HIGH;
                                data_state <= data_state_back;
                            else
                                sclk_out <= LOW;
                                sdio_out <= data_reg(15);
                                shift_flag <= '1';
                            end if;
                        end if;
                    else
                        if (clk_div_state = CLK_RISING_EDGE) then
                            data_reg <= (data_reg(14 downto 0) & data_reg(15));
                            shift_cnt <= shift_cnt + "000001";
                            sclk_out <= HIGH;
                            shift_flag <= '0';
                        end if;
                    end if;
                when DELAY =>
                    if (delay_cnt = DELAY_PERIOD) then
                        data_state <= IDLE;
                        delay_cnt <= "00000000000000000000000000";
                    else
                        delay_cnt <= delay_cnt + "00000000000000000000000001";
                    end if;
                when others =>
            end case;
        end if;
    end process;

end trans;