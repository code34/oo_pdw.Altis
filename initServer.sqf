		[] call compilefinal preprocessFileLineNumbers "oo_pdw.sqf";

		sleep 2;

		 _pdw = ["new"] call OO_PDW;
		["saveUnit", player] call _pdw;

		sleep 2;

		["clearUnit", player] call _pdw;
		hint "Clear all Player equipements";

		sleep 2;

		["loadUnit", player] call _pdw;
		hint "Restore All";

		hint "saving all objects";
		"saveObjects" call _pdw;

		sleep 2;
		hint "deleting all objects";

		deletevehicle vehicle1;
		deletevehicle vehicle2;
		deletevehicle ammo1;

		sleep 2;

		hint "loading all vehicles";
		"loadObjects" call _pdw;		




