library ieee;
use ieee.std_logic_1164.all;
entity freqdivider is
port
(
	CLK						:in std_logic;--12MHz
	clk8hz					:inout std_logic;
	clk_10					:inout std_logic 
);
end entity;

architecture freqdivider_arch of freqdivider is
begin
---------8HZ Clock---------
process (clk)
variable cnt8hz :integer range 0 to 2000000;
begin
if rising_edge(clk) then------8Hz->0.125s
  if cnt8hz = 750000 then
    clk8hz <= not clk8hz;
	  cnt8hz := 0;
	else cnt8hz := cnt8hz + 1;
	end if;
end if;
end process;

---------10Hz Clock---------
process (clk)
variable count : integer :=0 ;
begin
if rising_edge(clk) then
  if(count = 20*30000-1) then   
    count := 0;
    clk_10 <= not clk_10;
  else
    count := count + 1;
  end if;
end if;
end process;


end freqdivider_arch;