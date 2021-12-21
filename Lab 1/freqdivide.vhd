library ieee;  
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--显示

entity freqdivide is
port
(
	CLK							:in std_logic;--12MHz
	CLK_div1					:inout std_logic;
	CLK_div2					:inout std_logic 
);
end entity;

architecture freqdivide_arch of freqdivide is
	--frequency part
	CONSTANT CLK_20k : INTEGER := 400; --elated with clk_div's frequency-20khz给数码管
	CONSTANT CLK_20MS : INTEGER := 40000; --elated with clk_div2's frequency
	SIGNAL FS : STD_LOGIC_VECTOR(15 DOWNTO 0);

begin
	PROCESS (clk)
		VARIABLE clk_div_counter1 : INTEGER RANGE 1 TO CLK_20k;--CONSTANT CLK_DIV_PERIOD : INTEGER := 400
		VARIABLE clk_div_counter2 : INTEGER RANGE 1 TO CLK_20ms;
	BEGIN
		IF (clk' event AND clk = '1') THEN--clk_in-C1
			--divider for 7 segment led
			clk_div_counter1 := clk_div_counter1 + 1;
			IF (clk_div_counter1 = CLK_20k) THEN
				clk_div1 <= NOT clk_div1;------------生成分频后时钟信号clk_div2
				clk_div_counter1 := 1;
			END IF;
			--divider for keyboard
			IF FS = CLK_20ms THEN
				FS <= "0000000000000000";
			ELSE
				FS <= FS + 1;
			END IF;
		END IF;
	END PROCESS;
	clk_div2 <= FS(15);

end freqdivide_arch;