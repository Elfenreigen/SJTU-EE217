library ieee;  
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--显示

entity keyboard is
port
(
	CLK_div2						: IN std_logic;
	column 							: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	row 							: BUFFER STD_LOGIC_VECTOR(3 DOWNTO 0);
	key_code 						: BUFFER INTEGER RANGE 0 TO 21;
	btn 							: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	l								: OUT integer:=0;
	h								: OUT integer:=0
	);
end entity;

architecture keyboard_arch of keyboard is
	TYPE key_state_enum IS(row0, row1, row2, row3);
	SIGNAL key_num : STD_LOGIC_VECTOR(7 DOWNTO 0);
begin
	PROCESS (clk_div2)
		VARIABLE key_state : key_state_enum := row0;
	BEGIN
		IF (clk_div2 'event AND clk_div2 = '1') THEN
			CASE key_state IS
				WHEN row0 =>--按行依次拉低
					row <= "1110";
					key_state := row1;
				WHEN row1 =>
					row <= "1101";
					key_state := row2;
				WHEN row2 =>
					row <= "1011";
					key_state := row3;
				WHEN row3 =>
					row <= "0111";
					key_state := row0;
				WHEN OTHERS =>
					row <= "1110";
					key_state := row1;
			END CASE;
		END IF;
	END PROCESS;
	key_num <= row & column;

	--read the key
		PROCESS (clk_div2)
	BEGIN
		IF (clk_div2'event AND clk_div2 = '1') THEN
			IF btn = "1110" THEN
				key_code <= 17;
			ELSIF btn = "1101" THEN
				key_code <= 18;
			ELSIF btn = "1011" THEN
				key_code <= 19;
			ELSIF btn = "0111" THEN
				key_code <= 20;
			ELSE
				CASE key_num IS
					WHEN "11101110" => key_code <= 1;
					WHEN "11101101" => key_code <= 2;
					WHEN "11101011" => key_code <= 3;
					WHEN "11100111" => key_code <= 4;
					WHEN "11101111" => IF ((key_code <= 4 AND key_code >= 1) OR (key_code <= 20 AND key_code >= 17)) THEN
												key_code <= 0;
										END IF;

					WHEN "11011110" => key_code <= 5;
					WHEN "11011101" => key_code <= 6;
					WHEN "11011011" => key_code <= 7;
					WHEN "11010111" => key_code <= 8;
					WHEN "11011111" => IF ((key_code <= 8 AND key_code >= 5) OR (key_code <= 20 AND key_code >= 17)) THEN
											key_code <= 0;
										END IF;

					WHEN "10111110" => key_code <= 9;
					WHEN "10111101" => key_code <= 10;
					WHEN "10111011" => key_code <= 11;
					WHEN "10110111" => key_code <= 12;
					WHEN "10111111" => IF ((key_code <= 12 AND key_code >= 9) OR (key_code <= 20 AND key_code >= 17)) THEN
											key_code <= 0;
										END IF;

					WHEN "01111110" => key_code <= 13;
					WHEN "01111101" => key_code <= 14;
					WHEN "01111011" => key_code <= 15;
					WHEN "01110111" => key_code <= 16;
					WHEN "01111111" => IF ((key_code <= 16 AND key_code >= 13) OR (key_code <= 20 AND key_code >= 17)) THEN
											key_code <= 0;
										END IF;
					WHEN OTHERS => key_code <= key_code;
				END CASE;	
			END IF;
		END IF;
		
		IF (key_code < 10) THEN
			h<= 0;
			l<= key_code;
		ELSIF (key_code >= 10 AND key_code < 20) THEN
			h<= 1;
			l<= key_code - 10;
		ELSIF (key_code >= 20) THEN
			h<= 2;
			l<= key_code - 20;
		ELSE
			h<= 0;
			l<= 0;
		END IF;

		
	END PROCESS;

end keyboard_arch;