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

use <workbench/blueprints/triangle.scad>
use <workbench/multitool.scad>


// helper function to compute corner radius from side (tangent) radius
function corner_radius(r, ns=6) = r / cos(180/ns);

/*
 * -r: radius (measured from center to flat, not center to corner)
 * -d: diameter (if both radius and diameter are specified, behavior is undefined)
 * -ns: desired number of sides
 * -sl: desired minimum side length
 */
module regular_polygon(r=0, d=2, ns=6, sl=0.01) {
	
		function sideLength(r, ns) = r * tan(180/ns) * 2;
		
		function fa(ns, r) = 
			ns > 3 && sideLength(r, ns) < sl ?
				fa(ns - 1, r)
			:
				360 / ns;
				
		_r = (r == 0) ? d / 2 : r;
		a = fa(ns, _r);
		
		if(a > 72){
	
			if(a > 90){
			
				translate(y(_r * 2))	
					triangle(a = 60, h = _r * 3);
			}else{
			
				rotate(z(45))
						square(_r * 2, center = true);
			}
		}else{
		
			rotate(z(90))		
				circle(r = cornerRadius(r), $fa = a, $fs = sl);
		}
}

// test code

grid_spacing(spacing = 30, max_per_line = 4){
	regpol(r = 10, ns = 3);
	regpol(r = 10, ns = 4);
	regpol(r = 10, ns = 5);
	regpol(r = 10, ns = 6);
	regpol(r = 10, ns = 7);
	regpol(r = 10, ns = 8);
	regpol(r = 10, ns = 25);
	regpol(r = 10, ns = 300);
}
