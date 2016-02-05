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
		PRIVATE VARIABLE("string","drivername");
		PRIVATE VARIABLE("code","driver");
		PRIVATE VARIABLE("array","includingmarkers");
		PRIVATE VARIABLE("array","excludingmarkers");
		PRIVATE VARIABLE("array","aroundpos");
		PRIVATE VARIABLE("array","excludingtypes");
		PRIVATE VARIABLE("array","excludingobjects");
		PRIVATE VARIABLE("array","includingobjects");

		PUBLIC FUNCTION("string","constructor") { 
			private ["_array", "_drivername"];

			_drivername = toLower (param [0, "profile", [""]]);

			_array = [];

			MEMBER("includingmarkers", _array);
			MEMBER("excludingmarkers", _array);
			MEMBER("aroundpos", _array);
			MEMBER("excludingtypes", _array);
			MEMBER("excludingobjects", _array);
			MEMBER("includingobjects", _array);

			if(_drivername == "inidbi") then {
				if !(isClass(configFile >> "cfgPatches" >> "inidbi2")) exitwith { 
					MEMBER("ToLog", "PDW: requires INIDBI2");
				};
				_driver = ["new", "oo_pdw"] call OO_INIDBI;
				MEMBER("driver", _driver);
			};
			MEMBER("drivername", _drivername);
		};

		PUBLIC FUNCTION("string","setDbName") {
			["setDbName", _this] call MEMBER("driver", nil);
		};

		PUBLIC FUNCTION("array","setIncludingMarkers") {
			MEMBER("includingmarkers", _this);
		};

		PUBLIC FUNCTION("array","setExcludingMarkers") {
			MEMBER("excludingmarkers", _this);
		};

		PUBLIC FUNCTION("array","setAroundPos") {
			MEMBER("aroundpos", _this);
		};

		PUBLIC FUNCTION("array","setExcludingTypes") {
			MEMBER("excludingtypes", _this);
		};

		PUBLIC FUNCTION("array","setExcludingObjects") {
			MEMBER("excludingobjects", _this);
		};

		PUBLIC FUNCTION("array","setIncludingObjects") {
			MEMBER("includingobjects", _this);
		};

		PRIVATE FUNCTION("array","read") {
			private ["_drivername", "_key", "_result", "_default"];
			
			_key = param [0, "", [""]];
			_default = param[1, ""];

			if(_key isEqualTo "") exitwith { MEMBER("ToLog", "PDW: write failed - label not defined"); false;};

			_drivername = MEMBER("drivername", nil);

			switch (_drivername) do {
				case "inidbi": {
					_result = ["read", ["pdw", _key, _default]] call MEMBER("driver", nil);
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
			private ["_drivername", "_key", "_array", "_result"];
			
			_key = param [0, "", [""]];
			_array = param [1, ""];

			if(_key isEqualTo "") exitwith { MEMBER("ToLog", "PDW: write failed - label not defined"); false;};

			_drivername = MEMBER("drivername", nil);

			_result = ["write", ["pdw", _key, _array]] call MEMBER("driver", nil);

			switch (_drivername) do {
				case "inidbi": {
					_result = ["write", ["pdw", _key, _array]] call MEMBER("driver", nil);
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

		PUBLIC FUNCTION("","savePlayers") {
			{
				if(alive _x) then {
					["savePlayer", _x] call _pdw;
					["saveInventory", [name _x, _x]] call _pdw;
				};
				sleep 0.001;
			}foreach allplayers;
		};

		PUBLIC FUNCTION("","loadPlayers") {
			{
				if(alive _x) then {
					["loadPlayer", _x] call _pdw;
					["loadInventory", [name _x, _x]] call _pdw;
				};
				sleep 0.001;
			}foreach allplayers;
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
					_save = [format ["pdw_groups_%1", _counter], _data];
					MEMBER("write", _save);
					sleep 0.001;
				};
			}foreach allGroups;
			_save = ["pdw_groups", _counter];
			MEMBER("write", _save);
		};

		PUBLIC FUNCTION("","loadGroups") {
			private ["_array", "_name", "_counter", "_group", "_units", "_unit", "_param", "_side"];
			
			_save = ["pdw_groups", -1];
			_counter = MEMBER("read", _save);

			_objects = [];
			for "_x" from 0 to _counter step 1 do {
				_name = [format ["pdw_groups_%1", _x], []];
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
					_param = [_x, _group];
					_unit = MEMBER("loadUnit", _param);
					[_unit] joinSilent _group;
					_param = [_x, _unit];
					MEMBER("loadInventory", _param);
					sleep 0.001;
				}foreach _units;
				sleep 0.001;
			};

			{
				if(count (units _x) == 0) then { deleteGroup _x; };
				sleep 0.001;
			}foreach allGroups;
		};

		/*
		Save all the object build in game excluding MAN & LOGIC 
		Parameters: none
		Return : true if sucess
		*/
		PUBLIC FUNCTION("","saveObjects") {
			private ["_excludingtypes", "_excludingobjects", "_excludingmarkers", "_includingmarkers", "_objects", "_aroundpos", "_object", "_save", "_hypo", "_position", "_includingobjects", "_include", "_exclude"];
			
			_excludingtypes = MEMBER("excludingtypes", nil);
			_excludingobjects = MEMBER("excludingobjects", nil);
			_includingobjects = MEMBER("includingobjects", nil);
			_excludingmarkers = MEMBER("excludingmarkers", nil);
			_includingmarkers = MEMBER("includingmarkers", nil);
			_aroundpos = MEMBER("aroundpos", nil);
			
			_objects = allMissionObjects "All";
			{	
				_object = _x;
				_exclude = false;
				_include = false;

				if((typeOf _object) in _excludingtypes) then {_exclude = true;};
				if((_object isKindOf "MAN") or (_object isKindOf "LOGIC"))  then { _exclude = true;};
				if(isnil "_object") then { _exclude = true;};

				{
					_position = getMarkerPos  _x;
					_distancex = (getMarkerSize _x) select 0;
					_distancey = (getMarkerSize _x) select 1;
					_hypo =  sqrt ((_distancex ^ 2) + (_distancey ^ 2));
					if(_object distance _position < _hypo) then { _exclude = true;};
					sleep 0.0001;
				}foreach _excludingmarkers;

				{
					_position = getMarkerPos  _x;
					_distancex = (getMarkerSize _x) select 0;
					_distancey = (getMarkerSize _x) select 1;
					_hypo =  sqrt ((_distancex ^ 2) + (_distancey ^ 2));
					if(_object distance _position < _hypo) then { _include = true;};
					sleep 0.0001;
				}foreach _includingmarkers;

				{
					_position = _x select 0;
					_maxdistance = _x select 1;
				 	if(_object distance _position < _maxdistance) then { _include = true;};
					sleep 0.0001;
				}foreach _aroundpos;

				if(_include) then { _includingobjects = _includingobjects + [_object];};
				if(_exclude) then {_excludingobjects = _excludingobjects + [_object];};
			}foreach _objects;

			if(count _includingobjects > 0) then {
				_objects = _includingobjects - _excludingobjects;
			} else {
				_objects = _objects - _excludingobjects;
			};

			{
				_save = [format ["objects_%1", _forEachIndex], _x];
				MEMBER("saveObject", _save);
				sleep 0.0001;
			}foreach _objects;

			_save = ["pdw_objects", (count _objects) - 1];
			MEMBER("write", _save);
		};


		/*
		Restore all objects
		Parameters:  none
		Return : array of objects
		*/
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

		/*
		Save an object
		Parameters:  
			_this select 0 : _label : label of the save
			_this select 1 : _object : object to save
		Return : true if sucess
		*/
		PUBLIC FUNCTION("array","saveObject") {
			private ["_array", "_label", "_object"];
			
			_label = param [0, "", [""]];
			_object = param [1, ""];
			
			if (_label isEqualTo "") exitwith { MEMBER("ToLog", "PDW: require an object label to saveObject"); };
			if (_object isEqualTo "") exitwith { MEMBER("ToLog", "PDW: require an object to saveObject"); };


			_label = "pdw_object_" + _label;

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
			
			_save = [_label, _array];
			MEMBER("write", _save);
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

			if(_array isequalto []) exitwith {false};

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
				_object addMagazineCargoGlobal [_x, _count select _foreachindex];
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
				MEMBER("ToLog", "PDW: require a unit name to loadPlayer");
			};

			_name = format["pdw_unit_%1", getPlayerUID _this];		

			_save = [_name, []];
			_array = MEMBER("read", _save);
			if(_array isequalto []) exitwith {false;};	

			_position	= _array select 0;
			_dir		= _array select 1;
			_damage 	= _array select 2;

			_this setpos _position;
			_this setdir _dir;
			_this setdammage _damage;
			true;
		};

		PUBLIC FUNCTION("array","saveUnit") {
			private ["_label", "_object", "_result", "_array"];

			_label = param [0, "", [""]];
			_object = param [1, ""];

			if (_label isEqualTo "") exitwith { MEMBER("ToLog", "PDW: require a unit label to saveUnit");};
			if (_object isEqualTo "") exitwith { MEMBER("ToLog", "PDW: require a unit to saveUnit");};

			_label = "pdw_unit_" + _label;

			_array = [(typeof _object), (getpos _object), (getdir _object), (getdammage _object)];
			
			_save = [_label, _array];
			MEMBER("write", _save);
		};

		PUBLIC FUNCTION("array","loadUnit") {
			private ["_label", "_array", "_position", "_damage", "_dir", "_typeof", "_unit", "_group"];

			_label = param [0, "", [""]];
			_group = param [1, ""];

			if (_label isEqualTo "") exitwith { MEMBER("ToLog", "PDW: require a unit label to loadUnit");};
			if (_group isEqualTo "") exitwith { MEMBER("ToLog", "PDW: require a unit group to loadUnit");};				

			_label = "pdw_unit_" + _label;

			_save = [_label, []];
			_array = MEMBER("read", _save);
			if(_array isequalto []) exitwith {false};	

			_typeof 	= _array select 0;
			_position	= _array select 1;
			_dir		= _array select 2;
			_damage 	= _array select 3;

			_unit = _group createUnit [_typeof, _position, [], 0, "NONE"];
			_unit setpos _position;
			_unit setdir _dir;
			_unit setdammage _damage;
			_unit;
		};

		PUBLIC FUNCTION("array","saveInventory") {
			private ["_label", "_object", "_result", "_array"];

			_label = param [0, "", [""]];
			_object = param [1, ""];
			
			if (_label isEqualTo "") exitwith { MEMBER("ToLog", "PDW: require an unit label to saveUnit");};
			if (_object isEqualTo "") exitwith { MEMBER("ToLog", "PDW: require an unit ojbect to saveUnit");};				

			_label = "pdw_inventory_" + _label;			

			_array = [
				(headgear _object), 
				(goggles _object), 
				(uniform _object), 
				(UniformItems _object), 
				(vest _object), 
				(VestItems _object), 
				(backpack _object), 
				(backpackItems _object), 
				(magazinesAmmoFull _object),
				(primaryWeapon _object), 
				(primaryWeaponItems _object),
				(secondaryWeapon _object),
				(secondaryWeaponItems _object),
				(handgunWeapon _object),
				(handgunItems _object),
				(assignedItems _object)
			];

			_save = [_label, _array];
			MEMBER("write", _save);
		};

		PUBLIC FUNCTION("array","loadInventory") {
			private ["_label", "_array", "_headgear", "_goggles", "_uniform", "_uniformitems", "_vest", "_vestitems", "_backpack", "_backpackitems", "_primaryweapon", "_primaryweaponitems", "_fullmagazine", "_secondaryweapon", "_secondaryweaponitems", "_handgun", "_handgunweaponitems", "_assigneditems", "_position", "_damage", "_dir", "_object"];

			_label = param [0, "", [""]];
			_object = param [1, ""];
			
			if (_label isEqualTo "") exitwith { MEMBER("ToLog", "PDW: require a unit label to loadInventory");};
			if (_object isEqualTo "") exitwith { MEMBER("ToLog", "PDW: require a unit object to loadInventory");};

			_label = "pdw_inventory_" + _label;			

			_save = [_label, []];
			_array = MEMBER("read", _save);
			if(_array isequalto []) exitwith {false};

			MEMBER("ClearInventory", _object);

			_headgear = _array select 0;
			_goggles = _array select 1;
			_uniform = _array select 2;
			_uniformitems = _array select 3;
			_vest = _array select 4;
			_vestitems = _array select 5;
			_backpack = _array select 6;
			_backpackitems = _array select 7;
			_fullmagazine = _array select 8;
			_primaryweapon = _array select 9;
			_primaryweaponitems = _array select 10;
			_secondaryweapon = _array select 11;
			_secondaryweaponitems = _array select 12;
			_handgunweapon = _array select 13;
			_handgunweaponitems = _array select 14;
			_assigneditems = _array select 15;

			_object addHeadgear _headgear;
			_object forceAddUniform _uniform;
			_object addGoggles _goggles;
			_object addVest _vest;

			{
				if(!(_x isEqualTo "") and (_x isKindOf ["ItemCore", configFile >> "CfgWeapons"] )) then {
					_object addItemToUniform _x;
				};
			}foreach _uniformitems;
	
			{
				if(!(_x isEqualTo "") and (_x isKindOf ["ItemCore", configFile >> "CfgWeapons"] )) then {
					_object addItemToVest _x;
				};
			}foreach _vestitems;
	
			if!(_backpack isEqualTo "") then {
				_object addbackpack _backpack;
				{
					if(!(_x isEqualTo "") and (_x isKindOf ["ItemCore", configFile >> "CfgWeapons"] )) then {
						_object addItemToBackpack _x;
					};
				} foreach _backpackitems;
			};
	
			{
				if!(_x isEqualTo "") then {
					_object addMagazine [_x select 0, _x select 1];
				};
			} foreach _fullmagazine;

			//must be after assign items to secure loading mags
			_object addweapon _primaryweapon;
	
			{
				if(_x != "") then {
					_object addPrimaryWeaponItem _x;
				};
			} foreach _primaryweaponitems;

			_object addweapon _secondaryweapon;
	
			{
				if(_x != "") then {
					_object addSecondaryWeaponItem _x;
				};
			} foreach _secondaryweaponitems;
	

			_object addweapon _handgunweapon;
	
			{
				if(_x != "") then {
					_object addHandgunItem _x;
				};
			} foreach _handgunweaponitems;
	
			{
				if(_x != "") then {
					_object addweapon _x;
				};
			} foreach _assigneditems;

			if (needReload _object == 1) then {reload _object};
			true;
		};

		PUBLIC FUNCTION("","deconstructor") { 
			DELETE_VARIABLE("drivername");
			DELETE_VARIABLE("driver");
			DELETE_VARIABLE("includingmarkers");
			DELETE_VARIABLE("excludingmarkers");
			DELETE_VARIABLE("aroundpos");
			DELETE_VARIABLE("excludingtypes");
			DELETE_VARIABLE("excludingobjects");
			DELETE_VARIABLE("includingobjects");
		};
	ENDCLASS;