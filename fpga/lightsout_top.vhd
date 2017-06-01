library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.vga_controller_cfg.all;
use work.clkgen_cfg.all;



architecture main of tlv_pc_ifc is

   signal vga_mode  : std_logic_vector(60 downto 0); -- default 640x480x60

   signal rgbf 		: std_logic_vector(8 downto 0);
   signal rgb_cursor: std_logic_vector(8 downto 0);
   signal vga_rgb  	: std_logic_vector(8 downto 0);

   signal CELL_ID	: natural;  
   --signal red: std_logic_vector(2 downto 0);
   --signal green: std_logic_vector(2 downto 0);
   --signal blue: std_logic_vector(2 downto 0);

   alias red is rgbf(8 downto 6);
   alias green is rgbf(5 downto 3);
   alias blue is rgbf(2 downto 0);


   signal vga_row : std_logic_vector(11 downto 0);
   signal vga_col : std_logic_vector(11 downto 0);

 


--------------------------------------------------------------------



	-- character decoder
	signal char_symbol : std_logic_vector(3 downto 0) := "1010";
	signal char_data : std_logic;

	-- bcd 
	signal bcd_clk, bcd_reset, bcd_enable : std_logic;
	signal number1, number2, number3 : std_logic_vector(3 downto 0);

	--ASI cursor signals
	signal kbrd_data_out : std_logic_vector(15 downto 0);
	signal kbrd_data_vld : std_logic;

  signal ctl_enter,ctl_reset : std_logic;




   signal KEYS : std_logic_vector(4 downto 0);
   signal INIT_ACTIVE : std_logic_vector(24 downto 0) :=  "0010001010101010101000100";
   signal INIT_SELECTED : std_logic_vector(24 downto 0) :="0000000000001000000000000";
   signal ACTIVE : std_logic_vector(24 downto 0);
   signal SELECTED : std_logic_vector(24 downto 0);
 
   signal UP_SEL_REQ : std_logic_vector(24 downto 0);
   signal LEFT_SEL_REQ : std_logic_vector(24 downto 0);
   signal RIGHT_SEL_REQ : std_logic_vector(24 downto 0);
   signal DOWN_SEL_REQ : std_logic_vector(24 downto 0);
   signal UP_INV_REQ : std_logic_vector(24 downto 0);
   signal LEFT_INV_REQ : std_logic_vector(24 downto 0);
   signal RIGHT_INV_REQ : std_logic_vector(24 downto 0);
   signal DOWN_INV_REQ : std_logic_vector(24 downto 0);

--------------------------------------------------------------------

   
begin


   vga: entity work.vga_controller(arch_vga_controller) 
      generic map (REQ_DELAY => 1)
      port map (
         CLK    => CLK, 
         RST    => RESET,
         ENABLE => '1',
         MODE   => vga_mode,

         DATA_RED    => red,
         DATA_GREEN  => green,
         DATA_BLUE   => blue,
         ADDR_COLUMN => vga_col,
         ADDR_ROW    => vga_row,

         VGA_RED   => RED_V,
         VGA_BLUE  => BLUE_V,
         VGA_GREEN => GREEN_V,
         VGA_HSYNC => HSYNC_V,
         VGA_VSYNC => VSYNC_V
      );

    -- Nastaveni grafickeho rezimu (640x480, 60 Hz refresh)
   	setmode(r640x480x60, vga_mode);


   -- char 2 vga decoder
--   chardec : entity work.char_rom
--      port map (
--         ADDRESS => char_symbol,
--         ROW => vga_row(3 downto 0),
--         COLUMN => vga_col(2 downto 0),
--         DATA => char_data
--      );


   -- Keyboard controller
   kbrd_ctrl: entity work.keyboard_controller(arch_keyboard)
      port map (
         CLK => SMCLK,
         RST => RESET,

         DATA_OUT => kbrd_data_out(15 downto 0),
         DATA_VLD => kbrd_data_vld,
         
         KB_KIN   => KIN,
         KB_KOUT  => KOUT
      );

    --bcd counter
    bcd : entity work.bcd 
    	port map(

    		CLK => bcd_clk,
        	RESET => bcd_reset,
        	ENABLE => bcd_enable,
        	NUMBER1 => number1,
        	NUMBER2 => number2,
        	NUMBER3 => number3
    	);




