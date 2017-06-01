----------------------------------------------------------------------------------
-- Company: VUT FIT
-- Student: Frantisek Horazny; xhoraz02
-- 
-- Create Date:    13:06:36 03/29/2017 
-- Design Name: 
-- Module Name:    bcd - Behavioral 
-- Project Name: BCD citac
-- Target Devices: 
-- Tool versions: 
-- Description: vypocet skore (pocet kroku)
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity bcd is
    Port ( ENABLE : in  STD_LOGIC;
           RESET : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           NUMBER1 : buffer  STD_LOGIC_VECTOR(3 downto 0);
           NUMBER2 : buffer  STD_LOGIC_VECTOR(3 downto 0);
           NUMBER3 : buffer  STD_LOGIC_VECTOR(3 downto 0)
			);
end bcd;

architecture Behavioral of bcd is

begin 
process (CLK, RESET, ENABLE)
begin
 if (RESET='1') then    --pokud nabehne RESET-ihned se vynuluje
 NUMBER3 <= (others => '0');
 NUMBER2 <= (others => '0');
 NUMBER1 <= (others => '0');
 elsif (CLK='1') and (ENABLE='1') then
	if NUMBER1 = 9 then
			if NUMBER2 = 9 then
				if NUMBER3 = 9 then					--osetreni 999 kroku
					NUMBER3 <= (others => '0');
					NUMBER2 <= (others => '0');
					NUMBER1 <= (others => '0');
				else
					NUMBER3 <= NUMBER3 + 1;
					NUMBER2 <= (others => '0');
					NUMBER1 <= (others => '0');
				end if;
			else
				NUMBER2 <= NUMBER2 + 1;
				NUMBER1 <= (others => '0');
			end if;
	else
		NUMBER1 <= NUMBER1 + 1;
	end if;
 end if;
 
end process;

end Behavioral;

