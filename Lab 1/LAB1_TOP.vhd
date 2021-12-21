--"对clk_div2进行40000分频时，使用数组存储才可成功运行，不可用clk_div的分频方法"?????????????????????????????????????????????
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY matrix IS
PORT (
		clk : IN STD_LOGIC; --12MHz
		rck : INOUT STD_LOGIC; --74HC595 RCK
		sck: INOUT STD_LOGIC; --74HC595 SCK
		data:INOUT std_logic; --串行发出的数据
		column : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		row : BUFFER STD_LOGIC_VECTOR(3 DOWNTO 0);
		key_code : BUFFER INTEGER RANGE 0 TO 21;
		btn : IN STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END matrix;


ARCHITECTURE matrix_arch OF matrix IS

	CONSTANT LOW : STD_LOGIC := '0';
	CONSTANT HIGH : STD_LOGIC := '1';

	--7segment led part
	signal l						:integer:=0;
	signal h						:integer:=0;
	
	--keyboard part

	SIGNAL clk_div1 : STD_LOGIC; --clk_div signal to keyboard
	SIGNAL clk_div2 : STD_LOGIC; --clk_div signal to keyboard
	
	
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

component freqdivide is
port
(
	CLK							:in std_logic;--12MHz
	CLK_div1					:inout std_logic;
	CLK_div2					:inout std_logic 
);
end component;

component keyboard is
port
(
	CLK_div2					: IN std_logic;
	column 						: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	row 						: BUFFER STD_LOGIC_VECTOR(3 DOWNTO 0);
	key_code 					: BUFFER INTEGER RANGE 0 TO 21;
	btn 						: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	l							: OUT integer:=0;
	h							: OUT integer:=0
);
end component;

BEGIN
U1:Seg7 port map
(
	clk=>CLK,CLK_20K=>CLK_div1,l=>l,h=>h,rck=>rck,sck=>sck,data=>data
);

U2:freqdivide port map
(
	clk=>CLK,CLK_div1=>CLK_div1,CLK_div2=>CLK_div2
);

U3:keyboard port map
(
	CLK_div2=>CLK_div2,column=>column,row=>row,key_code=>key_code,btn=>btn,l=>l,h=>h
);

END matrix_arch;