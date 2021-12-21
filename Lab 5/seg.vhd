library ieee;
use ieee.std_logic_1164.all;
entity seg is
port
(
	CLK						:in std_logic;--12MHz
	tone					:in integer range 0 to 10;
	en     					:out std_logic;--segdig1
	digit					:out std_logic_vector(7 downto 0)--ºËÐÄ°åÊýÂë¹Ü 
);
end entity;

architecture seg_arch of seg is
begin
process (clk)
 begin
 if rising_edge(clk) then
 case tone is
 when 1=> digit <= "00000110";--1
 when 2=> digit <= "01011011";--2
 when 3=> digit <= "01001111";--3
 when 4=> digit <= "01100110";--4
 when 5=> digit <= "01101101";--5
 when 6=> digit <= "01111101";--6
 when 7=> digit <= "00000111";--7
 when 8=> digit <= "01111111";--8
 when 9=> digit <= "01101111";--9
 when 10=> digit <= "00111111";--10
 when others=> digit <="00000000";
 end case;
 end if;
 en<='0';
end process;
end seg_arch;