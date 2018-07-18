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
 
// Handfile: for those nice, finished edges


/*
 * [2D], [3D] chamfer a 2D shape if h=0, or an extruded 3D shape if h>0.
 * This has the effect of "flattening" out rounded edges. If no children are given,
 * the module will produce a 2D shape if h=0, or an extruded shape if h>0, that can 
 * be used subtractively to chamfer a single corner.
 * 
 * - e: [number] edge radius. Default is 1
 * - h: [number] extrude height. Default is 0 (2D shape)
 * - convexity: [integer] pass-through for linear_extrude() convexity parameter
 * - center: [boolean] center the shape vertically if 3D 
 */
module chamfer(e = 1, h = 0, convexity, center) { 
  if($children != 0) {
    _edge(e, h, convexity, fillet = false, center = center) children(); 
  } else {
    _single_edge(h, center)
      rotate([0, 0, 45])
        square(e * sqrt(2), center = true);
  }
}

/*
 * [2D], [3D] fillet a 2D shape if h=0, or an extruded 3D shape if h>0.
 * If no children are given, the module will produce a 2D shape if h=0, 
 * or an extruded shape if h>0, that can be used subtractively to fillet 
 * a single corner.
 * 
 * - e: [number] edge radius. Default is 1
 * - h: [number] extrude height. Default is 0 (2D shape)
 * - convexity: [integer] pass-through for linear_extrude() convexity parameter 
 * - center: [boolean] center the shape vertically if 3D
 */
module fillet(e = 1, h = 0, convexity, center) { 
  if($children != 0) {
    _edge(e, h, convexity, fillet = true, center = center) children();
  } else {
    offs = [-1, 1] * e;
    _single_edge(h, center)
      difference() {
        square(e * 2, center = true);
        for(xo = offs)
          for(yo = offs)
            translate([xo, yo])
              circle(r=e);
      }
  }
}

/* 
 * [3D] chamfer only along the extruded plane of a 3D shape. 
 * This allows for combined-edge operations such as filleted chamfers
 * 
 * - e: [number] edge radius. Default is 1
 * - h: [number] extrude height. Default is 10
 * - convexity: [integer] pass-through for linear_extrude() convexity parameter
 * - top: [boolean] chamfer top of extrude. Default true
 * - bottom: [boolean] chamfer bottom of extrude. Default false
 * - center: [boolean] center the shape vertically if 3D
 */
module chamfer_extrude(e = 1, h = 10, convexity, top = true, bottom = true, center = false) {
  
  start = bottom ? e : 0;
  finish = top ? h - e : h;
  
  hull() {
    
    linear_extrude(height = h, convexity = convexity, center = center)
      offset(r = -e)
        children();
        
    translate(center ? vec(0) : z(start))
      linear_extrude(height = finish - start, convexity = convexity, center = center)
        children();
  }
}

/* 
 * [3D] octahedron primitive for easy chamfering via the Minkowski Sum operator
 * 
 * - r: [number] radius
 */
module octahedron(r = 0) {

	p = [
		[0, 0, r],
		[0, r, 0],
		[r, 0, 0],
		[0, -r, 0],
		[-r, 0, 0],
		[0, 0, -r]
	];

	t = [
		[0, 1, 2],
		[0, 2, 3],
		[0, 3, 4],
		[0, 4, 1],

		[5, 2, 1],
		[5, 1, 4],
		[5, 4, 3],
		[5, 3, 2]
	];
	
	polyhedron(points = p, faces = t, convexity = 2);
}

module _edge(e, h, convexity, fillet, center) {

  if(h == 0) {
          
    if(fillet) {
      
      minkowski() {
      
        offset(r = -2*e)
          offset(delta = e)	  
              children();
          
        circle(r = e);
      }
    } else {

      minkowski() {
        off = e * sqrt(2) / tan(22.5);
        offset(delta = -off, chamfer = true)
          offset(delta = off - e)
            children();
        
        rotate([0, 0, 45])
          square(e * sqrt(2), center = true);
      }
    }
  } else {
  
    minkowski() {
      
      translate(z(center ? 0 : e))
        linear_extrude(h - (e*2), convexity = convexity, center = center)
          offset(-e)
            children();
        
      if(fillet) {
        
        sphere(r = e);
      } else {
      
        octahedron(r = e);
      }
    }
  }
}

module _single_edge(h, center) {
  if(h == 0) {
    children();
  } else {
    linear_extrude(height = h, convexity = 4, center = center)
      children();
  }
}
// test code
//$fa = 6;
//$fs = 0.1;

use <workbench/multitool.scad>

grid_array(spacing = 12, max_per_line = 4, $fa = 6, $fs = 0.1) {
  
  square(10);

  chamfer_extrude() fillet() square(10);
  
  chamfer_extrude(center = true) chamfer() square(10);
  
  chamfer(h=10) square(10);
  
  fillet(h=10) square(10);
  
  translate([5, 5]) fillet(h=10, e=2) circle(5);
  
  translate([5, 5]) chamfer(h=10, e=3, center = true) circle(5);
  
  fillet(e = 4, h = 10) square(10);
  
  chamfer() fillet() square(10);
  
  fillet() chamfer() square(10);
  
  translate([5, 5]) chamfer_extrude() circle(5);
  
  translate([5, 5]) fillet(e = 5);
  
  translate([5, 5]) chamfer(e = 5);
  
  translate([5, 5]) fillet(e = 5, h=10);
  
  translate([5, 5]) chamfer(e = 5, h=10, center = true);
  
  fillet() { square([10, 5]); square([5, 10]); }
  
  chamfer() { square([10, 5]); square([5, 10]); }
}

