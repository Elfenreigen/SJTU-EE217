library ieee;  
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--显示

entity freqdivider is
port
(
	CLK							:in std_logic;--12MHz
	CLK_div1					:inout std_logic;
	CLK_div2					:inout std_logic 
);
end entity;

architecture freqdivider_arch of freqdivider is
	CONSTANT CLK_breath		 		: INTEGER := 20000; --elated with clk_div2's frequency
	CONSTANT CLK_seg 				: INTEGER := 300; --elated with clk_div's frequency-20khz给数码管

begin
	PROCESS (clk)
	VARIABLE clk_div_counter1 : INTEGER RANGE 1 TO CLK_breath;--CONSTANT CLK_DIV_PERIOD : INTEGER := 400
	VARIABLE clk_div_counter2 : INTEGER RANGE 1 TO CLK_seg;
    BEGIN
			IF (clk 'event AND clk = '1') THEN
				clk_div_counter1 := clk_div_counter1 + 1;
				IF (clk_div_counter1 = CLK_breath) THEN
					clk_div1 <= NOT clk_div1;------------生成分频后时钟信号clk_div2
					clk_div_counter1 := 1;
				END IF;
				--divider for keyboard
				clk_div_counter2 := clk_div_counter2 + 1;
				IF (clk_div_counter2 = CLK_seg) THEN
					clk_div2 <= NOT clk_div2;------------生成分频后时钟信号clk_div2
					clk_div_counter2 := 1;
				END IF;
        END IF;
    END PROCESS;

end freqdivider_arch;