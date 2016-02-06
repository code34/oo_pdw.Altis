		call compilefinal preprocessFileLineNumbers "oo_pdw.sqf";

		 _pdw = ["new", "inidbi"] call OO_PDW;
		
		 hint "save AI infantry groups";
		 "saveGroups" call _pdw;
		 sleep 2;

		 {deletevehicle _x;} foreach allunits;

		 hint "load AI infantry groups";
		"loadGroups" call _pdw;
		 sleep 2;

		hint "Save all players";
		"savePlayers" call _pdw;
		sleep 2;

		hint "Restore all Players";
		"loadPlayers" call _pdw;	
		sleep 2;
		
		//Filters example
		//_aroundpos = [[position player, 100], [position chopper, 10]];
		//["setAroundPos", _aroundpos] call _pdw;
		//["setExcludingTypes", ["B_Heli_Light_01_F"]] call _pdw;
		//["setExcludingMarkers", ["test1", "test2"]] call _pdw;

		hint "Save all objects";	
		"saveObjects" call _pdw;

		sleep 2;

		hint "Delete all objects";
		{
			if!(_x isKindOf "MAN") then {
			deletevehicle _x;
			};
		}foreach (allMissionObjects "All");
		sleep 2;
		
		_objects = "loadObjects" call _pdw;
		hint format ["Restore all objects %1", _objects];
		


		



