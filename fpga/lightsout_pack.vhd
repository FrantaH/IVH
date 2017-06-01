--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--
----------------------------
--Jmeno: Frantisek Horazny
--Login: xhoraz02
----------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;

package lightsout_pack is

 type mask_t is
  record
    lefts: std_logic;
    rights: std_logic;
	 top: std_logic;
	 bottom: std_logic;
 end record;
 
	function getmask (x,y : natural; COLUMNS, ROWS : natural) 
	return mask_t;

end lightsout_pack;

package body lightsout_pack is


  function getmask (x,y : natural; COLUMNS, ROWS : natural) return mask_t is
	variable maska:mask_t;
  begin
  
   maska.lefts := '1';
  maska.rights := '1';
    maska.top := '1';
 maska.bottom := '1';
  
	if (x = 0) then 
		maska.lefts:= '0';
	elsif (x = (COLUMNS - 1)) then 
		maska.rights:= '0';
	end if;
	
	if (y = 0) then 
		maska.top:= '0';
	elsif (y = (ROWS - 1)) then 
		maska.bottom:= '0';
   end if;
	
   return maska; 
  end getmask;

end lightsout_pack;