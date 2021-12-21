 
-----------------------VERSION8----------------------------
--File         :   lab3_temp.vhd
--Version      :   4.0
--Time         :   2021/11/10 00:01:47
--Author       :   ����
--StudentID    :   51902191157
--E-mail       :   daodao123@sjtu.edu.cn
--Introduction :   ����С��ѾFPGAʵ����ϵ�������ɫLED�ƣ�ģ��ʵ��ʮ��·�ڵĺ��̵ƿ���ϵͳ��
-- ����Ҫ��
-- ��ͨ���������ò�ͬ����ģʽ��ʵ�ֶ���ģʽ�µĿ��Ʒ�ʽ��
-- �����������ͨ˫��Ե�ģʽ��һ�����ɵ�һ��θɵ��ķǶԵȿ���ģʽ����˫�򳤻�����ģʽ�ȡ�
-- ����ܿ���ʾ�������ݣ���ѡ����
-- Notes
-- �������ܾ���ʵ�֣�ѡ�����ܣ��������ʾ������Ѿ���ã�ֻ��Ҫ�ѱ���temp1��temp2�ĳ���Ҫ��ʾ��������ʮλ�͸�λ����

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
		data						: INOUT STD_LOGIC --���з���������
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
            