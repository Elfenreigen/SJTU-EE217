library ieee;  
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--ËÄ¸öLEDµÆ¿ØÖÆ

entity led is
port
(
	mode						:in integer:=1;
	LEDs						:out std_logic_vector(3 downto 0)
);
end entity;

architecture led_arch of led is
begin

process(mode)
begin
	case mode is
		when 0=>--Count Mode£¬lighten 1st LED
			LEDs<="1110";
		when 1=>--Hour£¬lighten 2nd LED
			LEDs<="1101";
		when 2=>--Minute£¬lighten 3rd LED
			LEDs<="1011";
		when 3=>--Second£¬lighten 4th LED
			LEDs<="0111";
		when others=>
			LEDs<="1110";
	end case;
end process;

end led_arch;