library ieee;  
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--显示

entity statemachine is
port
(
	CLK_div1					:inout std_logic;
	CLK_div2					:inout std_logic;
	btn 						:in STD_LOGIC_VECTOR(3 DOWNTO 0);
    light1,light2				:out std_logic_vector(2 downto 0);
	l							:inout INTEGER;
	h							:inout INTEGER
	);
end entity;

architecture statemachine_arch of statemachine is
	CONSTANT long : INTEGER := 12; 
	CONSTANT short : INTEGER := 6;
    signal mode : integer range 1 to 3:=1;
    type state is (zero,one,two,three,four,five,six,seven);
    signal pr_state,nx_state: state:=zero;
	

begin

  process(clk_div2)
    begin
        if(clk_div2 'event and clk_div2='1') then
            pr_state <= nx_state;
        end if;
    end process;

    --light mode
    PROCESS (clk_div1)
    BEGIN
        if (clk_div1'event and clk_div1='1') THEN
            if btn = "1110" then	
                mode <= 1;
            elsif btn = "1101" then
                mode <= 2;
            elsif btn = "1011" then
                
				mode <= 3;
            else
                mode <= mode;
            end if;
        end if;
    end process;
 
    --traffic light
    process(clk_div1)
	variable count: integer range 0 to 6000:=0;

    begin
		if (clk_div2'event and clk_div2='1') then
		   
		case mode is 
			when 1 =>
				case pr_state is
					when zero=>
						light1<="101";light2<="011";
						h<=0;l<=0;
						nx_state<=one;
					when one=>
						 --green red
						
						h<=0;l<=0;
						
						if count=long then
							count:=0;
							light1<="001";light2<="011";--准备转黄红
							nx_state<=two;
						else
							count:=count+1;
							if l<9 then
								l<=l+1;
								h<=h;
							else
								h<=h+1;
								l<=0;
							end if;
						end if;
					when two=>
							 --yellow red
							
							h<=0;l<=0;
						if count=2 then
							count:=0;
							light1<="011";light2<="101";--准备转红绿
							nx_state<=three;
						else
							count:=count+1;
							h<=0;
							l<=l+1;

		
						end if;
					when three=>
							
							 --red green
							h<=0;l<=0;
						if count=long then
							count:=0;
							light1<="011";light2<="001"; --准备转红黄
							nx_state<=four;
						else
							count:=count+1;
							if l<9 then
								h<=h;
								l<=l+1;
							else
								h<=h+1;
								l<=0;
							end if;
						end if;
					when four=>
					    h<=0;l<=0;
						if count=2 then
							count:=0;
							light1<="101";light2<="011";--准备转绿红
							nx_state<=one;
						else
							count:=count+1;
							h<=0;
							l<=l+1;
						end if;
					when others=>
						nx_state<=zero;
						count:=0;
				end case;
			when 2 =>
				case pr_state is
					when zero=>
						light1<="101";light2<="011";
						h<=0;l<=0;
						nx_state<=one;
					
					when one=>
						 --green red
						
						h<=0;l<=0;
						
						if count=long then
							count:=0;
							light1<="001";light2<="011";--准备转黄红
							nx_state<=two;
						else
							count:=count+1;
							if l<9 then
								l<=l+1;
								h<=h;
							else
								h<=h+1;
								l<=0;
							end if;
						end if;
					when two=>
							 --yellow red
							
							h<=0;l<=0;
						if count=2 then
							count:=0;
							light1<="011";light2<="101";--准备转红绿
							nx_state<=five;
						else
							count:=count+1;
							h<=0;
							l<=l+1;

		
						end if;
					when five=>
							
							 --red green
							h<=0;l<=0;
						if count=short then
							count:=0;
							light1<="011";light2<="001"; --准备转红黄
							nx_state<=four;
						else
							count:=count+1;
							if l<9 then
								h<=h;
								l<=l+1;
							else
								h<=h+1;
								l<=0;
							end if;
						end if;
					when four=>
					    h<=0;l<=0;
						if count=2 then
							count:=0;
							light1<="101";light2<="011";--准备转绿红
							nx_state<=one;
						else
							count:=count+1;
							h<=0;
							l<=l+1;
						end if;
					when others=>
						nx_state<=zero;
						count:=0;
				end case;
			
		
			when 3 =>
				h<=0;l<=0;
				case pr_state is
					when six=>
						light1<="001";light2<="001"; --yellow yellow
						if count=1 then
							count:=0;
							nx_state<=seven;
						else
							count:=count+1;
						end if;
					when seven=>
						light1<="111";light2<="111"; --none
						if count=1 then
							count:=0;
							nx_state<=six;
						else
							count:=count+1;
						end if;
					when others=>
						nx_state<=six;
						count:=0;
				end case;
			when others=>NULL;
			end case;
		end if;
		
    end process;
	
	

end statemachine_arch;