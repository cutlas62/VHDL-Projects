library IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;

USE work.PIC_pkg.all;

entity DMA is
PORT (
   Clk      : in    std_logic;
   Reset    : in    std_logic;
   RCVD_Data  : in    std_logic_vector(7 downto 0);
	RX_Full : in std_logic;
	RX_Empty :in std_logic;
	ACK_out : in std_logic;
	TX_RDY :in std_logic;
	DMA_ACK : in std_logic;
	Send_comm : in std_logic;
	Data_Read : out std_logic;
	Valid_D : out std_logic;
	TX_Data : out std_logic_vector(7 downto 0);
	Address : out std_logic_vector(7 downto 0);
	Databus : inout std_logic_vector(7 downto 0);
	Write_en : out std_logic;
	OE : out std_logic;
	DMA_RQ : out std_logic;
	READY : out std_logic);

end DMA;

architecture Behavioral of DMA is
	
	type estados is (Idle, Peticion, Lectura1, Lectura2, Lectura3, Terminado);
	signal current_state, next_state: estados;
begin	
process (RX_Empty, DMA_ack)
begin
	next_state <= current_state;
	data_read <= '0';
	write_en <= '0';
	dma_rq <= '0';
	if (Reset = '0') then
		next_state <= idle;
	else
		CASE current_state IS
		
			when idle =>
				if(RX_empty = '0') then
					next_state <= Peticion;
				end if;
				
			when Peticion =>
				DMA_RQ <= '1';
				if DMA_ack = '1' then
					data_read <='1';
					next_state <= Lectura1;
				end if;
				
			when Lectura1 =>
				databus <= RCVD_data;
				address <= "00000000";
				write_en <='1';
				if(RX_empty = '0') then
					data_read <='1';
					next_state <= Lectura2;
				end if;
			
			when Lectura2 =>
				databus <= RCVD_data;
				address <= "00000001";
				write_en <='1';
				if(RX_empty = '0') then
					data_read <='1';
					next_state <= Lectura3;
				end if;
				
			when Lectura3 =>
				databus <= RCVD_data;
				address <= "00000010";
				write_en <='1';
				if(RX_empty = '1') then
					next_state <= Terminado;
				end if;
				
			when Terminado =>
				DMA_RQ <= '0';
				if DMA_ack = '0' then
					next_state <= idle;
				end if;

			
		end case;
		end if;
end process;

end Behavioral;

