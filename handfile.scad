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

use <workbench/multitool.scad>


// chamfer a 2D shape if h=0, or an extruded 3D shape if h>0
module chamfer(e = 1, h = 0, c = 4){ _edge(e, h, c, fillet = false) children(); }

// fillet a 2D shape if h=0, or an extruded 3D shape if h>0
module fillet(e = 1, h = 0, c = 4){ _edge(e, h, c, fillet = true) children(); }

// chamfer only along the extruded plane of a 3D shape. 
// This allows for combined-edge operations such as filleted chamfers
module chamfer_extrude(e = 1, h = 10, c = 4, top = true, bottom = true){
  
  start = bottom ? e : 0;
  finish = top ? h - e : h;
  
  hull(){
    
    linear_extrude(height = h, convexity = c)
      offset(r = -e)
        children();
        
    translate(z(start))
      linear_extrude(height = finish - start, convexity = c)
        children();
  }
}

// primitive type for easy chamfering via the Minkowski Sum operator
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

module _edge(e, h, c, fillet){

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
        linear_extrude(h - (e*2), convexity = c)
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


grid_spacing(spacing = 12){
  
  square(10);

  chamfer_extrude() fillet() square(10);
  
  chamfer(h=10) square(10);
}

