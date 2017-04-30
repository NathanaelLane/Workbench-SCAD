/*
 * WWorkbench OpenSCAD utility library
 * Copyright (C) 2017 NathanaelLane
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */



// Partsbin: - keep your data organized

use <workbench/multitool.scad>

// create a Type structure
function Template(keystring) = 
	concat("&", [ let (s = split(keystring, ",")) [ for (i=range(0, len(s)-1)) stripR(stripL(s[i], " "), " ") ] ]);
	
// create an Object structure
function Obj(prototypes=[], type, values) = 
	concat("$", [prototypes], [type[1]], [values]);

// access a named field from an object, 
// including from within the prototype heirarchy, 
// recursively using key heirarchy strings
function v(obj, keys) = _v(obj, split(keys, "."));

// use key heirarchy arrays internally
function _v(obj, keys, i=0) = 
	let(val = _singleV(obj, keys[i]))
		len(keys)-1 == i ?
			val
		:
			_v(val, keys, i+1);	

// access a named field from an object, including from within the prototype heirarchy, without searching for sub-fields
function _singleV(obj, key) = 
	let (val = _localV(obj, key))
		val == undef ?
			_protoV(obj, key)
		:
			val;

// access a named field directly owned by an object		
function _localV(obj, key) = 
	[ for (i=range(0, len(obj[2])-1)) 
		if (obj[2][i] == key) 
			obj[3][i] 
	][0];

// access a named field owned by any of an object's prototypes
function _protoV(obj, key) = 
	[ for (i=range(0, len(obj[1])-1)) 
		let (val = _singleV(obj[1][i], key)) 
			if (val != undef) 
				val
	][0];

// print a structure to the console (including all fields and prototypes in full)
module debugStruct(structure, indent = "") {
	lead = str("> ", indent);
	tab = "    ";
	if(structure[0] == "&") {
		echo(str(lead, "Template structure"));
		for(i = range(0, len(structure[1])-1)) {
			echo(str(lead, tab, "Key: ", structure[1][i]));
		}
	} else {
		if (structure[0] == "$") {
			echo(str(lead, "Object structure"));
			for(i = range(0, len(structure[1])-1)) {
				debugStruct(structure[1][i], str(indent, tab));
			}
			for(i = range(0, len(structure[2])-1)) {
				echo(str(lead, tab, tab, structure[2][i], ": "));
				debugStruct(structure[3][i], str(indent, tab, tab, tab));
			}
		} else {
			echo(str(lead, structure));
		}
	}	
}

// test code

threadT = Template("nominal_d, pilot_d, pitch");
screwT = Template("length");
socketHeadT = Template("head_h, head_d, socket_d");
stepperT = Template("screw_size, screw_spacing, screw_depth, w, boss_d, boss_h, model");
extrusionT = Template("side_w, slot_w, lip_h, t_w, t_depth, corner_r, end_tap");

m3_thread = Obj([], threadT, [3, 2.5, 0.5]);

m3_socket_cap = Obj([m3_thread], socketHeadT, [2.4, 5.5, 2.5]);

m3_scs = Obj([m3_socket_cap], screwT, [25]);
echo(v(m3_scs, "thread_minor"));
debugStruct(m3_scs);










