		[] call compilefinal preprocessFileLineNumbers "oo_pdw.sqf";

		sleep 5;

		 _pdw = ["new"] call OO_PDW;
		["SavePlayer", player] call _pdw;

		sleep 5;		

		["RemoveAll", player] call _pdw;
		hint "Remove All equipements";

		["LoadPlayer", player] call _pdw;
		hint "Restore All";


