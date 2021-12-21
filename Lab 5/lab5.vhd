library ieee;
use ieee.std_logic_1164.all;
entity music_player is
 port(
   key    :  in std_logic_vector(2 downto 0);
   auto   :  in std_logic ;--key1
   clk  :  in std_logic;
   col    :  in std_logic_vector(3 downto 0);--矩阵按键col
   row   :  buffer std_logic_vector(3 downto 0);----矩阵按键row
   beep   :  out std_logic;--spisi蜂鸣器
   digit: out std_logic_vector(7 downto 0);--核心板数码管
   en     :  out std_logic--segdig1
 );
 end entity;

architecture music_player_arch of music_player is
signal clk_music    :std_logic;
signal auto1  :std_logic;
signal cnt    :integer range 0 to 1000000;
signal N      :integer range 0 to 10000000;
signal clk_10 :std_logic;
signal clk8hz :std_logic;
signal tone1,tone2,tone:integer range 0 to 10;
signal music_num:std_logic;
signal num    :integer range 0 to 1;

signal a      :integer range 0 to 1:=0;
component freqdivider is
port
(
	CLK						:in std_logic;--12MHz
	clk8hz					:inout std_logic;
	clk_10					:inout std_logic 
);
end component;
component seg is
port
(
	CLK						:in std_logic;--12MHz
	tone					:integer range 0 to 10;
	en     					:out std_logic;--segdig1
	digit					:out std_logic_vector(7 downto 0)--核心板数码管 
);
end component;
component song is
port
(
	clk8hz						:in std_logic;--12MHz
	tone2						:out integer range 0 to 10;
	music_num					:in std_logic;
	num    						:in integer range 0 to 1
);
end component;
begin
U1:freqdivider port map
(
	clk=>CLK,clk8hz=>clk8hz,clk_10=>clk_10
);
U2:seg port map
(
	clk=>CLK,tone=>tone,en=>en,digit=>digit
);
U3:song port map
(
	clk8hz=>clk8hz,tone2=>tone2,music_num=>music_num,num=>num
);
---------Mode Switching(auto控制是响单音，还是整曲演奏)--------
process(auto)
begin
if falling_edge(auto)then--KEY1按下--每按下一次改变一次auto1
  if auto1 = '1' then
    auto1 <= '0';
  else
    auto1 <= '1';
  end if;
 end if;
 end process;


----------Keyboard Scanning--------
process(clk_10)
variable cq : integer range 0 to 1 :=0;
begin
if (clk_10 = '1') then
  if cq = 0 then cq := 1;
  else cq := 0;
  end if;
end if;
a <= cq;--再分频
end process;

process(clk_10)
  begin
  case a is
   when 0=> row <= "1110";
   when others=> row <= "1101";
  end case;
end process;

----------Key Operations（如果auto1，按一个响一个，否则自动演奏，自动演奏曲目受FPGA上011控制）---------
process(clk_10)
begin
if rising_edge(clk_10) then
if auto1 = '1' then--按一个响一个模式
case a is
when 0 =>                 --Key on first row
case col is
 when "1110"=> tone1 <= 1;--
 when "1101"=> tone1 <= 2;
 when "1011"=> tone1 <= 3;
 when "0111"=> tone1 <= 4;
when others=> tone1 <= 0;
end case;
when 1=>                  --Key on second row
case col is
 when "1110" => tone1 <= 5;
 when "1101" => tone1 <= 6;
 when "1011" => tone1 <= 7;
 when "0111" => tone1 <= 8;
when others=> tone1 <= 0;
end case;
end case;

case key is               --Key on stepFPGA board
when "110" => tone1 <= 1;--M13-KEY2
when "101"=> tone1 <= 8;--M14--KEY3
when others=> null;
end case;
else--auto='0'自动播放曲目模式
case key is               
when "011" => music_num <= '1';--N14-KEY4
when others => music_num <= '0';
end case;
end if;
end if;
end process;

---------Music Switch-------
process(music_num)
begin
if falling_edge(music_num) then--切换曲目
    if num = 1 then num <= 0;
	else num <= num + 1;
	end if;
end if;
end process;

---------Music Play（C大调各主音对应的频率）---------
process(clk_music, tone1, tone2, auto1)
begin
if auto1 = '0'--自动播放
  then tone <= tone2;
else
  tone <= tone1;
end if;
case tone is
when 1=> N <= 11465;
when 2=> N <= 10216;
when 3=> N <= 9101;
when 4=> N <= 8590;
when 5=> N <= 7653;
when 6=> N <= 6818;
when 7=> N <= 6074;
when 8=> N <= 5736;
when 9=> N <= 5106;
when 10=> N <= 4548;
when others=> N <= 0;
end case;
end process;

process(clk, N)
begin
if rising_edge(clk)then
  if(cnt = N) then--相应分频
    cnt <= 0;
	  clk_music <= not clk_music;
  else
    cnt <= cnt + 1;
	end if;
	beep <= clk_music;
end if;
end process;


end;
