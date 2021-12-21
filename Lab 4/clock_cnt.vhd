library ieee;  
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--Count


entity clock_cnt is
port
(
	CLK_divided					:in std_logic;--1Hz
	mode						:in integer:=0;--Mode
	inc_stable					:in std_logic;--Plus After Debounce
	dec_stable					:in std_logic;--Minus After Debounce	
	rst							:in std_logic;--Reset
	s_l							:inout integer:=0;--Sec,LSB
	s_h							:inout integer:=0;--Sec,MSB
	m_l							:inout integer:=0;--Min,LSB
	m_h							:inout integer:=0;--Min,MSB
	h_l							:inout integer:=0;--Hour,LSB
	h_h							:inout integer:=0 --Hour,MSB
);
end entity;


architecture clock_cnt_arch of clock_cnt is
begin

clock_cnt:process(CLK_divided,inc_stable,dec_stable,rst)
variable delay_cnt			:integer:=0;
begin
	if rising_edge(CLK_divided) then
		if rst='0' then
			s_l<=0;
			s_h<=0;
			m_l<=0;
			m_h<=0;
			h_l<=0;
			h_h<=0;
		end if;
		
		case mode is
			when 1=>--Hour, +:X9£¬23,-:00£¬X0
				if inc_stable='0' then 
					if h_l=9 then      
						h_h<=h_h+1;
						h_l<=0;
					elsif h_l=3 and h_h=2 then
						h_h<=0;
						h_l<=0;
					else
						h_l<=h_l+1;
					end if;
				elsif dec_stable='0' then
					if h_l=0 then
						if h_h=0 then
							h_h<=2;
							h_l<=3;
						else
							h_h<=h_h-1;
							h_l<=9;
						end if;
					else
						h_l<=h_l-1;
					end if;
				end if;
				
			when 2=>--Minute,+:X9£¬59,-:00£¬X0
				if inc_stable='0' then
					if m_l=9 then
						if m_h=5 then
							m_h<=0;
							m_l<=0;
						else
							m_h<=m_h+1;
							m_l<=0;
						end if;
					else
						m_l<=m_l+1;
					end if;
				elsif dec_stable='0' then
					if m_l=0 then
						if m_h=0 then
							m_h<=5;
							m_l<=9;
						else
							m_h<=m_h-1;
							m_l<=9;
						end if;
					else
						m_l<=m_l-1;
					end if;
				end if;
				
			when 3=>--Second,+:X9£¬59,-:00£¬X0
				if inc_stable='0' then
					if s_l=9 then
						if s_h=5 then
							s_h<=0;
							s_l<=0;
						else
							s_h<=s_h+1;
							s_l<=0;
						end if;
					else
						s_l<=s_l+1;
					end if;
				elsif dec_stable='0' then
					if s_l=0 then
						if s_h=0 then
							s_h<=5;
							s_l<=9;
						else
							s_h<=s_h-1;
							s_l<=9;
						end if;
					else
						s_l<=s_l-1;
					end if;
				end if;
				
		
			when others=>--Count:ATTENTION 23£º59£º59¡¢XX£¨X9£©£º59£º59¡¢XX£ºXX(X9)£º59
			if delay_cnt=9 then
				delay_cnt:=0;
				if h_h=2 and h_l=3 and m_h=5 and m_l=9 and s_h=5 and s_l=9 then
					h_h<=0;
					h_l<=0;
					m_h<=0;
					m_l<=0;
					s_h<=0;
					s_l<=0;
				elsif m_h=5 and m_l=9 and s_h=5 and s_l=9 then
					m_h<=0;
					m_l<=0;
					s_h<=0;
					s_l<=0;
					if h_l=9 then
						h_h<=h_h+1;
						h_l<=0;
					else
						h_l<=h_l+1;
					end if;
				elsif s_h=5 and s_l=9 then
					s_h<=0;
					s_l<=0;
					if m_l=9 then 
						m_h<=m_h+1;
						m_l<=0;
					else
						m_l<=m_l+1;
					end if;
				else
					if s_l=9 then
						s_l<=0;
						s_h<=s_h+1;
					else
						s_l<=s_l+1;
					end if;
				end if;
			end if;
			delay_cnt:=delay_cnt+1;
		end case;
	end if;
end process;

end clock_cnt_arch;