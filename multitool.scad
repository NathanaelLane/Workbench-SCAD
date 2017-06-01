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

/* 
 * [array[number]] return an array representing an ordered progression of numbers-- 
 * or an empty array if lo > hi, unlike the native range notation
 * 
 * - lo: [number] range start
 * - hi: [number] range end (inclusive)
 * - step: [number] increment. Default is 1
 */
function range(lo, hi, step=1) = 
	lo > hi ?
		[]
	:
		[ for (i=[lo:step:hi]) i ];

	
/* 
 * [string] 'fold' the 'str' function across a list of strings
 * 
 * - argv: [array[string]]
 * - sep: [string] a sequence to place between arguments when combining.
 *     Default is ""
 */
function restring(argv, sep="", _i=0) = 
	len(argv) == 0 ?
		""
	: _i == len(argv) - 1 ? 
		argv[_i] 
	: 
		str(argv[_i], sep, restring(argv, sep, _i + 1));


/*
 * [array] extract a slice of an array, hi-inclusive.
 * 
 * - arr: [array]
 * - lo: [integer] lowest index to include. Clamped to 0
 * - hi: [integer] highest index to include. Clamped to len(arr) - 1
 */
function slice(arr, lo, hi) = 
	[ for (i=range(max(0, lo), min(hi, len(arr)-1))) arr[i] ];
	

/* 
 * [string] strip instances of the given character from the front of a string
 * 
 * - argv: [string]
 * - char: [character]
 */
function stripL(argv, char) = _strip(argv, char, 1, 0);


/*
 * [string] strip instances of the given character from the end of a string
 * 
 * - argv: [string]
 * - char: [character]
 */			
function stripR(argv, char) = _strip(argv, char, 0, 1);


// underlying strip implementation	
function _strip(argv, char, lo_inc, hi_inc) =
	let (l = len(argv))
		l > 0 && argv[hi_inc*(l-1)] == char ?
			_strip([ for (i=[lo_inc:l-1-hi_inc]) argv[i] ], char, lo_inc, hi_inc)
		:
			restring(argv);
			

/* 
 * [array[string]] split a string into an array of strings per the given separator character
 * 
 * - string: [string]
 * - sep: [character] default is " "
 */
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

/* 
 * [array[array]] transpose a matrix
 * 
 * - mat: [array[array]]
 */
function transpose(mat) = 
	[ for (i = [0:len(mat[0])-1]) 
		[ for (j = [0:len(mat)-1]) 
			mat[j][i] ] ];

/* 
 * [array] create a vector of repeated elements
 * 
 * - x: [number] value to repeat
 * - n: [integer] desired number of elements. Default is 3
 */
function vec(x, n = 3) = len(x) == undef ? [ for([1:n]) x ] : x;

/* 
 * [array], [number] return a vector of specified length along given axis, 
 * or the component of a specified vector along given axis
 * 
 * - arg: [number] returns [array] of length <arg> parallel to given axis. Default is 1
 * - arg: [array] returns [number] of component along given axis
 */
function x(arg = 1) = len(arg) == undef ? [arg, 0, 0] : arg[0];
function y(arg = 1) = len(arg) == undef ? [0, arg, 0] : arg[1];
function z(arg = 1) = len(arg) == undef ? [0, 0, arg] : arg[2];

/* 
 * [2D], [3D] extrude geometry along a given vector
 * 
 * - dim: [array] default is [1, 0, 0]
 */
module stretch(dim = x(10)){

	hull()
		for(t = [vec(0), vec(dim)])
			translate(t)
				children();
}

/* 
 * [2D], [3D] arrange child objects in an organized grid
 * 
 * - max_per_line: [integer] number of child elements to display 
 *     per row/column/line before wrapping the grid. Default is 10
 * - spacing: [number] distance between objects when placing child elements.
 *     Default is 50
 */
module grid_array(max_per_line = 10, spacing = 50){

	for(n = [0:$children - 1])
		translate([(n % max_per_line) * spacing, floor(n / max_per_line) * spacing, 0])
			children(n);
}

// test code
$fs = 0.05;
$fa = 5;

echo(range(10, 1));
echo(range(10, 1, -2.5));
echo(range(1, 10));
echo(range(1, 10, 3.5));
echo(range(1, 10, 11));

echo(restring(["a", "b", "c", "d"]));
echo(restring(["a", "b", "c", "d"], sep="/"));
echo(restring([], "/"));

arr = [0, 1, 2, 3, 4, 5];
echo(slice(arr, 0, len(arr)));
echo(slice(arr, 1, 4));

echo(stripL("...foo", "."));
echo(stripL("bar...", "."));
echo(stripL("foobar", ""));

echo(stripR("...foo", "."));
echo(stripR("bar...", "."));
echo(stripR("foobar", ""));

echo(split("abcdef", ""));
echo(split("abcdef"));
echo(split("abcdef", "d"));
echo(split("This is  a   sentence."));

mt = [[1, 1, 1], [2, 2, 2], [3, 3, 3]];
echo(mt);
echo(transpose(mt));

echo(vec(3.141));
echo(vec(2.3, 2));

echo(x());
echo(y(23));
echo(z(-7));

v = [1, 2, 3];
echo(x(v));
echo(y(v));
echo(z(v));

grid_array(max_per_line = 3, spacing = 10){
	stretch() circle();
	stretch([3, 1.5, 7]) cylinder(h = 10);
	circle();
	square();
	cube(5);
	cylinder(h=10, r = 4);
}




