----------------------------------------------------------------------------------
-- Author: FRANTISEK HORAZNY
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.lightsout_pack.ALL; -- vysledek z prvniho ukolu


entity cell is
   GENERIC (
      MASK              : mask_t := (others => '1') -- mask_t definovano v baliku lightsout_pack
   );
   Port ( 
      INVERT_REQ_IN     : in   STD_LOGIC_VECTOR (3 downto 0);
      INVERT_REQ_OUT    : out  STD_LOGIC_VECTOR (3 downto 0);
      
      KEYS              : in   STD_LOGIC_VECTOR (4 downto 0);
      
      SELECT_REQ_IN     : in   STD_LOGIC_VECTOR (3 downto 0);
      SELECT_REQ_OUT    : out  STD_LOGIC_VECTOR (3 downto 0);
      
      INIT_ACTIVE       : in   STD_LOGIC;
      ACTIVE            : out  STD_LOGIC;
      
      INIT_SELECTED     : in   STD_LOGIC;
      SELECTED          : out  STD_LOGIC;

      CLK               : in   STD_LOGIC;
      RESET             : in   STD_LOGIC;
	  RESTART			: in   STD_LOGIC
		
   );
end cell;

architecture Behavioral of cell is
  constant IDX_TOP    : NATURAL := 0; -- index sousedni bunky nachazejici se nahore v signalech *_REQ_IN a *_REQ_OUT, index klavesy posun nahoru v signalu KEYS
                                      -- tzn. 1) pokud chci poslat kurzor sousedni bunce nahore, musim nastavit na jeden hodinovy takt SELECT_REQ_OUT(IDX_TOP) na '1'
                                      --      2) pokud plati, ze KEYS(IDX_TOP)='1', pak byla stisknuta klavesa nahoru
  constant IDX_LEFT   : NATURAL := 1; -- ... totez        ...                vlevo
  constant IDX_RIGHT  : NATURAL := 2; -- ... totez        ...                vpravo
  constant IDX_BOTTOM : NATURAL := 3; -- ... totez        ...                dole
  
  constant IDX_ENTER  : NATURAL := 4; -- index klavesy v KEYS, zpusobujici inverzi bunky (enter, klavesa 5)
	signal SELECTED_TMP	:	STD_LOGIC := '0';
	signal ACTIVE_TMP		:	STD_LOGIC := '0';
begin
	ACTIVE 	<= ACTIVE_TMP;
	SELECTED <= SELECTED_TMP;
	
process (CLK, RESET)	

begin
	
-------------------MASK := getmask(,,5,5);
	
if (RESET = '1' or RESTART = '1') then
	ACTIVE_TMP <= INIT_ACTIVE;
	SELECTED_TMP <= INIT_SELECTED;
	--ACTIVE <= INIT_ACTIVE;
	--SELECTED <= INIT_SELECTED;
elsif(rising_edge(clk))then
	SELECT_REQ_OUT <= (others => '0');
	INVERT_REQ_OUT <= (others => '0');
-------------------------------------------------------------
	if (INVERT_REQ_IN(IDX_TOP)= MASK.top) and (MASK.top = '1') then
			ACTIVE_TMP <= not ACTIVE_TMP;
			--ACTIVE <= not ACTIVE;
		
	elsif (INVERT_REQ_IN(IDX_LEFT)= MASK.lefts) and (MASK.lefts = '1') then
			ACTIVE_TMP <= not ACTIVE_TMP;
			--ACTIVE <= not ACTIVE;
			
	elsif (INVERT_REQ_IN(IDX_RIGHT)= MASK.rights) and (MASK.rights = '1') then
			ACTIVE_TMP <= not ACTIVE_TMP;
			--ACTIVE <= not ACTIVE;
			
	elsif (INVERT_REQ_IN(IDX_BOTTOM)= MASK.bottom) and (MASK.bottom = '1') then
			ACTIVE_TMP <= not ACTIVE_TMP;
			--ACTIVE <= not ACTIVE;
	end if;
	-------------------------------------------------------------
	if (SELECTED_TMP = '0') then
		
		if (SELECT_REQ_IN(IDX_TOP)= MASK.top) and (MASK.top = '1') then
				--SELECTED <= '1';
				SELECTED_TMP <= '1';
			
		elsif (SELECT_REQ_IN(IDX_LEFT)= MASK.lefts) and (MASK.lefts = '1') then
				--SELECTED <= '1';
				SELECTED_TMP <= '1';
				
		elsif (SELECT_REQ_IN(IDX_RIGHT)= MASK.rights) and (MASK.rights = '1') then
				--SELECTED <= '1';
				SELECTED_TMP <= '1';
				
		elsif (SELECT_REQ_IN(IDX_BOTTOM)= MASK.bottom) and (MASK.bottom = '1') then
				--SELECTED <= '1';
				SELECTED_TMP <= '1';
		end if;
		-------------------------------------------------------------
	else

		if (KEYS(IDX_TOP) = '1') and (MASK.top = '1') then
			SELECT_REQ_OUT(IDX_TOP) <= '1';
			--SELECTED <= '0';
			SELECTED_TMP <= '0';
		elsif (KEYS(IDX_LEFT) = '1') and (MASK.lefts = '1') then
			SELECT_REQ_OUT(IDX_LEFT) <= '1';
			--SELECTED <= '0';
			SELECTED_TMP <= '0';
		elsif (KEYS(IDX_RIGHT) = '1') and (MASK.rights = '1') then
			SELECT_REQ_OUT(IDX_RIGHT) <= '1';
			--SELECTED <= '0';
			SELECTED_TMP <= '0';
		elsif (KEYS(IDX_BOTTOM) = '1') and (MASK.bottom = '1') then
			SELECT_REQ_OUT(IDX_BOTTOM) <= '1';
			--SELECTED <= '0';
			SELECTED_TMP <= '0';
		end if;
	-------------------------------------------------------------

		if (KEYS(IDX_ENTER) = '1') and (MASK.top = '1') then
			INVERT_REQ_OUT(IDX_TOP) <= '1';
		end if;
		if (KEYS(IDX_ENTER) = '1') and (MASK.lefts = '1') then
			INVERT_REQ_OUT(IDX_LEFT) <= '1';
		end if;
		if (KEYS(IDX_ENTER) = '1') and (MASK.rights = '1') then
			INVERT_REQ_OUT(IDX_RIGHT) <= '1';
		end if;
		if (KEYS(IDX_ENTER) = '1') and (MASK.bottom = '1') then
			INVERT_REQ_OUT(IDX_BOTTOM) <= '1';
		end if;
		if (KEYS(IDX_ENTER) = '1') then
			ACTIVE_TMP <= not ACTIVE_TMP;
			--ACTIVE <= not ACTIVE;
		end if;
	end if;
end if;
-- Pozadavky na funkci (sekvencni chovani vazane na vzestupnou hranu CLK)
--   pri resetu se nastavi ACTIVE a SELECTED na vychozi hodnotu danou signaly INIT_ACTIVE a INIT_SELECTED
--   pokud je bunka aktivni a prijde signal z klavesnice, tak se bud presune aktivita pomoci SELECT_REQ na dalsi bunky nebo se invertuje stav bunky
-- a jejiho okoli pomoci INVERT_REQ (klavesa ENTER)
--   pokud bunka neni aktivni a prijde signal INVERT_REQ, invertuje svuj stav
--   pozadavky do okolnich bunek se posilaji a z okolnich bunek prijimaji, jen pokud je maska na prislusne pozici v '1'
end process;


end Behavioral;

