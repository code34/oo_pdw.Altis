	/*
	Author: code34 nicolas_boiteux@yahoo.fr
	Copyright (C) 2013-2016 Nicolas BOITEUX

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

	Create a main bus message between clients & server
	
	Usage:
		put the "oo_pdw.sqf" and the "oop.h" files in your mission directory
		put this code into your mission init.sqf
		call compilefinal preprocessFileLineNumbers "oo_pdw.sqf";

	See example mission in directory: init.sqf
	
	Licence: 
	You can share, modify, distribute this script but don't remove the licence and the name of the original author

	logs:
		0.76
			- Add setIncludingMarkers method
			- Add setExcludingMarkers method
			- Add setAroundPos method
			- Add setExcludingTypes method
			- Add setExcludingObjects method
			- Add setIncludingObjects method
			- Delete saveObjectsAroundPos method
			- Delete saveObjectsInMarkers method
			- Delete saveObjectsOutOfMarkers method
			- Delete saveObjectsExcludingObjects method
			- Delete saveObjectsExcludingTypes
			- Control type methods parameters

		0.74	
			- fix magazines count for infantry
			- turn off gps add
			- fix binocular not assigned
			- Add saveObjectsAroundPos method
			- Add saveObjectsInMarkers method
			- Add saveObjectsOutOfMarkers method
			- Add saveObjectsExcludingObjects method
			- Add saveObjectsExcludingTypes
		0.72	- fix return values of methods
			- add savePlayers/loadPlayers methods
			- add saveGroups/loadGroups methods
			- fix initServer.sqf example for MP servers
			- update documentation
		0.7	- add support inidbi2 DB
			- refactory setFileName to setDbName
			- only compatible with inidbi2
			- fix saveObjects method
		0.6	- add  setFileName for inidbi DB
			- fix save file with inidbi
			- use UID instead of name of players
		0.5	- add drivers support
			- add profilename support
			- add loadPlayer & savePlayer methods
			- fix loadInventory method
		0.4	- re factory saveUnit, loadUnit, saveObject, loadObject
			- add saveObjects, loadObjects
			- add saveInventory, loadInventory, clearInventory
			- add more doc
		0.3 	- fix function name
			- fix reload weapon
			- fix example code
		0.2 	- Fix typo error, fix adduniform
		0.1 	- OO PDW - first release


