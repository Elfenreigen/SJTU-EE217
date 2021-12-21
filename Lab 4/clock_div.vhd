library ieee;  
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--Clk-Div


entity clk_div is
port
(
	CLK							:in std_logic;--12MHz
	CLK_divided					:inout std_logic;--1Hz
	CLK_20K						:inout std_logic --20KHz
);
end entity;


architecture clk_div_arch of clk_div is
signal cnt1						:integer:=0;--1Hz:Count Periods
signal cnt2						:integer:=0;--20KHz:Count Periods
begin

--1Hz
clock_div_1:process(ClK)
begin
	if rising_edge(CLK) then
		if cnt1=599999 then--Rectangular Waveform For Clk-Count
			clk_divided<=not clk_divided;
			cnt1<=0;
		else
			cnt1<=cnt1+1;
		end if;
	end if;
end process;



--20KHz
clock_div_20k:process(ClK)
begin
	if rising_edge(CLK) then
		if cnt2=599 then --595's working condition, whose waveform resembles Delta Function
			CLK_20K<='1';
			cnt2<=0;
		else
			cnt2<=cnt2+1;
			CLK_20K<='0';
		end if;
	end if;
end process;
end clk_div_arch;