F : for a in 0 to 24 generate
            begin 
            FF : if ((a /= 24)  and (a /=19))  generate
	            begin U1: entity work.cell
	            generic map(MASK => getmask(a/5,a mod 5, 5, 5))
	            port map    
	           (INVERT_REQ_IN(0)  => UP_INV_REQ(a),
	            INVERT_REQ_IN(1)  => LEFT_INV_REQ(a),  
	            INVERT_REQ_IN(2)  => RIGHT_INV_REQ((a+5) mod 24),
	            INVERT_REQ_IN(3)  => DOWN_INV_REQ((a + 1) mod 25),
	            INVERT_REQ_OUT(0) => DOWN_INV_REQ(a),
	            INVERT_REQ_OUT(1) => RIGHT_INV_REQ(a),
	            INVERT_REQ_OUT(2) => LEFT_INV_REQ((a+5) mod 24),
	            INVERT_REQ_OUT(3) => UP_INV_REQ((a+1) mod 25),
	            SELECT_REQ_IN(0)  => UP_SEL_REQ(a),  
	            SELECT_REQ_IN(1)  => LEFT_SEL_REQ(a),  
	            SELECT_REQ_IN(2)  => RIGHT_SEL_REQ((a+5) mod 24),
	            SELECT_REQ_IN(3)  => DOWN_SEL_REQ((a + 1) mod 25),
	            SELECT_REQ_OUT(0) => DOWN_SEL_REQ(a),
	            SELECT_REQ_OUT(1) => RIGHT_SEL_REQ(a),
	            SELECT_REQ_OUT(2) => LEFT_SEL_REQ((a+5) mod 24),  
	            SELECT_REQ_OUT(3) => UP_SEL_REQ((a+1) mod 25),  
	            KEYS => KEYS,
	            INIT_ACTIVE => INIT_ACTIVE(a),
	            ACTIVE => ACTIVE(a),
	            INIT_SELECTED => INIT_SELECTED(a),
	            SELECTED => SELECTED(a),
	            CLK => CLK,
	            RESET => RESET,
				RESTART => ctl_reset
				);
			end generate FF;

      		F24 :  if ( a = 24 ) generate
	            begin U1: entity work.cell
	            generic map(MASK => getmask(a/5,a mod 5, 5, 5))
	            port map    
	           (INVERT_REQ_IN(0)  => UP_INV_REQ(a),  
	            INVERT_REQ_IN(1)  => LEFT_INV_REQ(a),  
	            INVERT_REQ_IN(2)  => RIGHT_INV_REQ(0),
	            INVERT_REQ_IN(3)  => DOWN_INV_REQ((a + 1) mod 25),
	            INVERT_REQ_OUT(0) => DOWN_INV_REQ(a),
	            INVERT_REQ_OUT(1) => RIGHT_INV_REQ(a),
	            INVERT_REQ_OUT(2) => LEFT_INV_REQ(0),  
	            INVERT_REQ_OUT(3) => UP_INV_REQ((a+1) mod 25),
	            SELECT_REQ_IN(0)  => UP_SEL_REQ(a),
	            SELECT_REQ_IN(1)  => LEFT_SEL_REQ(a),
	            SELECT_REQ_IN(2)  => RIGHT_SEL_REQ(0),
	            SELECT_REQ_IN(3)  => DOWN_SEL_REQ((a + 1) mod 25),
	            SELECT_REQ_OUT(0) => DOWN_SEL_REQ(a),
	            SELECT_REQ_OUT(1) => RIGHT_SEL_REQ(a),
	            SELECT_REQ_OUT(2) => LEFT_SEL_REQ(0),
	            SELECT_REQ_OUT(3) => UP_SEL_REQ((a+1) mod 25),
	            KEYS => KEYS,
	            INIT_ACTIVE => INIT_ACTIVE(a),
	            ACTIVE => ACTIVE(a),
	            INIT_SELECTED => INIT_SELECTED(a),
	            SELECTED => SELECTED(a),
	            CLK => CLK,
	            RESET => RESET,
				RESTART => ctl_reset
				);
            end generate F24;

     		F19 :  if ( a = 19 ) generate
	            begin U1: entity work.cell
	            generic map(MASK => getmask(a/5,a mod 5, 5, 5))
	            port map      
	           (INVERT_REQ_IN(0)  => UP_INV_REQ(a),
	            INVERT_REQ_IN(1)  => LEFT_INV_REQ(a),
	            INVERT_REQ_IN(2)  => RIGHT_INV_REQ(24),
	            INVERT_REQ_IN(3)  => DOWN_INV_REQ((a + 1) mod 25),
	            INVERT_REQ_OUT(0) => DOWN_INV_REQ(a),
	            INVERT_REQ_OUT(1) => RIGHT_INV_REQ(a),
	            INVERT_REQ_OUT(2) => LEFT_INV_REQ(24),
	            INVERT_REQ_OUT(3) => UP_INV_REQ((a+1) mod 25),
	            SELECT_REQ_IN(0)  => UP_SEL_REQ(a),  
	            SELECT_REQ_IN(1)  => LEFT_SEL_REQ(a),
	            SELECT_REQ_IN(2)  => RIGHT_SEL_REQ(24),
	            SELECT_REQ_IN(3)  => DOWN_SEL_REQ((a + 1) mod 25),
	            SELECT_REQ_OUT(0) => DOWN_SEL_REQ(a),
	            SELECT_REQ_OUT(1) => RIGHT_SEL_REQ(a),
	            SELECT_REQ_OUT(2) => LEFT_SEL_REQ(24),
	            SELECT_REQ_OUT(3) => UP_SEL_REQ((a+1) mod 25),  
	            KEYS => KEYS,
	            INIT_ACTIVE => INIT_ACTIVE(a),
	            ACTIVE => ACTIVE(a),
	            INIT_SELECTED => INIT_SELECTED(a),
	            SELECTED => SELECTED(a),
	            CLK => CLK,
	            RESET => RESET,
				RESTART => ctl_reset
				);
        	end generate F19;
    end generate F;



