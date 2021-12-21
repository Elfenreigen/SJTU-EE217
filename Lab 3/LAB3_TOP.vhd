 
-----------------------VERSION8----------------------------
--File         :   lab3_temp.vhd
--Version      :   4.0
--Time         :   2021/11/10 00:01:47
--Author       :   李艳
--StudentID    :   51902191157
--E-mail       :   daodao123@sjtu.edu.cn
--Introduction :   利用小脚丫FPGA实验板上的两个三色LED灯，模拟实现十字路口的红绿灯控制系统。
-- 具体要求
-- 可通过按键设置不同控制模式，实现多种模式下的控制方式。
-- 如可以设置普通双向对等模式、一向主干道一向次干道的非对等控制模式或者双向长黄闪灯模式等。
-- 数码管可显示读秒数据（可选）。
-- Notes
-- 基本功能均已实现，选做功能（数码管显示）框架已经搭好，只需要把变量temp1和temp2改成想要显示的秒数的十位和个位即可

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity traffic_light is
    port(clk: in std_logic;
        btn : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        light1,light2: out std_logic_vector(2 downto 0);
		rck 						: INOUT STD_LOGIC; --74HC595 RCK
		sck							: INOUT STD_LOGIC; --74HC595 SCK
		data						: INOUT STD_LOGIC --串行发出的数据
		);
end traffic_light;

architecture traffic_light_arch of traffic_light is
--------------------------------------------------------------------------
SIGNAL clk_div1 				: STD_LOGIC;  --clk_div signal to keyboard
SIGNAL clk_div2 				: STD_LOGIC ; --clk_div signal to keyboard
SIGNAL clk_div3 				: STD_LOGIC ; --clk_div signal to keyboard 
SIGNAL l						: INTEGER;
SIGNAL h						: INTEGER;

component Seg7 is
port
(
	CLK							:in std_logic;
	CLK_20K						:in std_logic;
	l							:in integer;
	h							:in integer;
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
	CLK_div2					:inout std_logic;
	CLK_div3					:inout std_logic
	);
end component;

component statemachine is
port
(
	CLK_div1					:inout std_logic;
	CLK_div2					:inout std_logic;
	btn 						:in STD_LOGIC_VECTOR(3 DOWNTO 0);
    light1,light2				:out std_logic_vector(2 downto 0);
	l							:inout INTEGER;
	h							:inout INTEGER
	);
end component;
--------------------------------------------------------------------------
BEGIN
	
U1:Seg7 port map
(
	clk=>CLK,CLK_20K=>CLK_div3,l=>l,h=>h,rck=>rck,sck=>sck,data=>data
);
U2:freqdivider port map
(
	clk=>CLK,CLK_div1=>CLK_div1,CLK_div2=>CLK_div2,CLK_div3=>CLK_div3
	);
U3:statemachine port map
(
	CLK_div1=>CLK_div1,CLK_div2=>CLK_div2,btn=>btn,light1=>light1,light2=>light2,l=>l,h=>h
	);


    end traffic_light_arch;
            