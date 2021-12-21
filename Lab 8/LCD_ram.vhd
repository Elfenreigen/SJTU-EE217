LIBRARY ieee;
   USE ieee.std_logic_1164.all;
   USE ieee.std_logic_unsigned.all;
   USE IEEE.Std_Logic_Arith.ALL;

--LCD_ram is the memory ram whose unit means the pixel state (background '0' or typrface '1') correspond to the internal ram of LCD

entity ram is

--'we' is the enable signal for outputting the date
--'din' is 5 BCD code
port
(
	clk : in std_logic;
	addr : in std_logic_vector(7 downto 0);
	we : in std_logic;
	din : in std_logic_vector(19 downto 0);
	dout : out std_logic_vector(127 downto 0)
);

end ram;

architecture Behavioral of ram is

--RamType is the ram type for data storage as we all known
--nums is the type for digital dot matrix to display numbers
--dots is the type for digital dot matrix to display dots
type RamType is array(255 downto 0) of std_logic_vector(127 downto 0);
type nums IS ARRAY (15 DOWNTO 0) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
type dots IS ARRAY (15 DOWNTO 0) OF STD_LOGIC_VECTOR(7 DOWNTO 0);

--instantiate the signal
signal num0,num1,num2,num3,num4,num5,num6,num7,num8,num9 :nums;
signal dot :dots;
signal ram : RamType;

signal display4,display3,display2,display1,display0 :nums;
signal display_dot :dots;
signal display4_num,display3_num,display2_num,display1_num,display0_num :std_logic_vector(3 downto 0);
begin

display4_num <=din(19 downto 16);
display3_num <=din(15 downto 12);
display2_num <=din(11 downto 8);
display1_num <=din(7 downto 4);
display0_num <=din(3 downto 0);

----------output the corresponding data when "we ='1'"----------
process(clk)

begin
	if clk'event and clk = '1' then
		if we = '1' then
			dout <= ram(conv_integer(addr));
		end if;
	end if;
end process;

----------assign the ram with the digital dot matrix in a specific location----------
process(clk)

--due to the fact that the order of LCD x-scan is inverse, we adopt the loop nesting method
begin
	for i in 0 to 255 loop
		for j in 0 to 127 loop
			if (i<63) then
				ram(i)(127-j)<= '0';
			elsif (i>80)then
				ram(i)(127-j)<= '0';
			else
				ram(i)(127-j)<='0';
				if(i>=63 and j>=4 and i<=80 and j<=19) then
					if(display0(i-63)(j-4)='1') then
						ram(i)(127-j) <= '1';
					end if;
				end if;
				if(i>=63 and j>=26 and i<=80 and j<=41) then
					if(display1(i-63)(j-26)='1') then
						ram(i)(127-j) <= '1';
					end if;
				end if;
				if(i>=63 and j>=48 and i<=80 and j<=63) then
					if(display2(i-63)(j-48)='1') then
						ram(i)(127-j) <= '1';
					end if;
				end if;
				if(i>=63 and j>=70 and i<=80 and j<=85) then
					if(display3(i-63)(j-70)='1') then
						ram(i)(127-j) <= '1';
					end if;
				end if;
				if(i>=63 and j>=86 and i<=80 and j<=93) then
					if(display_dot(i-63)(j-86)='1') then
						ram(i)(127-j) <= '1';
					end if;
				end if;
				if(i>=63 and j>=94 and i<=80 and j<=119) then
					if(display4(i-63)(j-94)='1') then
						ram(i)(127-j) <= '1';
					end if;
				end if;
			end if;
		end loop;
	end loop;
end process;

----------convert the BCD code to digital dot matrix form for ram storage----------
process(clk)
begin

	display_dot<=dot;

	case(display4_num)  is
		when "0000"=> display4 <= num0;
		when "0001"=> display4 <= num1;
		when "0010"=> display4 <= num2;
		when "0011"=> display4 <= num3;
		when "0100"=> display4 <= num4;
		when "0101"=> display4 <= num5;
		when "0110"=> display4 <= num6;
		when "0111"=> display4 <= num7;
		when "1000"=> display4 <= num8;
		when "1001"=> display4 <= num9;
	end case;
	
	case(display3_num)  is
		when "0000"=> display3 <= num0;
		when "0001"=> display3 <= num1;
		when "0010"=> display3 <= num2;
		when "0011"=> display3 <= num3;
		when "0100"=> display3 <= num4;
		when "0101"=> display3 <= num5;
		when "0110"=> display3 <= num6;
		when "0111"=> display3 <= num7;
		when "1000"=> display3 <= num8;
		when "1001"=> display3 <= num9;
	end case;
	
	case(display2_num)  is
		when "0000"=> display2 <= num0;
		when "0001"=> display2 <= num1;
		when "0010"=> display2 <= num2;
		when "0011"=> display2 <= num3;
		when "0100"=> display2 <= num4;
		when "0101"=> display2 <= num5;
		when "0110"=> display2 <= num6;
		when "0111"=> display2 <= num7;
		when "1000"=> display2 <= num8;
		when "1001"=> display2 <= num9;
	end case;
	
	case(display1_num)  is
		when "0000"=> display1 <= num0;
		when "0001"=> display1 <= num1;
		when "0010"=> display1 <= num2;
		when "0011"=> display1 <= num3;
		when "0100"=> display1 <= num4;
		when "0101"=> display1 <= num5;
		when "0110"=> display1 <= num6;
		when "0111"=> display1 <= num7;
		when "1000"=> display1 <= num8;
		when "1001"=> display1 <= num9;
	end case;
	
	case(display0_num)  is
		when "0000"=> display0 <= num0;
		when "0001"=> display0 <= num1;
		when "0010"=> display0 <= num2;
		when "0011"=> display0 <= num3;
		when "0100"=> display0 <= num4;
		when "0101"=> display0 <= num5;
		when "0110"=> display0 <= num6;
		when "0111"=> display0 <= num7;
		when "1000"=> display0 <= num8;
		when "1001"=> display0 <= num9;
	end case;

