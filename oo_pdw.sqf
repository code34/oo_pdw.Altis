	/*
	Author: code34 nicolas_boiteux@yahoo.fr
	Copyright (C) 2014 Nicolas BOITEUX

	CLASS OO_PDW -  Pesistent Data World
	
	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.
	
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
	
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>. 
	*/

	#include "oop.h"

	CLASS("OO_PDW")
		PRIVATE VARIABLE("string","driver");
		PUBLIC FUNCTION("string","constructor") { 
			private ["_array"];
			if !(isClass(configFile >> "cfgPatches" >> "inidbi")) exitwith { 
				MEMBER("ToLog", "PDW: requires INIDBI");
			};
			[] call compilefinal preProcessFile "\inidbi\init.sqf";
			MEMBER("driver", _this);
		};

		PUBLIC FUNCTION("","getObjects") FUNC_GETVAR("objects");

		PRIVATE FUNCTION("string","read") {
			private ["_driver", "_key"];
			
			_key = _this;

			_driver = MEMBER("driver", nil);
			switch (_driver) do {
				case "inidbi": {
					_array = [missionName, "pdw", _key] call iniDB_read;
				};

				case "profile": {
					_array = profileNamespace getVariable _key;
				};

				default {

				};
			};
		};

		PRIVATE FUNCTION("array","write") {
			private ["_driver", "_key", "_array"];
			
			_key = _this select 0;
			_array = _this select 1;

			_driver = MEMBER("driver", nil);

			switch (_driver) do {
				case "inidbi": {
					[missionName, "pdw", _key, _array] call iniDB_write;
				};

				case "profile": {
					profileNamespace setVariable [_key, _array];
					saveProfileNamespace;
				};

				default {

				};
			};
		};		

		PUBLIC FUNCTION("string","toLog") {
			hint _this;
			diag_log _this;
		};

		PUBLIC FUNCTION("object","clearInventory") {
			removeallweapons _this;
			removeGoggles _this;
			removeHeadgear _this;
			removeVest _this;
			removeUniform _this;
			removeAllAssignedItems _this;
			removeBackpack _this;
		};

		PUBLIC FUNCTION("object","clearObject") {
			clearWeaponCargoGlobal _this;
			clearMagazineCargoGlobal _this;
			clearItemCargoGlobal _this;
			clearBackpackCargoGlobal _this;
		};

		PUBLIC FUNCTION("","saveGroups") {
			private ["_name", "_counter"];
			{
				_save = [format ["PDW_UNIT_%1", _foreachindex], _x];
				MEMBER("saveUnit", _save);
				_counter = _foreachindex;
				sleep 0.01;
			}foreach allGroups;
			_result = [missionName, "object", "pdw_groups", _counter] call iniDB_write;
		};

		PUBLIC FUNCTION("","saveObjects") {
			private ["_name", "_counter"];
			{
				_save = [format ["PDW_OBJECTS_%1", _foreachindex], _x];
				MEMBER("saveObject", _save);
				_counter = _foreachindex;
				sleep 0.01;
			}foreach vehicles;
			_result = [missionName, "object", "pdw_objects", _counter] call iniDB_write;
		};

		PUBLIC FUNCTION("","loadObjects") {
			private ["_name", "_counter", "_object","_objects"];
			
			_counter = [missionName, "object", "pdw_objects","SCALAR"] call iniDB_read;
			_objects = [];
			for "_x" from 0 to _counter step 1 do {
				_name = format ["PDW_OBJECTS_%1", _x];
				_object = MEMBER("loadObject", _name);
				_objects = _objects + [_object];
				sleep 0.01;
			};
			_objects;
		};

		PUBLIC FUNCTION("array","saveObject") {
			private ["_array", "_name", "_result", "_object"];
			
			_name = _this select 0;
			_object = _this select 1;
			
			if (isnil "_name") exitwith { 
				MEMBER("ToLog", "PDW: require a object name to saveObject");
			};

			_array = [
				(typeof _object),
				(getpos _object),
				(getdir _object),
				(getDammage _object),
				(getWeaponCargo _object),
				(getMagazineCargo _object),
				(getItemCargo _object),
				(getBackpackCargo _object)
				];
			_result = [missionName, "object", _name, _array] call iniDB_write;
		};

		PUBLIC FUNCTION("string","loadObject") {
			private ["_array", "_name", "_object", "_item", "_count"];
			
			_name = _this;

			if (isnil "_name") exitwith { 
				MEMBER("ToLog", "PDW: require a object name to loadObject");
			};
			_array = [missionName, "object", _name,"ARRAY"] call iniDB_read;
			if(_array isequalto "") exitwith {false};

			_object = createVehicle [(_array select 0), (_array select 1), [], 0, "NONE"];
			_object setposatl (_array select 1);
			_object setdir (_array select 2);
			_object setdamage (_array select 3);

			MEMBER("ClearObject", _this);

			_items = (_array select 4) select 0;
			_count = (_array select 4) select 1;
			{
				_object addWeaponCargoGlobal [_x, _count select _foreachindex];
			}foreach _items;

			_items = (_array select 5) select 0;
			_count = (_array select 5) select 1;
			{
				_object addMagazineCargoGlobal [_x, _foreachindex];
			}foreach _items;

			_items = (_array select 6) select 0;
			_count = (_array select 6) select 1;
			{
				_object addItemCargoGlobal [_x, _count select _foreachindex];
			}foreach _items;

			_items = (_array select 7) select 0;
			_count = (_array select 7) select 1;
			{
				_object addBackpackCargoGlobal [_x, _count select _foreachindex];
			}foreach _items;
			_object;
		};

		PUBLIC FUNCTION("array","saveUnit") {
			private ["_name", "_object", "_result", "_array"];

			_name = _this select 0;
			_object = _this select 1;
			
			if (isnil "_name") exitwith { 
				MEMBER("ToLog", "PDW: require a unit name to saveUnit");
			};

			_array = [(typeof _object), (getpos _object), (getdir _object), (getdammage _object)];
			
			_result = [missionName, "unit", _name, _array] call iniDB_write;
		};

		PUBLIC FUNCTION("string","loadUnit") {
			private ["_name", "_array", "_position", "_damage", "_dir", "_typeof", "_unit"];

			_name = _this;

			if (isnil "_name") exitwith { 
				MEMBER("ToLog", "PDW: require a unit name to loadUnit");
			};

			_array = [missionName, "unit", _name,"ARRAY"] call iniDB_read;
			if(_array isequalto "") exitwith {false};	

			_typeof 	= _array select 0;
			_position	= _array select 1;
			_dir		= _array select 2;
			_damage 	= _array select 3;

			_unit = createVehicle [_typeof, _position,[], 0, "NONE"];
			_unit setpos _position;
			_unit setdir _dir;
			_unit setdammage _damage;
			_unit;
		};

		PUBLIC FUNCTION("array","saveInventory") {
			private ["_name", "_object", "_result", "_array"];

			_name = _this select 0;
			_object = _this select 1;
			
			if (isnil "_name") exitwith { 
				MEMBER("ToLog", "PDW: require a unit name to saveUnit");
			};

			_array = [
				(headgear _object), 
				(goggles _object), 
				(uniform _object), 
				(UniformItems _object), 
				(vest _object), 
				(VestItems _object), 
				(backpack _object), 
				(backpackItems _object), 
				(primaryWeapon _object), 
				(primaryWeaponItems _object),
				(primaryWeaponMagazine _object),
				(secondaryWeapon _object),
				(secondaryWeaponItems _object),
				(secondaryWeaponMagazine _object),
				(handgunWeapon _object),
				(handgunItems _object),
				(handgunMagazine _object),
				(assignedItems _object)
			];
			_result = [missionName, "inventory", _name, _array] call iniDB_write;
		};

		PUBLIC FUNCTION("array","loadInventory") {
			private ["_name", "_array", "_headgear", "_goggles", "_uniform", "_uniformitems", "_vest", "_vestitems", "_backpack", "_backpackitems", "_primaryweapon", "_primaryweaponitems", "_primaryweaponmagazine", "_secondaryweapon", "_secondaryweaponitems", "_secondaryweaponmagazine", "_handgun", "_handgunweaponitems", "_handgunweaponmagazine", "_assigneditems", "_position", "_damage", "_dir"];

			_name = _this select 0;
			_object = _this select 1;

			if (isnil "_name") exitwith { 
				MEMBER("ToLog", "PDW: require a unit name to loadUnit");
			};

			MEMBER("ClearInventory", _object);

			_array = [missionName, "inventory", _name,"ARRAY"] call iniDB_read;
			if(_array isequalto "") exitwith {false};	

			_headgear = _array select 0;
			_goggles = _array select 1;
			_uniform = _array select 2;
			_uniformitems = _array select 3;
			_vest = _array select 4;
			_vestitems = _array select 5;
			_backpack = _array select 6;
			_backpackitems = _array select 7;
			_primaryweapon = _array select 8;
			_primaryweaponitems = _array select 9;
			_primaryweaponmagazine = _array select 10;
			_secondaryweapon = _array select 11;
			_secondaryweaponitems = _array select 12;
			_secondaryweaponmagazine = _array select 13;
			_handgunweapon = _array select 14;
			_handgunweaponitems = _array select 15;
			_handgunweaponmagazine = _array select 16;
			_assigneditems = _array select 17;

			_object addHeadgear _headgear;
			_object forceAddUniform _uniform;
			_object addGoggles _goggles;
			_object addVest _vest;
			_object addweapon _primaryweapon;
			_object addweapon _secondaryweapon;
			_object addweapon _handgunweapon;

			{
				_object addItemToUniform _x;
			}foreach _uniformitems;
	
			{
				_object addItemToVest _x;
			}foreach _vestitems;
	
			if(format["%1", _backpack] != "") then {
				_object addbackpack _backpack;
				{
					_object addItemToBackpack _x;
				} foreach _backpackitems;
			};
	
			{
				_object addMagazine _x;
			} foreach _primaryweaponmagazine;

			{
				_object addPrimaryWeaponItem _x;
			} foreach _primaryweaponitems;
	
			{
				_object addMagazine _x;
			} foreach _secondaryweaponmagazine;
	
			{
				_object addSecondaryWeaponItem _x;
			} foreach _secondaryweaponitems;
	
	
			{
				_object addMagazine _x;
			} foreach _handgunweaponmagazine;
	
			{
				_object addHandgunItem _x;
			} foreach _handgunweaponitems;
	
			{
				_object additem _x;
				_object assignItem _x;
			} foreach _assigneditems;
			if (needReload _object == 1) then {reload _object};
			true;
		};

		PUBLIC FUNCTION("array","deconstructor") { };
	ENDCLASS;