/*
 * Workbench OpenSCAD utility library
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


// Multitool: - the first thing you reach for to get the job done

// returns an empty list if lo > hi, unlike the native range notation
function range(lo, hi) = 
	lo > hi ?
		[]
	:
		[ for (i=[lo:hi]) i ];

// 'fold' the 'str' function across a list of strings
function restring(argv, sep="", i=0) = 
	len(argv) == 0 ?
		""
	: i == len(argv) - 1 ? 
		argv[i] 
	: 
		str(argv[i], sep, restring(argv, sep, i + 1));

// strip instances of the given character from the front of a string	
function stripL(argv, char) = _strip(argv, char, 0, range(1, len(argv)-1));

// strip instances of the given character from the end of a string			
function stripR(argv, char) = _strip(argv, char, len(argv)-1, range(0, len(argv)-2));

// underlying strip implementation	
function _strip(argv, char, testIndex, listRange) =
		len(argv) > 0 && argv[testIndex] == char ?
			_strip([ for (i=listRange) argv[i] ], char, testIndex, listRange)
		:
			restring(argv);

// extract a slice of an array, hi-inclusive.
function slice(arr, lo, hi) = 
	[ for (i=range(lo, hi)) arr[i] ];

// split a string into an array of strings per the given separator character	
function split(string, sep=" ") = 
	let (cleanStr = stripL(string, sep))
		len(cleanStr) == 0 || sep == "" ?
			[ for (i=range(0, len(string)-1)) string[i] ]
		:
			let(sepIndex = search(sep, cleanStr, 1)[0])
				sepIndex == undef ? 
					[restring(cleanStr)]
				:
					concat(restring(slice(cleanStr, 0, sepIndex-1)), split(slice(cleanStr, sepIndex+1, len(cleanStr)-1), sep));

// transpose a matrix
function transpose(mat) = 
	[ for (i = [0:len(mat[0])-1]) 
		[ for (j = [0:len(mat)-1]) 
			mat[j][i] ] ];

// create a vector of repeated elements
function vec(x, n = 3) = len(x) == undef ? [ for([1:n]) x ] : x;

// return a vector of specified length along given axis, 
// or the component of a specified vector along given axis
function x(arg = 1) = len(arg) == undef ? [arg, 0, 0] : arg[0];
function y(arg = 1) = len(arg) == undef ? [0, arg, 0] : arg[1];
function z(arg = 1) = len(arg) == undef ? [0, 0, arg] : arg[2];

// extrude geometry along a given vector
module stretch(dim = x(10)){

	hull()
		for(t = [vec(0), vec(dim)])
			translate(t)
				children();
}

// arrange child objects in an organized grid
module grid_array(max_per_line = 10, spacing = 50){

	for(n = [0:$children - 1])
		translate([(n % max_per_line) * spacing, floor(n / max_per_line) * spacing, 0])
			children(n);
}


