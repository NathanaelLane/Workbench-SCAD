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

/*
 * [template] create a Template structure
 * 
 * - keystring: [string] a comma-separated list of keys
 */
function Template(keystring) = 
	concat("&", [ let (s = split(keystring, ",")) [ for (i=range(0, len(s)-1)) stripR(stripL(s[i], " "), " ") ] ]);
	
/* 
 * [object] create an Object structure
 * 
 * - template: [template] 
 * - values: [array] populate the template fields
 * - prototypes: [array[object]] define inheritance chains. 
 *     If a key is not found in an object's own list of properties,
 *     all of its prototypes are searched recursively for a value corresponding to the given key.
 */
function Obj(template, values, prototypes=[]) = 
	concat("$", [prototypes], [template[1]], [values]);

/* 
 * access a named field from an object, including from within the prototype heirarchy, 
 * recursively using key heirarchy strings. If the object does not contain a value for the given key, 
 * behavior is undefined. 
 * 
 * - obj: [object] the object to search
 * - keys: [string] a string representing a sequential set of keys separated by the "." character,
 *     e.g. "param.subparam.value." The value of the first (leftmost) key will be treated as an object,
 *     within which the next key is queried, and so forth until the value corresponding to the final key is returned.
 */
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

/*
 * [echo] print a structure to the console (including all fields and prototypes in full)
 * 
 * - structure: [object],[template]
 */
module debugStruct(structure, _indent = "") {
	lead = str("> ", _indent);
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
				debugStruct(structure[1][i], str(_indent, tab));
			}
			for(i = range(0, len(structure[2])-1)) {
				echo(str(lead, tab, tab, structure[2][i], ": "));
				debugStruct(structure[3][i], str(_indent, tab, tab, tab));
			}
		} else {
			echo(str(lead, structure));
		}
	}	
}

/* 
 * [object] helper function for creating many different object types with the same Template
 * 
 * - template: [template] used by all child objects
 * - kvp: [array[string, array]] an array of key-value pairs, where the "key"
 *     will be included in the returned "collection" object's template, while the "value" is 
 *     an array of values which match the "template" parameter and will be used to create the
 * 		 child object corresponding to the given key
 * - prototypes: [array[object]] used by all child objects
 */
function Collection(template, kvp, prototypes=[]) = 
	let (ordered = transpose(kvp))
		let (objs = [ for (o=ordered[1]) Obj(template, o, prototypes) ])
			Obj(Template(restring(ordered[0], sep=",")), objs);

// test code

threadT = Template("nominal_d, pilot_d, pitch");
screwT = Template("length");
socketHeadT = Template("head_h, head_d, socket_d");
stepperT = Template("screw_size, screw_spacing, screw_depth, w, boss_d, boss_h, model");
extrusionT = Template("side_w, slot_w, lip_h, t_w, t_depth, corner_r, end_tap");

m3_thread = Obj(threadT, [3, 2.5, 0.5]);

m3_socket_cap = Obj(socketHeadT, [2.4, 5.5, 2.5], [m3_thread]);

m3_scs = Obj(screwT, [25], [m3_socket_cap]);
echo(v(m3_scs, "pilot_d"));
debugStruct(m3_scs);

k = [["a", [1]], ["b", [2]]];
debugStruct(Collection(Template("num"), k, [m3_scs]));










