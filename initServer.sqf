		call compilefinal preprocessFileLineNumbers "oo_pdw.sqf";
		
		sleep 2;

		 _pdw = ["new", "inidbi"] call OO_PDW;
		 ["setFileName", "mydb"] call _pdw;

		hint "Save player";
		["savePlayer", player] call _pdw;
		["saveInventory", [name player, player]] call _pdw;

		sleep 2;
		hint "Clear";
		["clearInventory", player] call _pdw;
		player setpos [16000,16000];
		sleep 2;

		hint "Restore Player";
		["loadPlayer", player] call _pdw;
		["loadInventory", [name player, player]] call _pdw;
		
		sleep 2;

		hint "Save all objects";
		"saveObjects" call _pdw;

		sleep 2;
		hint "Delete all objects";
		{deletevehicle _x;}foreach vehicles;

		sleep 2;
		
		_objects = "loadObjects" call _pdw;
		hint format ["Restore all objects %1", _objects];
		



