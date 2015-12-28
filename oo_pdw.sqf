	/*
	Author: code34 nicolas_boiteux@yahoo.fr
	Copyright (C) 2014-2016 Nicolas BOITEUX

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
		PRIVATE VARIABLE("code","inidbi");

		PUBLIC FUNCTION("string","constructor") { 
			if(_this == "inidbi") then {
				if !(isClass(configFile >> "cfgPatches" >> "inidbi2")) exitwith { 
					MEMBER("ToLog", "PDW: requires INIDBI2");
				};
				_inidbi = ["new", "oo_pdw"] call OO_INIDBI;
				MEMBER("inidbi", _inidbi);
			};
			MEMBER("driver", _this);
		};

		PUBLIC FUNCTION("string","setDbName") {
			["setDbName", _this] call MEMBER("inidbi", nil);
		};

		PRIVATE FUNCTION("array","read") {
			private ["_driver", "_key", "_result", "_default"];
			
			_key = _this select 0;
			_default = _this select 1;

			_driver = MEMBER("driver", nil);

			switch (_driver) do {
				case "inidbi": {
					_result = ["read", ["pdw", _key, _default]] call MEMBER("inidbi", nil);
				};

				case "profile": {
					_result = profileNamespace getVariable _key;
				};

				default {
					_result = false;
				};
			};
			_result;
		};

		PRIVATE FUNCTION("array","write") {
			private ["_driver", "_key", "_array", "_result"];
			
			_key = _this select 0;
			_array = _this select 1;

			_driver = MEMBER("driver", nil);

			_result = ["write", ["pdw", _key, _array]] call MEMBER("inidbi", nil);

			switch (_driver) do {
				case "inidbi": {
					_result = ["write", ["pdw", _key, _array]] call MEMBER("inidbi", nil);
				};

				case "profile": {
					profileNamespace setVariable [_key, _array];
					saveProfileNamespace;
					_result = true;
				};

				default {
					_result = false;
				};
			};
			_result;
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
			private ["_data", "_save", "_counter", "_name", "_counter2"];
			_counter = -1;
			_counter2 = -1;
			{
				if(!isplayer(leader _x)) then {
					_counter = _counter + 1;
					_data  = [];
					{
						if(alive _x) then {
							_counter2 = _counter2 + 1;
							_name = str(_counter2);
							_data = _data + [_name];
							["saveUnit", [_name, _x]] call _pdw;
							["saveInventory", [_name, _x]] call _pdw;
							sleep 0.001;
						};
					} foreach units _x;
					_data = [str(side _x), _data];
					_save = [format ["groups_%1", _counter], _data];
					MEMBER("write", _save);
					sleep 0.001;
				};
			}foreach allGroups;
			_save = ["pdw_groups", _counter];
			MEMBER("write", _save);
		};

		PUBLIC FUNCTION("","loadGroups") {
			private ["_array", "_name", "_counter", "_group", "_units", "_unit", "_id", "_side"];
			
			_save = ["pdw_groups", -1];
			_counter = MEMBER("read", _save);

			_objects = [];
			for "_x" from 0 to _counter step 1 do {
				_name = [format ["groups_%1", _x], []];
				_array = MEMBER("read", _name);
				_side = _array select 0;
				_units = _array select 1;

				switch (_side) do {
					case "CIV" : {
						_group = creategroup civilian;
					};

					case "GUER" : {
						_group = creategroup resistance;
					};

					default {
						_group = call compile format ["creategroup %1;", _side];
					};
				};

				{
					_unit = MEMBER("loadUnit", _x);
					[_unit] joinSilent _group;
					_id = [_x, _unit];
					MEMBER("loadInventory", _id);
					sleep 0.001;
				}foreach _units;
				sleep 0.001;
			};
		};
		
		PUBLIC FUNCTION("","saveObjects") {
			private ["_save", "_counter"];
			_counter = -1;
			{
			 	if!((_x isKindOf "MAN") or (_x isKindOf "LOGIC")) then {
					_counter = _counter + 1;
					_save = [format ["objects_%1", _counter], _x];
					MEMBER("saveObject", _save);
				};
				sleep 0.01;
			}foreach (allMissionObjects "All");
			_save = ["pdw_objects", _counter];
			MEMBER("write", _save);
		};

		PUBLIC FUNCTION("","loadObjects") {
			private ["_name", "_counter", "_object","_objects"];
			
			_save = ["pdw_objects", 0];
			_counter = MEMBER("read", _save);

			_objects = [];
			for "_x" from 0 to _counter step 1 do {
				_name = format ["objects_%1", _x];
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

			_name = "pdw_object_" + _name;

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
			
			_save = [_name, _array];
			_result = MEMBER("write", _save);
		};

		PUBLIC FUNCTION("string","loadObject") {
			private ["_array", "_name", "_object", "_item", "_count"];
			
			_name = _this;

			if (isnil "_name") exitwith { 
				MEMBER("ToLog", "PDW: require a object name to loadObject");
			};

			_name = "pdw_object_" + _name;

			_save = [_name, []];
			_array = MEMBER("read", _save);

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

		PUBLIC FUNCTION("object","savePlayer") {
			private ["_name", "_object", "_result", "_array"];

			_object = _this;
			_name = getPlayerUID _this;
			
			if (isnil "_name") exitwith { 
				MEMBER("ToLog", "PDW: require a unit name to savePlayer");
			};

			_name = format["pdw_unit_%1", getPlayerUID _this];

			_array = [(getpos _object), (getdir _object), (getdammage _object)];
			
			_save = [_name, _array];
			MEMBER("write", _save);
		};

		PUBLIC FUNCTION("object","loadPlayer") {
			private ["_name", "_array", "_position", "_damage", "_dir", "_typeof", "_unit"];

			_name = getPlayerUID _this;

			if (isnil "_name") exitwith { 
				MEMBER("ToLog", "PDW: require a unit name to loadUnit");
			};

			_name = format["pdw_unit_%1", getPlayerUID _this];		

			_save = [_name, []];
			_array = MEMBER("read", _save);
			if(_array isequalto "") exitwith {false};	

			_position	= _array select 0;
			_dir		= _array select 1;
			_damage 	= _array select 2;

			_this setpos _position;
			_this setdir _dir;
			_this setdammage _damage;
		};

		PUBLIC FUNCTION("array","saveUnit") {
			private ["_name", "_object", "_result", "_array"];

			_name = _this select 0;
			_object = _this select 1;
			
			if (isnil "_name") exitwith { 
				MEMBER("ToLog", "PDW: require a unit name to saveUnit");
			};

			_name = "pdw_unit_" + _name;

			_array = [(typeof _object), (getpos _object), (getdir _object), (getdammage _object)];
			
			_save = [_name, _array];
			MEMBER("write", _save);
		};

		PUBLIC FUNCTION("string","loadUnit") {
			private ["_name", "_array", "_position", "_damage", "_dir", "_typeof", "_unit"];

			_name = _this;

			if (isnil "_name") exitwith { 
				MEMBER("ToLog", "PDW: require a unit name to loadUnit");
			};

			_name = "pdw_unit_" + _name;			

			_save = [_name, []];
			_array = MEMBER("read", _save);
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

			_name = "pdw_inventory_" + _name;			

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

			_save = [_name, _array];
			MEMBER("write", _save);
		};

		PUBLIC FUNCTION("array","loadInventory") {
			private ["_name", "_array", "_headgear", "_goggles", "_uniform", "_uniformitems", "_vest", "_vestitems", "_backpack", "_backpackitems", "_primaryweapon", "_primaryweaponitems", "_primaryweaponmagazine", "_secondaryweapon", "_secondaryweaponitems", "_secondaryweaponmagazine", "_handgun", "_handgunweaponitems", "_handgunweaponmagazine", "_assigneditems", "_position", "_damage", "_dir", "_object"];

			_name = _this select 0;
			_object = _this select 1;

			if (isnil "_name") exitwith { 
				MEMBER("ToLog", "PDW: require a unit name to loadUnit");
			};

			_name = "pdw_inventory_" + _name;			

			MEMBER("ClearInventory", _object);

			_save = [_name, []];
			_array = MEMBER("read", _save);
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

			{
				if(_x != "") then {
					_object addItemToUniform _x;
				};
			}foreach _uniformitems;
	
			{
				if(_x != "") then {
					_object addItemToVest _x;
				};
			}foreach _vestitems;
	
			if(format["%1", _backpack] != "") then {
				_object addbackpack _backpack;
				{
					if(_x != "") then {
						_object addItemToBackpack _x;
					};
				} foreach _backpackitems;
			};
	
			{
				if(_x != "") then {
					_object addMagazine _x;
				};
			} foreach _primaryweaponmagazine;

			//must be after assign items to secure loading mags
			_object addweapon _primaryweapon;
	
			{
				if(_x != "") then {
					_object addPrimaryWeaponItem _x;
				};
			} foreach _primaryweaponitems;
	
			{
				if(_x != "") then {
					_object addMagazine _x;
				};
			} foreach _secondaryweaponmagazine;

			_object addweapon _secondaryweapon;
	
			{
				if(_x != "") then {
					_object addSecondaryWeaponItem _x;
				};
			} foreach _secondaryweaponitems;
	
	
			{
				if(_x != "") then {
					_object addMagazine _x;
				};
			} foreach _handgunweaponmagazine;

			_object addweapon _handgunweapon;
	
			{
				if(_x != "") then {
					_object addHandgunItem _x;
				};
			} foreach _handgunweaponitems;
	
			{
				if(_x != "") then {
					_object additem _x;
					_object assignItem _x;
				};
			} foreach _assigneditems;

			_object addWeapon "ItemGPS";

			if (needReload player == 1) then {reload player};
			true;
		};

		PUBLIC FUNCTION("","deconstructor") { 
			DELETE_VARIABLE("driver");
			DELETE_VARIABLE("inidbi");
		};
	ENDCLASS;