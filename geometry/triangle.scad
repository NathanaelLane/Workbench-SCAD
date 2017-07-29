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


/*
 * [2D] Creates an isosceles triangle given two of the following parameters. 
 * If more than two parameters are specified, the outcome is undefined.
 * 
 * - b: [number] length of base
 * - h: [number] base-to-apex distance (height)
 * - s: [number] length of sides
 * - a: [number] apex angle
 */
module triangle(b = 0, h = 0, s = 0, a = 0, base_origin = false) {
	
	ahBase = tan(a / 2) * h * 2;
	asBase = sin(a / 2) * s * 2;
	hsBase = sqrt((s * s) - (h * h));
	abHeight = (b / 2) / tan(a / 2);
	asHeight = cos(a / 2) * s;
	bsHeight = sqrt((s * s) - (b * b));

	baseLUT = [b, asBase, b, ahBase, b, hsBase];
	heightLUT = [abHeight, asHeight, bsHeight, h, h, h];

	lkup = min((sign(b) + sign(s) * 2 + sign(h) * 4) - 1, 5);
	base = baseLUT[lkup];
	height = heightLUT[lkup];

	translate([0, base_origin ? height : 0, 0])
			polygon([
				[0, 0], 
				[base / 2, -height], 
				[-base / 2, -height]
			]);	
}

// test code
$fa = 5;
$fs = 0.05;

use <workbench/multitool.scad>

grid_array() {
	triangle(b = 10, a = 60, base_origin = true);
	triangle(b=10, h=10);
	triangle(a=60, h = 10);
}
