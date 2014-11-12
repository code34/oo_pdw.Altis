		[] call compilefinal preprocessFileLineNumbers "oo_pdw.sqf";

		sleep 2;

		 _pdw = ["new"] call OO_PDW;
		["savePlayer", player] call _pdw;

		sleep 2;

		["clearPlayer", player] call _pdw;
		hint "Clear all Player equipements";

		sleep 2;

		["loadPlayer", player] call _pdw;
		hint "Restore All";