cursor: process(CLK)
variable in_access : std_logic := '0';
begin
    if (CLK'event and CLK='1') then
          KEYS<="00000";
			ctl_reset <= '0';
			bcd_reset <= '0';
			bcd_enable <= '0';
			
      if (in_access='0') then
          if (kbrd_data_vld='1') then
              in_access := '1';
              if (kbrd_data_out(9)='1') then  	 -- klavesa 6 vpravo
                   KEYS(3) <= '1';
				   bcd_enable <= '1';
              elsif (kbrd_data_out(1)='1') then  -- klavesa 4 vlevo
                   KEYS(0) <= '1';
				   bcd_enable <= '1';
              elsif (kbrd_data_out(4)='1') then  -- klavesa 2 nahoru
                   KEYS(1) <= '1';
				   bcd_enable <= '1';
              elsif (kbrd_data_out(6)='1') then  -- klavesa 8 dolu
                   KEYS(2) <= '1';
				   bcd_enable <= '1';
              elsif (kbrd_data_out(5)='1') then  -- klavesa 5 enter   
                   KEYS(4) <= '1';
				   bcd_enable <= '1';
 
              elsif (kbrd_data_out(12)='1') then
                    ctl_reset <= '1';
					bcd_reset <= '1';
										
			  elsif (kbrd_data_out(13)='1') then
                    ctl_reset <= '1';
					bcd_reset <= '1';
										
			  elsif (kbrd_data_out(14)='1') then
                    ctl_reset <= '1';
					bcd_reset <= '1';
										
			  elsif (kbrd_data_out(15)='1') then
                    ctl_reset <= '1';
					bcd_reset <= '1';
 
              end if;
          end if;

      else
          if (kbrd_data_vld='0')  then
              in_access := '0';
          end if;
      end if;
    end if;
end process;




CELL_ID<= 0 when ((vga_row(11 downto 6) = 1) and (vga_col(11 downto 6) = 2)) else
		  1 when ((vga_row(11 downto 6) = 1) and (vga_col(11 downto 6) = 3)) else
		  2 when ((vga_row(11 downto 6) = 1) and (vga_col(11 downto 6) = 4)) else
		  3 when ((vga_row(11 downto 6) = 1) and (vga_col(11 downto 6) = 5)) else
		  4 when ((vga_row(11 downto 6) = 1) and (vga_col(11 downto 6) = 6)) else
		  5 when ((vga_row(11 downto 6) = 2) and (vga_col(11 downto 6) = 2)) else
		  6 when ((vga_row(11 downto 6) = 2) and (vga_col(11 downto 6) = 3)) else
		  7 when ((vga_row(11 downto 6) = 2) and (vga_col(11 downto 6) = 4)) else
		  8 when ((vga_row(11 downto 6) = 2) and (vga_col(11 downto 6) = 5)) else
		  9 when ((vga_row(11 downto 6) = 2) and (vga_col(11 downto 6) = 6)) else
		 10 when ((vga_row(11 downto 6) = 3) and (vga_col(11 downto 6) = 2)) else
		 11 when ((vga_row(11 downto 6) = 3) and (vga_col(11 downto 6) = 3)) else
		 12 when ((vga_row(11 downto 6) = 3) and (vga_col(11 downto 6) = 4)) else
		 13 when ((vga_row(11 downto 6) = 3) and (vga_col(11 downto 6) = 5)) else
		 14 when ((vga_row(11 downto 6) = 3) and (vga_col(11 downto 6) = 6)) else
		 15 when ((vga_row(11 downto 6) = 4) and (vga_col(11 downto 6) = 2)) else
		 16 when ((vga_row(11 downto 6) = 4) and (vga_col(11 downto 6) = 3)) else
		 17 when ((vga_row(11 downto 6) = 4) and (vga_col(11 downto 6) = 4)) else
		 18 when ((vga_row(11 downto 6) = 4) and (vga_col(11 downto 6) = 5)) else
		 19 when ((vga_row(11 downto 6) = 4) and (vga_col(11 downto 6) = 6)) else
		 20 when ((vga_row(11 downto 6) = 5) and (vga_col(11 downto 6) = 2)) else
		 21 when ((vga_row(11 downto 6) = 5) and (vga_col(11 downto 6) = 3)) else
		 22 when ((vga_row(11 downto 6) = 5) and (vga_col(11 downto 6) = 4)) else
		 23 when ((vga_row(11 downto 6) = 5) and (vga_col(11 downto 6) = 5)) else
		 24 when ((vga_row(11 downto 6) = 5) and (vga_col(11 downto 6) = 6)) else
		 26;

vga_rgb <= rgbf;
----------------------------------------------------------
--lcdc_u : entity work.lcd_ctrl_high
--port map(
--   CLK         => CLK,
--   RESET       => RESET,

   -- user interface
--   DATA        => mx_lcd_data,
--   WRITE       => fsm_lcd_wr,
--   CLEAR       => fsm_lcd_clr,

   -- lcd interface
--   LRS         => LRS,
--   LRW         => LRW,
--   LE          => LE,
--   LD          => LD
--);
-----------------------------------------------------
process (vga_col, vga_row, CLK)

begin
if (CLK'event and CLK='1') then

	if (CELL_ID = 26) then
		rgbf <= "000000000"; --cerna okolo
	end if;



  if ((ACTIVE(CELL_ID) = '1') and (SELECTED(CELL_ID) = '1') and (CELL_ID < 25)) then
  	rgbf <= "011011011";
  end if;

  if ((ACTIVE(CELL_ID) = '1') and (SELECTED(CELL_ID) = '0') and (CELL_ID < 25)) then
  	rgbf <= "111111111";
  end if;

  if ((ACTIVE(CELL_ID) = '0') and (SELECTED(CELL_ID) = '1') and (CELL_ID < 25)) then
  	rgbf <= "001001001";
  end if;

  if ((ACTIVE(CELL_ID) = '0') and (SELECTED(CELL_ID) = '0') and (CELL_ID < 25)) then
  	rgbf <= "000000000";
  end if;
  ------------------------------------------------------------
  
  ------------------------------------------------------------
 
end if ;
end process;
end main;

