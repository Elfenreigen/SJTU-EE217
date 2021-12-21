library ieee;  
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--Debounce


entity debounce is
port
(
	CLK						:in std_logic;--12MHz
	modeSelect				:in std_logic;--Mode Selection
	inc						:in std_logic;--Increase
	dec						:in std_logic;--Minus
	modeSelect_stable		:inout std_logic;--Stable
	inc_stable				:inout std_logic;--Stable
	dec_stable				:inout std_logic --Stable
);
end entity;


architecture debounce_arch of debounce is
constant delay				:integer:=120000; --10ms
begin


debounce_mode:process(modeSelect,CLK)
variable delay_cnt			:integer:=0;
begin
	if modeSelect='0' then
		if rising_edge(CLK) then
			if delay_cnt<delay then
				delay_cnt:=delay_cnt+1;
			else
				delay_cnt:=delay_cnt;
			end if;
			if delay_cnt<delay then
				modeSelect_stable<='1';
			else
				modeSelect_stable<='0';
			end if;
		end if;
	else
		delay_cnt:=0;
		modeSelect_stable<='1';
	end if;
end process;


debounce_inc:process(inc,CLK)
variable delay_cnt			:integer:=0;
begin
	if inc='0' then
		if rising_edge(CLK) then
			if delay_cnt<delay then
				delay_cnt:=delay_cnt+1;
			else
				delay_cnt:=delay_cnt;
			end if;
			if delay_cnt<delay then
				inc_stable<='1';
			else
				inc_stable<='0';
			end if;
		end if;
	else
		delay_cnt:=0;
		inc_stable<='1';
	end if;
end process;


debounce_dec:process(dec,CLK)
variable delay_cnt			:integer:=0;
begin
	if dec='0' then
		if rising_edge(CLK) then
			if delay_cnt<delay then
				delay_cnt:=delay_cnt+1;
			else
				delay_cnt:=delay_cnt;
			end if;
			if delay_cnt<delay then
				dec_stable<='1';
			else
				dec_stable<='0';
			end if;
		end if;
	else
		delay_cnt:=0;
		dec_stable<='1';
	end if;
end process;

end debounce_arch;