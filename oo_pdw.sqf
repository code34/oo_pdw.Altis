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
		PUBLIC FUNCTION("","constructor") { 
			if !(isClass(configFile >> "cfgPatches" >> "inidbi")) exitwith { 
				MEMBER("ToLog", "PDW: requires INIDBI");
			};
			[] call compilefinal preProcessFile "\inidbi\init.sqf";
		};

		PUBLIC FUNCTION("string","toLog") {
			hint _this;
			diag_log _this;
		};

		PUBLIC FUNCTION("object","clearUnit") {
			removeallweapons _this;
			removeGoggles _this;
			removeHeadgear _this;
			removeVest _this;
			removeUniform _this;
			removeAllAssignedItems _this;
			removeBackpack _this;
		};

		PUBLIC FUNCTION("object","clearVehicle") {
			clearWeaponCargoGlobal _this;
			clearMagazineCargoGlobal _this;
			clearItemCargoGlobal _this;
			clearBackpackCargoGlobal _this;
		};

		PUBLIC FUNCTION("","saveVehicles") {
			private ["_name", "_counter"];
			{
				_save = [format ["PDW_VEHICLES_%1", _foreachindex], _x];
				MEMBER("saveVehicle", _save);
				_counter = _foreachindex;
				sleep 0.01;
			}foreach vehicles;
			_result = [missionName, "vehicle", "pdw_vehicles", _counter] call iniDB_write;
		};

		PUBLIC FUNCTION("","loadVehicles") {
			private ["_name", "_counter"];
			_counter = [missionName, "vehicle", "pdw_vehicles","SCALAR"] call iniDB_read;
			for "_x" from 0 to _counter step 1 do {
				_name = format ["PDW_VEHICLES_%1", _x];
				MEMBER("loadVehicle", _name);
				sleep 0.01;
			};
		};

		PUBLIC FUNCTION("array","saveVehicle") {
			private ["_array", "_name", "_result", "_object"];
			
			_name = _this select 0;
			_object = _this select 1;
			
			if (isnil "_name") exitwith { 
				MEMBER("ToLog", "PDW: require a vehicle name to SaveVehicle");
			};

			_array = [
				(typeof _object),
				(getposatl _object),
				(getdir _object),
				(getDammage _object),
				(getWeaponCargo _object),
				(getMagazineCargo _object),
				(getItemCargo _object),
				(getBackpackCargo _object)
				];
			_result = [missionName, "vehicle", _name, _array] call iniDB_write;
		};

		PUBLIC FUNCTION("string","loadVehicle") {
			private ["_array", "_name", "_vehicle", "_item", "_count"];
			
			_name = _this;

			if (isnil "_name") exitwith { 
				MEMBER("ToLog", "PDW: require a vehicle name to LoadVehicle");
			};
			_array = [missionName, "vehicle", _name,"ARRAY"] call iniDB_read;
			if(_array isequalto "") exitwith {false};

			_vehicle = createVehicle [(_array select 0), (_array select 1), [], 0, "NONE"];
			_vehicle setposatl (_array select 1);
			_vehicle setdir (_array select 2);
			_vehicle setdamage (_array select 3);

			MEMBER("ClearVehicle", _this);

			_items = (_array select 4) select 0;
			_count = (_array select 4) select 1;
			{
				_vehicle addWeaponCargoGlobal [_x, _count select _foreachindex];
			}foreach _items;

			_items = (_array select 5) select 0;
			_count = (_array select 5) select 1;
			{
				_vehicle addMagazineCargoGlobal [_x, _foreachindex];
			}foreach _items;

			_items = (_array select 6) select 0;
			_count = (_array select 6) select 1;
			{
				_vehicle addItemCargoGlobal [_x, _count select _foreachindex];
			}foreach _items;

			_items = (_array select 7) select 0;
			_count = (_array select 7) select 1;
			{
				_vehicle addBackpackCargoGlobal [_x, _count select _foreachindex];
			}foreach _items;
			_vehicle;
		};

		PUBLIC FUNCTION("object","saveUnit") {
			private ["_DB", "_result", "_array"];
			_DB = format ["%1", getplayeruid _this];
			_array = [
				(headgear _this), 
				(goggles _this), 
				(uniform _this), 
				(UniformItems _this), 
				(vest _this), 
				(VestItems _this), 
				(backpack _this), 
				(backpackItems _this), 
				(primaryWeapon _this), 
				(primaryWeaponItems _this),
				(primaryWeaponMagazine _this),
				(secondaryWeapon _this),
				(secondaryWeaponItems _this),
				(secondaryWeaponMagazine _this),
				(handgunWeapon _this),
				(handgunItems _this),
				(handgunMagazine _this),
				(assignedItems _this),
				(getposatl _this),
				(damage _this),
				(getdir _this)
			];
			_result = [_DB, "player", "inventory", _array] call iniDB_write;
		};

		PUBLIC FUNCTION("object","loadUnit") {
			private ["_DB", "_array", "_headgear", "_goggles", "_uniform", "_uniformitems", "_vest", "_vestitems", "_backpack", "_backpackitems", "_primaryweapon", "_primaryweaponitems", "_primaryweaponmagazine", "_secondaryweapon", "_secondaryweaponitems", "_secondaryweaponmagazine", "_handgun", "_handgunweaponitems", "_handgunweaponmagazine", "_assigneditems", "_position", "_damage", "_dir"];

			_DB = format ["%1", getplayeruid _this];
			if!(_DB call iniDB_exists) exitwith {false;};

			MEMBER("ClearPlayer", _this);

			_array = [_DB, "player", "inventory","ARRAY"] call iniDB_read;
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
			_position = _array select 18;
			_damage = _array select 19;
			_dir = _array select 20;

			_this setposatl _position;
			_this setdamage _damage;
			_this setdir _dir;
			_this addHeadgear _headgear;
			_this forceAddUniform _uniform;
			_this addGoggles _goggles;
			_this addVest _vest;
			_this addweapon _primaryweapon;
			_this addweapon _secondaryweapon;
			_this addweapon _handgunweapon;

			{
				_this addItemToUniform _x;
			}foreach _uniformitems;
	
			{
				_this addItemToVest _x;
			}foreach _vestitems;
	
			if(format["%1", _backpack] != "") then {
				_this addbackpack _backpack;
				{
					_this addItemToBackpack _x;
				} foreach _backpackitems;
			};
	
			{
				_this addMagazine _x;
			} foreach _primaryweaponmagazine;

			{
				_this addPrimaryWeaponItem _x;
			} foreach _primaryweaponitems;
	
			{
				_this addMagazine _x;
			} foreach _secondaryweaponmagazine;
	
			{
				_this addSecondaryWeaponItem _x;
			} foreach _secondaryweaponitems;
	
	
			{
				_this addMagazine _x;
			} foreach _handgunweaponmagazine;
	
			{
				_this addHandgunItem _x;
			} foreach _handgunweaponitems;
	
			{
				_this additem _x;
				_this assignItem _x;
			} foreach _assigneditems;
			if (needReload _this == 1) then {reload _this};
			true;
		};

		PUBLIC FUNCTION("array","deconstructor") { };
	ENDCLASS;