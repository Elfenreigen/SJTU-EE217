LIBRARY ieee;
   USE ieee.std_logic_1164.all;
   USE ieee.std_logic_arith.all;
   USE ieee.std_logic_unsigned.all;

   
entity bin_2_BCD is
   port (
      clk       : in std_logic;
      rst       : in std_logic;
      binary    : in std_logic_vector(15 downto 0);
      BCD       : out std_logic_vector(19 downto 0)
   );
end bin_2_BCD;

architecture a of bin_2_BCD is

    signal count  :integer:=0;
    signal tmp   :std_logic_vector(35 downto 0);
begin

    process (clk,rst)
    begin
       if((not(rst)) = '1') then
           tmp<="000000000000000000000000000000000000";
       elsif rising_edge(clk) then
           
           if count=0 then
              tmp<="00000000000000000000"&binary;
		   end if;
		   
           if (count>=1 and count<=31) then
                
              if(conv_std_logic_vector(count,6)(0)='1') then       
                tmp<=tmp(34 downto 0)&'0';
              end if;

              if(conv_std_logic_vector(count,6)(0)='0') then
                
                if tmp(35 downto 32)>="0101" then
                    tmp(35 downto 32)<=tmp(35 downto 32)+"0011";
                end if;
                if tmp(31 downto 28)>="0101" then
                    tmp(31 downto 28)<=tmp(31 downto 28)+"0011";
                end if;
                if tmp(27 downto 24)>="0101" then
                    tmp(27 downto 24)<=tmp(27 downto 24)+"0011";
                end if;
                if tmp(23 downto 20)>="0101" then
                    tmp(23 downto 20)<=tmp(23 downto 20)+"0011";
                end if;
                if tmp(19 downto 16)>="0101" then
                    tmp(19 downto 16)<=tmp(19 downto 16)+"0011";
                end if;
                
              end if;  
			
			end if;
			
			if count=32 then
                BCD<=tmp(35 downto 16);
		    end if ;
			
        end if;
    end process;


    process (clk,rst)
    begin
       if((not(rst)) = '1') then
           count<=0;
       elsif rising_edge(clk) then
           
           if count<33 then
              count<=count+1;
           else
              count<=0;
		   end if;
        end if;
    end process;




end a; 


           