library ieee;  
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--显示

entity freqdivider is
port
(
	CLK							:in std_logic;--12MHz
	CLK_div1					:inout std_logic;
	CLK_div2					:inout std_logic;
	CLK_div3					:inout std_logic 	
);
end entity;

architecture freqdivider_arch of freqdivider is
	CONSTANT CLK_led : INTEGER := 6000000; --elated with clk_div's frequency
	CONSTANT CLK_btn : INTEGER := 40000; --elated with clk_div's frequency
	CONSTANT CLK_seg : INTEGER := 400; --elated with clk_div2's frequency

begin
PROCESS (clk)
	VARIABLE clk_div_counter1 : INTEGER RANGE 1 TO CLK_btn;--CONSTANT CLK_DIV_PERIOD : INTEGER := 400
	VARIABLE clk_div_counter2 : INTEGER RANGE 1 TO CLK_led;
	VARIABLE clk_div_counter3 : INTEGER RANGE 1 TO CLK_seg;
    BEGIN
			IF (clk 'event AND clk = '1') THEN
				clk_div_counter1 := clk_div_counter1 + 1;
				IF (clk_div_counter1 = CLK_btn) THEN
					clk_div1 <= NOT clk_div1;------------生成分频后时钟信号clk_div2
					clk_div_counter1 := 1;
				END IF;
				clk_div_counter2 := clk_div_counter2 + 1;
				IF (clk_div_counter2 = CLK_led) THEN
					clk_div2 <= NOT clk_div2;------------生成分频后时钟信号clk_div2
					clk_div_counter2 := 2;
				END IF;
				--divider for keyboard
				clk_div_counter3 := clk_div_counter3 + 1;
				IF (clk_div_counter3 = CLK_seg) THEN
					clk_div3 <= NOT clk_div3;------------生成分频后时钟信号clk_div2
					clk_div_counter3 := 1;
				END IF;
        END IF;
    END PROCESS;

end freqdivider_arch;