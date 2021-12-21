LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY breathingled IS
    PORT (
        clk							: IN STD_LOGIC;
		fre_up						: IN STD_LOGIC;
		fre_down					: IN STD_LOGIC;
		strength_up					: IN STD_LOGIC;
		strength_down				: IN STD_LOGIC;
		rck 						: INOUT STD_LOGIC; --74HC595 RCK
		sck							: INOUT STD_LOGIC; --74HC595 SCK
		data						: INOUT STD_LOGIC; --串行发出的数据
        breathingled				: OUT STD_LOGIC
		);
END breathingled;

ARCHITECTURE breathingled_arch OF breathingled IS
	CONSTANT MAX_AMPLITUDE 			: INTEGER := 1200;
	CONSTANT MAX_STEP 				: INTEGER := 60;
	CONSTANT triangle_step 			: INTEGER := 1;
	SIGNAL clk_div1 				: STD_LOGIC;  --clk_div signal to keyboard
    SIGNAL clk_div2 				: STD_LOGIC ; --clk_div signal to keyboard
	SIGNAL l						: INTEGER:=5;
	SIGNAL h						: INTEGER:=5;

	
component Seg7 is
port
(
	CLK							:in std_logic;
	CLK_20K						:in std_logic;
	l							:in integer:=0;
	h							:in integer:=0;
	rck							:inout std_logic;
	sck							:inout std_logic;
	data						:inout std_logic
);
end component;
	
component freqdivider is
port
(
	CLK							:in std_logic;--12MHz
	CLK_div1					:inout std_logic;
	CLK_div2					:inout std_logic 
);
end component;	
	
component breathing is
port
(
	CLK_div1						:IN STD_LOGIC;--给呼吸灯
	fre_up							:IN STD_LOGIC;
	fre_down						:IN STD_LOGIC;
	strength_up						:IN STD_LOGIC;
	strength_down					:IN STD_LOGIC;
	l								:OUT INTEGER;
	h								:OUT INTEGER;
	breathingled					:OUT STD_LOGIC
);
end component;	
	
BEGIN

U1:Seg7 port map
(
	clk=>CLK,CLK_20K=>CLK_div2,l=>l,h=>h,rck=>rck,sck=>sck,data=>data
);
    --frequency divider

U2:freqdivider port map
(
	clk=>CLK,CLK_div1=>CLK_div1,CLK_div2=>CLK_div2
	);
    --frequency divider  

U3:breathing port map
(	CLK_div1=>CLK_div1,
	fre_up=>fre_up,			
	fre_down=>fre_down,				
	strength_up=>strength_up,			
	strength_down=>strength_down,
	l=>l,
	h=>h,
	breathingled=>breathingled

);


    
END breathingled_arch;