end process;

----------store the digital dot matrix for each number and dot----------
   PROCESS 
   BEGIN
		num0(0)   <= "0001111111111000";
		num0(1)   <= "0011111111111100";
		num0(2)   <= "0111111111111110";
		num0(3)   <= "1110000000000111";
		num0(4)   <= "1110000000000111";
		num0(5)   <= "1110000000000111";
		num0(6)   <= "1110000000000111";
		num0(7)   <= "1110000000000111";
		num0(8)   <= "1110000000000111";
		num0(9)   <= "1110000000000111";
		num0(10) <= "1110000000000011";
		num0(11) <= "1110000000000011";
		num0(12) <= "1110000000000011";
		num0(13) <= "0111111111111110";
		num0(14) <= "0011111111111100";
		num0(15) <= "0001111111111000";

   END PROCESS;


   PROCESS 
   BEGIN
		num1(0)   <= "0000000001000000";
		num1(1)   <= "0000000111000000";
		num1(2)   <= "0000011111000000";
		num1(3)   <= "0001111111000000";
		num1(4)   <= "0000000111000000";
		num1(5)   <= "0000000111000000";
		num1(6)   <= "0000000111000000";
		num1(7)   <= "0000000111000000";
		num1(8)   <= "0000000111000000";
		num1(9)   <= "0000000111000000";
		num1(10) <= "0000000111000000";
		num1(11) <= "0000000111000000";
		num1(12) <= "0000000111000000";
		num1(13) <= "0000011111110000";
		num1(14) <= "0001111111111000";
		num1(15) <= "0001111111111000";

   END PROCESS;

   PROCESS 
   BEGIN
		num2(0)   <= "0001111111111000";
		num2(1)   <= "0011111111111100";
		num2(2)   <= "1111111111111111";
		num2(3)   <= "1110000000000111";
		num2(4)   <= "1110000000000111";
		num2(5)   <= "0000000000000111";
		num2(6)   <= "0000000000000111";
		num2(7)   <= "1111111111111111";
		num2(8)   <= "1111111111111111";
		num2(9)   <= "1111111111111111";
		num2(10) <= "1110000000000000";
		num2(11) <= "1110000000000000";
		num2(12) <= "1110000000000000";
		num2(13) <= "1111111111111111";
		num2(14) <= "0011111111111100";
		num2(15) <= "0001111111111000";

   END PROCESS;

   PROCESS 
   BEGIN
		num3(0)   <= "0001111111111000";
		num3(1)   <= "0011111111111100";
		num3(2)   <= "0111000000001110";
		num3(3)   <= "1110000000000111";
		num3(4)   <= "0000000000001110";
		num3(5)   <= "0000000001111100";
		num3(6)   <= "0000011111110000";
		num3(7)   <= "0000011111110000";
		num3(8)   <= "0000011111110000";
		num3(9)   <= "0000000001111100";
		num3(10) <= "0000000000001110";
		num3(11) <= "0000000000000111";
		num3(12) <= "1110000000000111";
		num3(13) <= "0111000000001110";
		num3(14) <= "0011111111111100";
		num3(15) <= "0001111111111000";

   END PROCESS;

   PROCESS 
   BEGIN
		num4(0)   <= "0000000001111000";
		num4(1)   <= "0000000011111000";
		num4(2)   <= "0000000110111000";
		num4(3)   <= "0000001110111000";
		num4(4)   <= "0000011100111000";
		num4(5)   <= "0000111000111000";
		num4(6)   <= "0001110000111000";
		num4(7)   <= "0011111111111111";
		num4(8)   <= "0111111111111111";
		num4(9)   <= "1111111111111111";
		num4(10) <= "0000000000111000";
		num4(11) <= "0000000000111000";
		num4(12) <= "0000000000111000";
		num4(13) <= "0000000000111000";
		num4(14) <= "0000000000111000";
		num4(15) <= "0000000000111000";

   END PROCESS;

   PROCESS 
   BEGIN
		num5(0)   <= "0011111111111110";
		num5(1)   <= "0011111111111110";
		num5(2)   <= "0011111111111110";
		num5(3)   <= "0011100000000000";
		num5(4)   <= "0011100000000000";
		num5(5)   <= "0011100000000000";
		num5(6)   <= "0011111111111000";
		num5(7)   <= "0011111111111100";
		num5(8)   <= "0001111111111100";
		num5(9)   <= "0000000000001110";
		num5(10) <= "0000000000001110";
		num5(11) <= "0000000000001110";
		num5(12) <= "0000000000001110";
		num5(13) <= "0011111111111110";
		num5(14) <= "0011111111111100";
		num5(15) <= "0011111111111000";

   END PROCESS;


   PROCESS 
   BEGIN
		num6(0)   <= "0000111111110000";
		num6(1)   <= "0001111111111000";
		num6(2)   <= "0011111111111100";
		num6(3)   <= "0111000000001110";
		num6(4)   <= "1110000000000111";
		num6(5)   <= "1110000000000000";
		num6(6)   <= "1110011111111000";
		num6(7)   <= "1110111111111100";
		num6(8)   <= "1111111000001110";
		num6(9)   <= "1111110000000111";
		num6(10) <= "1110000000000111";
		num6(11) <= "1110000000000111";
		num6(12) <= "0111000000001110";
		num6(13) <= "0011100000011100";
		num6(14) <= "0001111111111000";
		num6(15) <= "0000111111110000";

   END PROCESS;

   PROCESS 
   BEGIN
		num7(0)   <= "1111111111111111";
		num7(1)   <= "1111111111111111";
		num7(2)   <= "1111111111111111";
		num7(3)   <= "1110000000001110";
		num7(4)   <= "1110000000011100";
		num7(5)   <= "0000000000111000";
		num7(6)   <= "0000000001110000";
		num7(7)   <= "0000000001110000";
		num7(8)   <= "0000000001110000";
		num7(9)   <= "0000000001110000";
		num7(10) <= "0000000001110000";
		num7(11) <= "0000000001110000";
		num7(12) <= "0000000001110000";
		num7(13) <= "0000000001110000";
		num7(14) <= "0000000001110000";
		num7(15) <= "0000000001110000";

   END PROCESS;

   PROCESS 
   BEGIN
        num8(0)   <= "0001111111111000";
        num8(1)   <= "0011111111111100";
        num8(2)   <= "0111111111111110";
        num8(3)   <= "1110000000000111";
        num8(4)   <= "1110000000000111";
        num8(5)   <= "1110000000000111";
        num8(6)   <= "1110000000000111";
        num8(7)   <= "0111111111111110";
        num8(8)   <= "0111111111111110";
        num8(9)   <= "1110000000000111";
        num8(10) <= "1110000000000111";
        num8(11) <= "1110000000000111";
        num8(12) <= "1110000000000111";
        num8(13) <= "0111000000001110";
        num8(14) <= "0011111111111100";
        num8(15) <= "0001111111111000";

   END PROCESS;

	PROCESS 
    BEGIN
		num9(0)   <= "0001111111111000";
		num9(1)   <= "0011111111111100";
		num9(2)   <= "0111111111111110";
		num9(3)   <= "1110000000000111";
		num9(4)   <= "1110000000000111";
		num9(5)   <= "1110000000000111";
		num9(6)   <= "1110000000000111";
		num9(7)   <= "0111111111111110";
		num9(8)   <= "0111111111111110";
		num9(9)   <= "0000000000000111";
		num9(10) <= "0000000000000111";
		num9(11) <= "0000000000000111";
		num9(12) <= "1110000000000111";
		num9(13) <= "0111000000001110";
		num9(14) <= "0011111111111100";
		num9(15) <= "0001111111111000";

   END PROCESS;


   PROCESS 
   BEGIN
		dot(0)   <= "00000000";
		dot(1)   <= "00000000";
		dot(2)   <= "00000000";
		dot(3)   <= "00000000";
		dot(4)   <= "00000000";
		dot(5)   <= "00000000";
		dot(6)   <= "00000000";
		dot(7)   <= "00000000";
		dot(8)   <= "00000000";
		dot(9)   <= "00000000";
		dot(10) <= "00000000";
		dot(11) <= "00000000";
		dot(12) <= "00111000";
		dot(13) <= "00111000";
		dot(14) <= "00111000";
		dot(15) <= "00000000";

   END PROCESS;

end Behavioral;