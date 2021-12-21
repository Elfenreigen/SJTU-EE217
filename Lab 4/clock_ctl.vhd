library ieee;  
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--Mode Selection


entity clock_ctl is
port
(
	modeSelect_stable			:in std_logic;--Mode Selection After Debounce
	mode						:inout integer:=1--Mode
);
end entity;


architecture clock_ctl_arch of clock_ctl is
begin

clock_ctl:process(modeSelect_stable)
begin
	if falling_edge(modeSelect_stable) then
		mode<=(mode+1) mod 4;
	end if;
end process;

end clock_ctl_arch;