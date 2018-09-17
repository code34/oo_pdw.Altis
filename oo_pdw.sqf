	/*
	Author: code34 nicolas_boiteux@yahoo.fr
	Copyright (C) 2014-2018 Nicolas BOITEUX

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
		PRIVATE VARIABLE("array","includingtypes");
		PRIVATE VARIABLE("array","excludingkindof");
		PRIVATE VARIABLE("array","includingkindof");
		PRIVATE VARIABLE("array","excludingobjects");
		PRIVATE VARIABLE("array","includingobjects");
		PRIVATE VARIABLE("string","savename");

		PUBLIC FUNCTION("string","constructor") { 
			DEBUG(#, "OO_PDW::constructor")
			private _drivername = toLower (param [0, "profile", [""]]);
			MEMBER("includingmarkers", []);
			MEMBER("excludingmarkers", []);
			MEMBER("aroundpos", []);
			MEMBER("excludingtypes", []);
			MEMBER("includingtypes", []);
			MEMBER("excludingkindof", []);
			MEMBER("includingkindof", []);
			MEMBER("excludingobjects", []);
			MEMBER("includingobjects", []);
			MEMBER("savename", "");

			switch (_drivername) do {
				case "inidbi": {
					if !(isClass(configFile >> "cfgPatches" >> "inidbi2")) exitwith { 
						MEMBER("ToLog", "PDW: requires INIDBI2");
					};
					_driver = ["new", "oo_pdw"] call OO_INIDBI;
					MEMBER("driver", _driver);
					MEMBER("drivername", "inidbi");
				};

				default {
					MEMBER("drivername", "profile");
				};
			}
		};

		PUBLIC FUNCTION("string","setSaveName") { MEMBER("savename", _this); };
		PUBLIC FUNCTION("","getSaveName") { MEMBER("savename", nil); };
		PUBLIC FUNCTION("array","setIncludingMarkers") { MEMBER("includingmarkers", _this); };
		PUBLIC FUNCTION("array","setExcludingMarkers") { MEMBER("excludingmarkers", _this); };
		PUBLIC FUNCTION("array","setAroundPos") { MEMBER("aroundpos", _this); };
		PUBLIC FUNCTION("array","setExcludingTypes") { MEMBER("excludingtypes", _this); };
		PUBLIC FUNCTION("array","setIncludingTypes") { MEMBER("includingtypes", _this); };
		PUBLIC FUNCTION("array","setExcludingKindOf") { MEMBER("excludingkindof", _this); };
		PUBLIC FUNCTION("array","setIncludingKindOf") { MEMBER("includingkindof", _this); };
		PUBLIC FUNCTION("array","setExcludingObjects") { MEMBER("excludingobjects", _this); };
		PUBLIC FUNCTION("array","setIncludingObjects") { MEMBER("includingobjects", _this); };

		PUBLIC FUNCTION("string","setDbName") {
			DEBUG(#, "OO_PDW::setDbName")
			["setDbName", _this] call MEMBER("driver", nil); 
		};

		PRIVATE FUNCTION("array","read") {
			DEBUG(#, "OO_PDW::read")
			private _key = param [0, "", [""]];
			if(_key isEqualTo "") exitwith { MEMBER("ToLog", "PDW: write failed - label not defined"); false;};
			_key = MEMBER("savename",nil) +_key;

			private _default = param[1, ""];
			private _result = false;
			private _drivername = MEMBER("drivername", nil);

			switch (_drivername) do {
				case "inidbi": { 	_result = ["read", ["pdw", _key, _default]] call MEMBER("driver", nil);	};
				case "profile": { _result = profileNamespace getVariable _key;};
				default { _result = false; };
			};
			_result;
		};

		PRIVATE FUNCTION("array","write") {
			DEBUG(#, "OO_PDW::write")
			private _key = param [0, "", [""]];
			if(_key isEqualTo "") exitwith { MEMBER("ToLog", "PDW: write failed - label not defined"); false;};
			_key = MEMBER("savename",nil) +_key;
			private _array = param [1, ""];
			private _drivername = MEMBER("drivername", nil);
			private _result = false;

			switch (_drivername) do {
				case "inidbi": { _result = ["write", ["pdw", _key, _array]] call MEMBER("driver", nil); };
				case "profile": {
					profileNamespace setVariable [_key, _array];
					saveProfileNamespace;
					_result = true;
				};
				default { _result = false; };
			};
			_result;
		};		

		PUBLIC FUNCTION("string","toLog") {
			DEBUG(#, "OO_PDW::toLog")
			hintc _this;
			diag_log _this;
		};

		PUBLIC FUNCTION("object","clearInventory") {
			DEBUG(#, "OO_PDW::clearInventory")
			removeallweapons _this;
			removeGoggles _this;
			removeHeadgear _this;
			removeVest _this;
			removeUniform _this;
			removeAllAssignedItems _this;
			removeBackpack _this;
		};

		PUBLIC FUNCTION("object","clearObject") {
			DEBUG(#, "OO_PDW::clearObject")
			clearWeaponCargoGlobal _this;
			clearMagazineCargoGlobal _this;
			clearItemCargoGlobal _this;
			clearBackpackCargoGlobal _this;
		};

		PUBLIC FUNCTION("","savePlayers") {
			DEBUG(#, "OO_PDW::savePlayers")
			{
				if(alive _x) then {
					["savePlayer", _x] call _pdw;
					["saveInventory", [name _x, _x]] call _pdw;
				};
				sleep 0.001;
			}foreach allplayers;
		};

		PUBLIC FUNCTION("","loadPlayers") {
			DEBUG(#, "OO_PDW::loadPlayers")
			{
				if(alive _x) then {
					["loadPlayer", _x] call _pdw;
					["loadInventory", [name _x, _x]] call _pdw;
				};
				sleep 0.001;
			}foreach allplayers;
		};		

		PUBLIC FUNCTION("","saveGroups") {
			DEBUG(#, "OO_PDW::saveGroups")
			private _counter = -1;
			private _counter2 = -1;
			private _name = "";
			private _data = [];
			private _save = [];

			{
				if(!isplayer(leader _x)) then {
					_counter = _counter + 1;
					_data  = [];
					{
						if(alive _x) then {
							_counter2 = _counter2 + 1;
							_name = str(_counter2);
							_data pushBack _name;
							["saveUnit", [_name, _x]] call _pdw;
							["saveInventory", [_name, _x]] call _pdw;
							sleep 0.001;
						};
					} foreach units _x;
					_save = [format ["pdw_groups_%1", _counter], [str(side _x), _data]];
					MEMBER("write", _save);
					sleep 0.001;
				};
			}foreach allGroups;
			_save = ["pdw_groups", _counter];
			MEMBER("write", _save);
		};

		PUBLIC FUNCTION("","loadGroups") {
			DEBUG(#, "OO_PDW::loadGroups")
			private _save = ["pdw_groups", -1];
			private _counter = MEMBER("read", _save);
			private	_objects = [];
			private _side = "";
			private _units = [];
			private _array = [];
			private _name = "";
			private _unit = "";
			private _group = "";
			private _param = [];


			for "_x" from 0 to _counter step 1 do {
				_name = [format ["pdw_groups_%1", _x], []];
				_array = MEMBER("read", _name);
				_side = _array select 0;
				_units = _array select 1;

				switch (_side) do {
					case "CIV" : { _group = creategroup civilian; };
 					case "GUER" : {	_group = creategroup resistance; };
					default { _group = call compile format ["creategroup %1;", _side]; };
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
				if(count (units _x) isEqualTo 0) then { deleteGroup _x; };
				sleep 0.001;
			}foreach allGroups;
		};

		/*
		Save all the object build in game excluding MAN & LOGIC 
		Parameters: none
		Return : true if sucess
		*/
		PUBLIC FUNCTION("","saveObjects") {
			DEBUG(#, "OO_PDW::saveObjects")
			private _excludingtypes = MEMBER("excludingtypes", nil);
			private _includingtypes = MEMBER("includingtypes", nil);
			private _excludingkindof = MEMBER("excludingkindof", nil);
			private _includingkindof = MEMBER("includingkindof", nil);
			private _excludingobjects = +MEMBER("excludingobjects", nil);
			private _includingobjects = +MEMBER("includingobjects", nil);
			private _excludingmarkers = MEMBER("excludingmarkers", nil);
			private _includingmarkers = MEMBER("includingmarkers", nil);
			private _aroundpos = MEMBER("aroundpos", nil);
			private _objects = allMissionObjects "All";
			private _object = objNull;
			private _exclude = false;
			private _include = false;
			private _position = [];
			private _save = "";
			private _hypo = 0;

			{	
				_object = _x;
				_exclude = false;
				_include = false;

				{ if (_object isKindOf _x) then { _exclude = true;}; true;} count _excludingkindof;
				{ if (_object isKindOf _x) then { _include = true;}; true;} count _includingkindof;
				if((typeOf _object) in _excludingtypes) then {_exclude = true;};
				if((typeOf _object) in _includingtypes) then {_include = true;};
				if((_object isKindOf "MAN") or (_object isKindOf "LOGIC")) then { _exclude = true;};
				if(isnil "_object") then { _exclude = true;};

				{
					_position = getMarkerPos _x;
					_distancex = (getMarkerSize _x) select 0;
					_distancey = (getMarkerSize _x) select 1;
					_hypo = sqrt ((_distancex ^ 2) + (_distancey ^ 2));
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

				if(_include) then { _includingobjects pushBack _object;};
				if(_exclude) then {_excludingobjects pushBack _object;};
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
			DEBUG(#, "OO_PDW::loadObjects")
			private _save = ["pdw_objects", 0];
			private _counter = MEMBER("read", _save);
			private _name = "";
			private _objects = [];

			for "_x" from 0 to _counter step 1 do {
				_name = format ["objects_%1", _x];
				_objects pushBack MEMBER("loadObject", _name);
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
			DEBUG(#, "OO_PDW::saveObject")
			private _label = param [0, "", [""]];
			private _object = param [1, ""];
			private _position = [];

			if (_label isEqualTo "") exitwith { MEMBER("ToLog", "PDW: require an object label to saveObject"); };
			if (_object isEqualTo "") exitwith { MEMBER("ToLog", "PDW: require an object to saveObject"); };
			_label = "pdw_object_" + _label;

			if (surfaceIsWater (getpos _object)) then { _position = (getposASL _object); } else { _position = (getposATL _object); };

			private _array = [
				(typeof _object),
				_position,
				(getdir _object),
				(getDammage _object),
				(getWeaponCargo _object),
				(getMagazineCargo _object),
				(getItemCargo _object),
				(getBackpackCargo _object),
				(simulationEnabled _object)
				];
			
			private _save = [_label, _array];
			MEMBER("write", _save);
		};

		PUBLIC FUNCTION("string","loadObject") {
			DEBUG(#, "OO_PDW::loadObject")
			private _name = _this;
			if (isnil "_name") exitwith { MEMBER("ToLog", "PDW: require a object name to loadObject"); };
			_name = "pdw_object_" + _name;

			private _save = [_name, []];
			_array = MEMBER("read", _save);
			if(_array isEqualTo []) exitWith {false;};

			private _object = createVehicle [(_array select 0), (_array select 1), [], 0, "NONE"];
			if (count _array > 8) then { _object enableSimulation (_array select 8);};

			if (surfaceIsWater (_array select 1)) then { _object setPosASL (_array select 1); } else { _object setPosATL (_array select 1); };
			_object setdir (_array select 2);
			_object setdamage (_array select 3);
			MEMBER("ClearObject", _object);

			private _items = (_array select 4) select 0;
			private _count = (_array select 4) select 1;
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
			DEBUG(#, "OO_PDW::savePlayer")
			private _object = _this;
			private _name = getPlayerUID _this;		
			if (isnil "_name") exitwith { MEMBER("ToLog", "PDW: require a unit name to savePlayer"); };
			_name = format["pdw_unit_%1", getPlayerUID _this];
			private _save = [_name, [(getpos _object), (getdir _object), (getdammage _object)]];
			MEMBER("write", _save);
		};

		PUBLIC FUNCTION("object","loadPlayer") {
			DEBUG(#, "OO_PDW::loadPlayer")
			private _name = getPlayerUID _this;
			if (isnil "_name") exitwith { MEMBER("ToLog", "PDW: require a unit name to loadPlayer"); };
			private _name = [format["pdw_unit_%1", getPlayerUID _this], []];
			private _array = MEMBER("read", _name);
			if(_array isEqualTo []) exitWith {false;};

			_this setpos (_array select 0);
			_this setdir (_array select 1);
			_this setdammage (_array select 2);
			true;
		};

		PUBLIC FUNCTION("array","saveUnit") {
			DEBUG(#, "OO_PDW::saveUnit")
			private _label = param [0, "", [""]];
			if (_label isEqualTo "") exitwith { MEMBER("ToLog", "PDW: require a unit label to saveUnit");};
			private _object = param [1, ""];
			if (_object isEqualTo "") exitwith { MEMBER("ToLog", "PDW: require a unit to saveUnit");};
			_label = "pdw_unit_" + _label;		
			private _save = [_label, [(typeof _object), (getpos _object), (getdir _object), (getdammage _object)]];
			MEMBER("write", _save);
		};

		PUBLIC FUNCTION("array","loadUnit") {
			DEBUG(#, "OO_PDW::loadUnit")
			private _label = param [0, "", [""]];
			if (_label isEqualTo "") exitwith { MEMBER("ToLog", "PDW: require a unit label to loadUnit");};
			private _group = param [1, ""];
			if (_group isEqualTo "") exitwith { MEMBER("ToLog", "PDW: require a unit group to loadUnit");};
			_label = "pdw_unit_" + _label;
			private _save = [_label, []];
			_array = MEMBER("read", _save);
			if(_array isEqualTo []) exitWith {false;};	
			private _unit = _group createUnit [(_array select 0), (_array select 1), [], 0, "NONE"];
			_unit setpos (_array select 1);
			_unit setdir (_array select 2);
			_unit setdammage (_array select 3);
			_unit;
		};

		PUBLIC FUNCTION("array","saveInventory") {
			DEBUG(#, "OO_PDW::saveInventory")
			private _label = param [0, "", [""]];
			private _object = param [1, ""];
			
			if (_label isEqualTo "") exitwith { MEMBER("ToLog", "PDW: require an unit label to saveUnit");};
			if (_object isEqualTo "") exitwith { MEMBER("ToLog", "PDW: require an unit ojbect to saveUnit");};

			_label = "pdw_inventory_" + _label;

			private _array = [
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

			private _save = [_label, _array];
			MEMBER("write", _save);
		};

		PUBLIC FUNCTION("array","loadInventory") {
			DEBUG(#, "OO_PDW::loadInventory")
			private _label = param [0, "", [""]];
			private _object = param [1, ""];
			
			if (_label isEqualTo "") exitwith { MEMBER("ToLog", "PDW: require a unit label to loadInventory");};
			if (_object isEqualTo "") exitwith { MEMBER("ToLog", "PDW: require a unit object to loadInventory");};

			_label = "pdw_inventory_" + _label;

			private _save = [_label, []];
			private _array = MEMBER("read", _save);
			if(_array isEqualTo []) exitWith {false;};

			MEMBER("ClearInventory", _object);

			private _headgear = _array select 0;
			private _goggles = _array select 1;
			private _uniform = _array select 2;
			private _uniformitems = _array select 3;
			private _vest = _array select 4;
			private _vestitems = _array select 5;
			private _backpack = _array select 6;
			private _backpackitems = _array select 7;
			private _fullmagazine = _array select 8;
			private _primaryweapon = _array select 9;
			private _primaryweaponitems = _array select 10;
			private _secondaryweapon = _array select 11;
			private _secondaryweaponitems = _array select 12;
			private _handgunweapon = _array select 13;
			private _handgunweaponitems = _array select 14;
			private _assigneditems = _array select 15;

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
				if!(_x isEqualTo "") then {
					_object addPrimaryWeaponItem _x;
				};
			} foreach _primaryweaponitems;

			_object addweapon _secondaryweapon;

			{
				if!(_x isEqualTo "") then {
					_object addSecondaryWeaponItem _x;
				};
			} foreach _secondaryweaponitems;

			_object addweapon _handgunweapon;

			{
				if!(_x isEqualTo "") then {
					_object addHandgunItem _x;
				};
			} foreach _handgunweaponitems;

			{
				if!(_x isEqualTo "") then {
					_object addweapon _x;
				};
			} foreach _assigneditems;

			if (needReload _object isEqualTo 1) then {reload _object};
			true;
		};

		PUBLIC FUNCTION("","deconstructor") { 
			DEBUG(#, "OO_PDW::deconstructor")
			DELETE_VARIABLE("drivername");
			DELETE_VARIABLE("driver");
			DELETE_VARIABLE("includingmarkers");
			DELETE_VARIABLE("excludingmarkers");
			DELETE_VARIABLE("aroundpos");
			DELETE_VARIABLE("excludingtypes");
			DELETE_VARIABLE("includingtypes");
			DELETE_VARIABLE("excludingkindof");
			DELETE_VARIABLE("includingkindof");
			DELETE_VARIABLE("excludingobjects");
			DELETE_VARIABLE("includingobjects");
		};
	ENDCLASS;