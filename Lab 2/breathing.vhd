library ieee;  
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--��ʾ

entity breathing is
port
(
	CLK_div1						:IN STD_LOGIC;--��������
	fre_up							:IN STD_LOGIC;
	fre_down						:IN STD_LOGIC;
	strength_up						:IN STD_LOGIC;
	strength_down					:IN STD_LOGIC;
	l								:OUT INTEGER;
	h								:OUT INTEGER;
	breathingled					:OUT STD_LOGIC
	);
end entity;

architecture breathing_arch of breathing is
	CONSTANT CLK_breath		 		: INTEGER := 20000; --elated with clk_div2's frequency
	CONSTANT CLK_seg 				: INTEGER := 300; --elated with clk_div's frequency-20khz�������
	CONSTANT MAX_AMPLITUDE 			: INTEGER := 1200;--�ĵ������ֵ���ֵ
	CONSTANT MAX_STEP 				: INTEGER := 60;--�ĵ�������󲽳�
	CONSTANT triangle_step 			: INTEGER := 1;--���ǲ���ֵ�仯�̶�

BEGIN
PROCESS (clk_div1)
		VARIABLE amplitude : INTEGER RANGE 1 TO MAX_AMPLITUDE := MAX_AMPLITUDE/5;--��ݲ������ǲ�������ֵ
		VARIABLE sawtooth_step : INTEGER RANGE 1 TO MAX_STEP := MAX_STEP/5;--��ݲ���ֵ�仯����
        VARIABLE temp1 : INTEGER RANGE 0 TO MAX_AMPLITUDE := 0;
        VARIABLE temp2 : INTEGER RANGE 0 TO MAX_AMPLITUDE := 0;
        VARIABLE temp2_state : INTEGER RANGE 0 TO 2 := 0;
		VARIABLE h0 : INTEGER:= 0;
        VARIABLE l0 : INTEGER:= 0;
		VARIABLE delay_cnt : INTEGER:= 0;
BEGIN
	IF(clk_div1 'event AND clk_div1 = '1') THEN
			--detect key
			IF delay_cnt=90 THEN
				delay_cnt:=0;
				IF (fre_up = '0') THEN
					amplitude := amplitude - MAX_AMPLITUDE/5;
					h0:=h0-1;
				ELSIF (fre_down = '0') THEN
					amplitude := amplitude + MAX_AMPLITUDE/5;
					h0:=h0+1;
				END IF;

				IF (strength_up = '0') THEN
					sawtooth_step := sawtooth_step - MAX_STEP/5;
					l0:=l0-1;
				ELSIF (strength_down = '0') THEN
					sawtooth_step := sawtooth_step + MAX_STEP/5;
					l0:=l0+1;
				END IF;
			ELSE	delay_cnt:=delay_cnt+1;
			END IF;
			
			--Can't cross the boundary
			IF (amplitude >= MAX_AMPLITUDE) OR (amplitude <=1) THEN
				amplitude := MAX_AMPLITUDE/5;
				h0:=0;
			END IF;
			IF (sawtooth_step >= MAX_STEP) OR (sawtooth_step <= 1) THEN
				sawtooth_step := MAX_STEP/5;
				l0:=0;
			END IF;
			
			h<=h0;
			l<=l0;
			
			--two counters
			--sawtooth wave
            IF (temp1 < amplitude) THEN--��ݲ�
                temp1 := temp1 + sawtooth_step;
            ELSE
                temp1 := 0;
            END IF;
			
			--triangle wave
            IF (temp2 >= amplitude) THEN
                temp2_state := 0;--���ǲ��ﵽ���ֵ������½�ģʽ
            ELSIF (temp2 <= 1) THEN
                temp2_state := 1;--����ģʽ
            ELSE
                temp2_state := temp2_state;
            END IF;

            IF (temp2_state = 0) THEN
                temp2 := temp2 - triangle_step;
            ELSE
                temp2 := temp2 + triangle_step;
            END IF;

            IF (temp1 > temp2) THEN
                breathingled <= '0'; --����
            ELSE
                breathingled <= '1';
            END IF;
			
      END IF;
 END PROCESS;

end breathing_arch;