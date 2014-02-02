		call compilefinal preprocessFileLineNumbers "oo_pdw.sqf";

		 _pdw = ["new"] call OO_PDW;
		["SavePlayer", player] call OO_PDW;

		
		["RemoveAll", player] call OO_PDW;
		hint "Remove All equipements";

		sleep 5;

		["LoadPlayer", player] call OO_PDW;
		hint "Restore All";


