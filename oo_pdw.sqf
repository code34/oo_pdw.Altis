	/*
	Author: code34 nicolas_boiteux@yahoo.fr
	Copyright (C) 2013 Nicolas BOITEUX

	OO_PDW Persistent Data World
	
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
				hint "PDW: requires INIDBI"; 
				diag_log "PDW: requires INIDBI";
			};
			[] call compilefinal preProcessFile "\inidbi\init.sqf";
		};	

		PUBLIC FUNCTION("object","RemoveAll") {
			removeallweapons _this;
			removeGoggles _this;
			removeHeadgear _this;
			removeVest _this;
			removeUniform _this;
			removeAllAssignedItems _this;
			removeBackpack _this;
		};

		PUBLIC FUNCTION("object","SaveVehicle") {
			private ["_DB", "_result"];
			_DB = format ["%1", getplayeruid _this];
			_result = [_DB, "vehicle", "dir", getdir _this] call iniDB_write;
			_result = [_DB, "vehicle", "position", getposatl _this] call iniDB_write;
			_result = [_DB, "vehicle", "damage", damage _this] call iniDB_write;
			_result = [_DB, "vehicle", "typeof", typeof _this] call iniDB_write;			
		};

		PUBLIC FUNCTION("object","LoadVehicle") {
			private ["_DB", "_result"];
		};

		PUBLIC FUNCTION("object","SavePlayer") {
			private ["_DB", "_result"];
			_DB = format ["%1", getplayeruid _this];
			_result = [_DB, "inventory", "HEADGEAR", (headgear _this)] call iniDB_write;
			_result = [_DB, "inventory", "GOGGLES", (goggles _this)] call iniDB_write;
			_result = [_DB, "inventory", "UNIFORM", (uniform _this)] call iniDB_write;
			_result = [_DB, "inventory", "UNIFORMITEMS", (UniformItems _this)] call iniDB_write;
			_result = [_DB, "inventory", "VEST", (vest _this)] call iniDB_write;
			_result = [_DB, "inventory", "VESTITEMS", (VestItems _this)] call iniDB_write;
			_result = [_DB, "inventory", "BACKPACK",  (backpack _this)] call iniDB_write;
			_result = [_DB, "inventory", "BACKPACKITEMS", (backpackItems _this)] call iniDB_write;
			_result = [_DB, "inventory", "WEAPON", (primaryWeapon _this)] call iniDB_write;
			_result = [_DB, "inventory", "WEAPONMAGAZINES", (primaryWeaponMagazine _this)] call iniDB_write;
			_result = [_DB, "inventory", "WEAPONITEMS", (primaryWeaponItems _this)] call iniDB_write;
			_result = [_DB, "inventory", "SECONDARYWEAPON", (secondaryWeapon _this)] call iniDB_write;
			_result = [_DB, "inventory", "SECONDARYWEAPONITEMS", (secondaryWeaponItems _this)] call iniDB_write;
			_result = [_DB, "inventory", "SECONDARYWEAPONMAGAZINES", (secondaryWeaponMagazine _this)] call iniDB_write;
			_result = [_DB, "inventory", "HANDGUNWEAPON", (handgunWeapon _this)] call iniDB_write;
			_result = [_DB, "inventory", "HANDGUNWEAPONITEMS", (handgunItems _this)] call iniDB_write;
			_result = [_DB, "inventory", "HANDGUNWEAPONMAGAZINES", (handgunMagazine _this)] call iniDB_write;
			_result = [_DB, "inventory", "ITEMS", (assignedItems _this)] call iniDB_write;
			_result = [_DB, "inventory", "position", getposatl _this] call iniDB_write;
			_result = [_DB, "inventory", "damage", damage _this] call iniDB_write;
			_result = [_DB, "inventory", "dir", getdir _this] call iniDB_write;
		};

		PUBLIC FUNCTION("object","LoadPlayer") {
			private ["_temp", "_DB"];
			_DB = format ["%1", getplayeruid _this];
			if!(_DB call iniDB_exists) exitwith {false;};

			MEMBER("RemoveAll", _this);

			_temp = [_DB, "inventory", "position","ARRAY"] call iniDB_read;
			_this setposatl _temp;
	
			_temp = [_DB, "inventory", "damage","SCALAR"] call iniDB_read;
			_this setdamage _temp;
	
			_temp = [_DB, "inventory", "HEADGEAR","STRING"] call iniDB_read;
			_this addHeadgear _temp;
	
			_temp = [_DB, "inventory", "UNIFORM","STRING"] call iniDB_read;
			_this addUniform _temp;
	
			_temp = [_DB, "inventory", "UNIFORMITEMS","ARRAY"] call iniDB_read;
			{
				_this additem _x;
			}foreach _temp;
	
			_temp = [_DB, "inventory", "GOGGLES","STRING"] call iniDB_read;
			_this addGoggles _temp;
	
			_temp = [_DB, "inventory", "VEST","STRING"] call iniDB_read;
			_this addVest _temp;
	
			_temp = [_DB, "inventory", "VESTITEMS","ARRAY"] call iniDB_read;
			{
				_this addItemToVest _x;
			}foreach _temp;
	
			_temp = [_DB, "inventory", "BACKPACK","STRING"] call iniDB_read;
			if(format["%1", _temp] != "") then {
				_this addbackpack _temp;
				_temp = [_DB, "inventory", "BACKPACKITEMS","ARRAY"] call iniDB_read;
				{
					_this addItemToBackpack _x;
				} foreach _temp;
			};
	
			_temp = [_DB, "inventory", "WEAPON","STRING"] call iniDB_read;
			_this addweapon _temp;
	
			_temp = [_DB, "inventory", "WEAPONMAGAZINES","ARRAY"] call iniDB_read;
			{
				_this addMagazine _x;
			} foreach _temp;
	
			_temp = [_DB, "inventory", "WEAPONITEMS","ARRAY"] call iniDB_read;
			{
				_this addPrimaryWeaponItem _x;
			} foreach _temp;
	
	
			_temp = [_DB, "inventory", "SECONDARYWEAPON","STRING"] call iniDB_read;
			_this addweapon _temp;
	
			_temp = [_DB, "inventory", "SECONDARYWEAPONMAGAZINES","ARRAY"] call iniDB_read;
			{
				_this addMagazine _x;
			} foreach _temp;
	
			_temp = [_DB, "inventory", "SECONDARYWEAPONITEMS","ARRAY"] call iniDB_read;
			{
				_this addSecondaryWeaponItem _x;
			} foreach _temp;
	
			_temp = [_DB, "inventory", "HANDGUNWEAPON","STRING"] call iniDB_read;
			_this addweapon _temp;
	
			_temp = [_DB, "inventory", "HANDGUNWEAPONMAGAZINES","ARRAY"] call iniDB_read;
			{
				_this addMagazine _x;
			} foreach _temp;
	
			_temp = [_DB, "inventory", "HANDGUNWEAPONITEMS","ARRAY"] call iniDB_read;
			{
				_this addHandgunItem _x;
			} foreach _temp;
	
			
			_temp = [_DB, "inventory", "ITEMS","ARRAY"] call iniDB_read;
			{
				_this additem _x;
				_this assignItem _x;
			} foreach _temp;
			true;
		};

		PUBLIC FUNCTION("array","deconstructor") { };
	ENDCLASS;