		[] call compilefinal preprocessFileLineNumbers "oo_pdw.sqf";

		sleep 2;

		 _pdw = ["new", "inidbi"] call OO_PDW;
		["saveUnit", [name player, player]] call _pdw;
		["saveInventory", [name player, player]] call _pdw;

		sleep 2;

		hint "Restore Unit";
		_object = ["loadUnit", name player] call _pdw;

		sleep 2;

		hint "Clear inventory";
		["clearInventory", _object] call _pdw;
		
		sleep 2 ;

		hint "Restore Inventory";
		["loadInventory", [name player, _object]] call _pdw;
		
		sleep 2;

		hint "Save all objects";
		"saveObjects" call _pdw;

		sleep 2;
		hint "Delete all objects";
		{deletevehicle _x;}foreach vehicles;

		sleep 2;
		
		_objects = "loadObjects" call _pdw;
		hint format ["Restore all objects %1", _objects];
		



