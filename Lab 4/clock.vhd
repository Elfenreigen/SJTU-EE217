--File         :   clock.vhd
--Version      :   Based on Dahu Feng Version
--Time         :   2021/11/20 21:05:32
--Author       :   戴天杰
--StudentID    :   519021910734
--E-mail       :   elfenreigen@sjtu.edu.cn
--Introduction :   四种模式：调时、调分、调秒（前三者调节时，其他两个数码管熄灭）、自动计时，利用按键控制模式与增减。不同模式点亮不同LED，并在数码管上显示。

library ieee;  
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity clock is
port
(
	CLK							:in std_logic;--12MHz时钟
	modeSelect					:in std_logic;--四种模式切换
	inc							:in std_logic;--数字加键
	dec							:in std_logic;--数字减键
	rst							:in std_logic;--重置按键
	LEDs						:out std_logic_vector(3 downto 0);--4个LED灯控制
	rck							:inout std_logic;--595并行输出时钟
	sck							:inout std_logic;--595串行输入时钟
	data						:inout std_logic --串行发出的数据
);
end entity;

architecture clock_arch of clock is

signal CLK_divided				:std_logic;
signal CLK_20K					:std_logic;
signal modeSelect_stable		:std_logic;
signal inc_stable				:std_logic;
signal dec_stable				:std_logic;
signal mode						:integer:=0;
signal s_l						:integer:=0;
signal s_h						:integer:=0;
signal m_l						:integer:=0;
signal m_h						:integer:=0;
signal h_l						:integer:=0;
signal h_h						:integer:=0;


--Clk-Div
component clk_div is
port
(
	CLK							:in std_logic;--12MHz
	CLK_divided					:inout std_logic;--1Hz
	CLK_20K						:inout std_logic --20KHz For 595
);
end component;
   
--Debounce Module
component debounce is
port
(
	CLK							:in std_logic;--12MHz
	modeSelect					:in std_logic;--Mode Selection
	inc							:in std_logic;--Increase
	dec							:in std_logic;--Minus
	modeSelect_stable			:inout std_logic;--Mode Selection After Debounce
	inc_stable					:inout std_logic;--Increase After Debounce
	dec_stable					:inout std_logic --Minus After Debounce
);
end component;

--Mode Selection
component clock_ctl is
port
(
	modeSelect_stable			:in std_logic;--Mode Selection After Debounce
	mode						:inout integer:=1--Sum the total number of button-pressing action mod 4 
);
end component;

--Count
component clock_cnt is
port
(
	CLK_divided					:in std_logic;--1Hz
	mode						:in integer:=0;--Mode
	inc_stable					:in std_logic;--Increase After Debounce
	dec_stable					:in std_logic;--Minus After Debounce	
	rst							:in std_logic;--Reset
	s_l							:inout integer:=0;--Sec，LSB
	s_h							:inout integer:=0;--Sec，MSB
	m_l							:inout integer:=0;--Min，LSB
	m_h							:inout integer:=0;--Min，MSB
	h_l							:inout integer:=0;--Hour，LSB
	h_h							:inout integer:=0 --Hour，MSB
);
end component;

--LED 
component led is
port
(
	mode						:in integer:=1;--Mode
	LEDs						:out std_logic_vector(3 downto 0)--Choosing which one to lighten
);
end component;

--595 & DISPLAY 
component clock_trans is
port
(
	CLK							:in std_logic;
	CLK_20K						:in std_logic;
	mode						:in integer:=0;
	s_l							:in integer:=0;
	s_h							:in integer:=0;
	m_l							:in integer:=0;
	m_h							:in integer:=0;
	h_l							:in integer:=0;
	h_h							:in integer:=0;
	rck							:inout std_logic;
	sck							:inout std_logic;
	data						:inout std_logic
);
end component;

begin

--元件端口映射

--Clk-Div
U1:clk_div port map
(
	CLK=>CLK,CLK_divided=>CLK_divided,CLK_20K=>CLK_20K
);
--Debounce
U2:debounce port map
(
	CLK=>CLK,modeSelect=>modeSelect,inc=>inc,dec=>dec,modeSelect_stable=>modeSelect_stable,inc_stable=>inc_stable,dec_stable=>dec_stable
);
--Mode Selection
U3:clock_ctl port map
(
	modeSelect_stable=>modeSelect_stable,mode=>mode
);
--Count
U4:clock_cnt port map
(
	CLK_divided=>CLK_divided,mode=>mode,inc_stable=>inc_stable,dec_stable=>dec_stable,s_l=>s_l,s_h=>s_h,m_l=>m_l,m_h=>m_h,h_l=>h_l,h_h=>h_h,rst=>rst
);
--LED
U5:LED port map
(
	mode=>mode,LEDs=>LEDs
);
--595 & DISPLAY 
U6:clock_trans port map
(
	CLK=>CLK,CLK_20K=>CLK_20K,mode=>mode,s_l=>s_l,s_h=>s_h,m_l=>m_l,m_h=>m_h,h_l=>h_l,h_h=>h_h,rck=>rck,sck=>sck,data=>data
);

end clock_arch;