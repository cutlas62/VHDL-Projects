
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;

USE work.PIC_pkg.all;

ENTITY ram IS
PORT (
   Clk      : in    std_logic;
   Reset    : in    std_logic;
   write_en : in    std_logic;
   oe       : in    std_logic;
   address  : in    std_logic_vector(7 downto 0);
   databus  : inout std_logic_vector(7 downto 0);
	switches : out   std_logic_vector(7 downto 0);
	temp_l   : out   std_logic_vector(6 downto 0);
	temp_h   : out   std_logic_vector(6 downto 0));
END ram;

ARCHITECTURE behavior OF ram IS

	SIGNAL contents_ram : array8_ram(255 downto 0);
	signal en_gp : std_logic;
	
	
BEGIN

-------------------------------------------------------------------------
-- Selección de tipo de memoria
-------------------------------------------------------------------------
p_gp : process (address)
begin

	if conv_Integer(address) >= 64 then
		en_gp <= '1';
	else
		en_gp <= '0';
	end if;
end process;
-------------------------------------------------------------------------



-------------------------------------------------------------------------
-- Memoria de propósito general
-------------------------------------------------------------------------
p_ram_gp : process (clk)  -- no reset
begin
  
  if clk'event and clk = '1' then
    if write_en = '1' and en_gp = '1' then
      contents_ram(conv_Integer(address)) <= databus;
    end if;
  end if;

end process;
databus <= contents_ram(conv_integer(address)) when oe = '0' else (others => 'Z');
-------------------------------------------------------------------------



-------------------------------------------------------------------------
-- Memoria predefinida
-------------------------------------------------------------------------
p_ram_d : process (clk)  -- no reset
begin
  if(Reset = '1') then
	contents_ram(conv_integer(DMA_RX_BUFFER_MSB))<= "00000000";
	contents_ram(conv_integer(DMA_RX_BUFFER_MID))<= "00000000";
	contents_ram(conv_integer(DMA_RX_BUFFER_LSB))<= "00000000";
	contents_ram(conv_integer(NEW_INST))<= "00000000";
	contents_ram(conv_integer(DMA_TX_BUFFER_MSB))<= "00000000";
	contents_ram(conv_integer(DMA_TX_BUFFER_LSB))<= "00000000";
	
	contents_ram(conv_integer(SWITCH_BASE))<= "00000000";
   contents_ram(conv_integer(SWITCH_BASE + 1))<= "00000000";
	contents_ram(conv_integer(SWITCH_BASE + 2))<= "00000000";
	contents_ram(conv_integer(SWITCH_BASE + 3))<= "00000000";
	contents_ram(conv_integer(SWITCH_BASE + 4))<= "00000000";
	contents_ram(conv_integer(SWITCH_BASE + 5))<= "00000000";
	contents_ram(conv_integer(SWITCH_BASE + 6))<= "00000000";
	contents_ram(conv_integer(SWITCH_BASE + 7))<= "00000000";
	
	contents_ram(conv_integer(LEVER_BASE))<= "00000000";
	contents_ram(conv_integer(LEVER_BASE + 1))<= "00000000";
	contents_ram(conv_integer(LEVER_BASE + 2))<= "00000000";
	contents_ram(conv_integer(LEVER_BASE + 3))<= "00000000";
	contents_ram(conv_integer(LEVER_BASE + 4))<= "00000000";
	contents_ram(conv_integer(LEVER_BASE + 5))<= "00000000";
	contents_ram(conv_integer(LEVER_BASE + 6))<= "00000000";
	contents_ram(conv_integer(LEVER_BASE + 7))<= "00000000";
	contents_ram(conv_integer(LEVER_BASE + 8))<= "00000000";
	contents_ram(conv_integer(LEVER_BASE + 9))<= "00000000";
	
	contents_ram(conv_integer(CAL_OP))<= "00000000";
	contents_ram(conv_integer(T_STAT))<= "00010000";
	contents_ram(conv_integer(GP_RAM_BASE))<= "00000000";
	--databus <="00000000";
  end if;
  
  if clk'event and clk = '1' then
    if write_en = '1' and en_gp = '0' then
      contents_ram(conv_Integer(address)) <= databus;
    end if;
  end if;

end process;
-------------------------------------------------------------------------

switches(0) <= contents_ram(conv_integer(SWITCH_BASE))(0);
switches(1) <= contents_ram(conv_integer(SWITCH_BASE + 1))(0);
switches(2) <= contents_ram(conv_integer(SWITCH_BASE + 2))(0);
switches(3) <= contents_ram(conv_integer(SWITCH_BASE + 3))(0);
switches(4) <= contents_ram(conv_integer(SWITCH_BASE + 4))(0);
switches(5) <= contents_ram(conv_integer(SWITCH_BASE + 5))(0);
switches(6) <= contents_ram(conv_integer(SWITCH_BASE + 6))(0);
switches(7) <= contents_ram(conv_integer(SWITCH_BASE + 7))(0);


-------------------------------------------------------------------------
-- Decodificador de BCD a 7 segmentos
-------------------------------------------------------------------------
with contents_ram(conv_integer(T_STAT))(7 downto 4) select
Temp_H <=
    "0000110" when "0001",  -- 1
    "1011011" when "0010",  -- 2
    "1001111" when "0011",  -- 3
    "1100110" when "0100",  -- 4
    "1101101" when "0101",  -- 5
    "1111101" when "0110",  -- 6
    "0000111" when "0111",  -- 7
    "1111111" when "1000",  -- 8
    "1101111" when "1001",  -- 9
    "1110111" when "1010",  -- A
    "1111100" when "1011",  -- B
    "0111001" when "1100",  -- C
    "1011110" when "1101",  -- D
    "1111001" when "1110",  -- E
    "1110001" when "1111",  -- F
    "0111111" when others;  -- 0

with contents_ram(conv_integer(T_STAT))(3 downto 0) select
Temp_l <=
    "0000110" when "0001",  -- 1
    "1011011" when "0010",  -- 2
    "1001111" when "0011",  -- 3
    "1100110" when "0100",  -- 4
    "1101101" when "0101",  -- 5
    "1111101" when "0110",  -- 6
    "0000111" when "0111",  -- 7
    "1111111" when "1000",  -- 8
    "1101111" when "1001",  -- 9
    "1110111" when "1010",  -- A
    "1111100" when "1011",  -- B
    "0111001" when "1100",  -- C
    "1011110" when "1101",  -- D
    "1111001" when "1110",  -- E
    "1110001" when "1111",  -- F
    "0111111" when others;  -- 0
-------------------------------------------------------------------------

END behavior;

