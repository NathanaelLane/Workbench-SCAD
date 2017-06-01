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
 * This has the effect of "flattening" out rounded edges
 * 
 * - e: [number] edge radius. Default is 1
 * - h: [number] extrude height. Default is 0 (2D shape)
 * - convexity: [integer] pass-through for linear_extrude() convexity parameter 
 */
module chamfer(e = 1, h = 0, convexity){ _edge(e, h, convexity, fillet = false) children(); }

/*
 * [2D], [3D] fillet a 2D shape if h=0, or an extruded 3D shape if h>0
 * 
 * - e: [number] edge radius. Default is 1
 * - h: [number] extrude height. Default is 0 (2D shape)
 * - convexity: [integer] pass-through for linear_extrude() convexity parameter 
 */
module fillet(e = 1, h = 0, convexity){ _edge(e, h, convexity, fillet = true) children(); }


/* 
 * [3D] chamfer only along the extruded plane of a 3D shape. 
 * This allows for combined-edge operations such as filleted chamfers
 * 
 * - e: [number] edge radius. Default is 1
 * - h: [number] extrude height. Default is 10
 * - convexity: [integer] pass-through for linear_extrude() convexity parameter
 * - top: [boolean] chamfer top of extrude. Default true
 * - bottom: [boolean] chamfer bottom of extrude. Default false
 */
module chamfer_extrude(e = 1, h = 10, convexity, top = true, bottom = true){
  
  start = bottom ? e : 0;
  finish = top ? h - e : h;
  
  hull(){
    
    linear_extrude(height = h, convexity = convexity)
      offset(r = -e)
        children();
        
    translate(z(start))
      linear_extrude(height = finish - start, convexity = convexity)
        children();
  }
}

/* 
 * [3D] octahedron primitive for easy chamfering via the Minkowski Sum operator
 * 
 * - r: [number] radius
 */
module octahedron(r = 0){

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

module _edge(e, h, convexity, fillet){

  if(h == 0){
    
    minkowski(){
      offset(-e)
        children();
      
      if(fillet){
        
        circle(r = e);
      }else{
        
        rotate([0, 0, 45])
          square(e * sqrt(2), center = true);
      }
    }
  }else{
  
    minkowski(){
      translate(z(e))
        linear_extrude(h - (e*2), convexity = convexity)
          offset(-e)
            children();
        
      if(fillet){
        
        sphere(r = e);
      }else{
      
        octahedron(r = e);
      }
    }
  }
}

// test code
$fa = 5;
$fs = 0.05;

use <workbench/multitool.scad>

grid_array(spacing = 12, max_per_line = 4){
  
  square(10);

  chamfer_extrude() fillet() square(10);
  
  chamfer(h=10) square(10);
  
  fillet(h=10) square(10);
  
  fillet(h=10, e=2) circle(5);
  
  chamfer(h=10, e=3) circle(5);
  
  fillet(e = 4, h = 10) square(10);
  
  chamfer() fillet() square(10);
  
  fillet() chamfer() square(10);
  
  chamfer_extrude() circle(5);
}

