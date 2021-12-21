library ieee;  
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--显示

entity Seg7 is
port
(
	CLK							:in std_logic;--12MHz
	CLK_20K						:in std_logic;--20KHz
	l							:in integer;
	h							:in integer;
	rck							:inout std_logic;--并行输出时钟（若为1，输出16位的data）
	sck							:inout std_logic;--串行输入时钟（若为1，16位的data一位一位串联进入595）
	data						:inout std_logic --串行发出的数据
);
end entity;

architecture Seg7_arch of Seg7 is
signal cnt_main					:integer:=1;--6个数码管逐个扫描编号
signal cnt_write				:integer:=0;
signal state					:integer:=0;--595状态控制，1表示配置数据（使得某一数码管工作，并计算出对应值），2表示发送数据（串联输入，并联输出）
signal data_reg					:std_logic_vector(15 downto 0);
--数码管的字库
--顺序为：DP,G,F,E,D,C,B,A
type num is array(0 to 9) of std_logic_vector(7 downto 0);
constant seg:num:=
(
	"00111111",--0
	"00000110",--1
	"01011011",--2
	"01001111",--3
	"01100110",--4
	"01101101",--5
	"01111101",--6
	"00000111",--7
	"01111111",--8
	"01101111" --9
);

begin
process(CLK)
begin
	if rising_edge(CLK) then
		case state is
			when 0=>
				state<=1;
				cnt_main<=0;
				cnt_write<=0;
				sck<='0';
				rck<='0';
				
			when 1=>--配置数据（使得某一数码管工作，并计算出对应值）
				if cnt_main>=1 then--扫描数码管
					cnt_main<=0;
				else
					cnt_main<=cnt_main+1;
				end if;
				case cnt_main is
					when 0=>--SEG1,H MSB，第一个数码管
						state<=2;--配置完成后，转入发送状态
						data_reg(15 downto 8)<=seg(h);--对应的七段码数据
						data_reg(7 downto 0)<="11111110";
					when 1=>--SEG2,H LSB
						state<=2;
						data_reg(15 downto 8)<=seg(l);
						data_reg(7 downto 0)<="11111101";
					when others=>NULL;
				end case;
				
			when 2=>--发送数据（串联输入，并联输出）
				if CLK_20K='1' then--一次16位的并联输出，需要34个完整的输入分频时钟周期（16*2+1+1）
					if cnt_write>=33 then
						cnt_write<=0;
					else
						cnt_write<=cnt_write+1;
					end if;
					case cnt_write is
						when 0=>--第一个分频时钟周期，令595输入时钟SCK为下降沿，此时，传入要传输的第一位数据，等待上升沿的到来
							sck<='0';
							data<=data_reg(15);
						when 1=>--第二个分频时钟周期，令595输入时钟SCK为上升沿，此时，单个数据进入595缓存数组保存
							sck<='1';
						when 2=>
							sck<='0';
							data<=data_reg(14);
						when 3=>
							sck<='1';
						when 4=>
							sck<='0';
							data<=data_reg(13);
						when 5=>
							sck<='1';
						when 6=>
							sck<='0';
							data<=data_reg(12);
						when 7=>
							sck<='1';
						when 8=>
							sck<='0';
							data<=data_reg(11);
						when 9=>
							sck<='1';
						when 10=>
							sck<='0';
							data<=data_reg(10);
						when 11=>
							sck<='1';
						when 12=>
							sck<='0';
							data<=data_reg(9);
						when 13=>
							sck<='1';
						when 14=>
							sck<='0';
							data<=data_reg(8);
						when 15=>
							sck<='1';
						when 16=>
							sck<='0';
							data<=data_reg(7);
						when 17=>
							sck<='1';
						when 18=>
							sck<='0';
							data<=data_reg(6);
						when 19=>
							sck<='1';
						when 20=>
							sck<='0';
							data<=data_reg(5);
						when 21=>
							sck<='1';
						when 22=>
							sck<='0';
							data<=data_reg(4);
						when 23=>
							sck<='1';
						when 24=>
							sck<='0';
							data<=data_reg(3);
						when 25=>
							sck<='1';
						when 26=>
							sck<='0';
							data<=data_reg(2);
						when 27=>
							sck<='1';
						when 28=>
							sck<='0';
							data<=data_reg(1);
						when 29=>
							sck<='1';
						when 30=>
							sck<='0';
							data<=data_reg(0);
						when 31=>
							sck<='1';
						when 32=>
							rck<='1';--数据链注入完毕，并行信号输出准备
						when 33=>
							rck<='0';
							state<=1;
							when others=>
					end case;
				else
					sck<=sck;
					rck<=rck;
					data<=data;
					cnt_write<=cnt_write;
					state<=state;
				end if;
			when others=>
		end case;
	end if;
end process;

end Seg7_arch;