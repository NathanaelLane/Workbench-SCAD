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
 
use <workbench/partsbin.scad>
use <workbench/multitool.scad>
use <workbench/handfile.scad>
use <workbench/blueprints/regular_polygon.scad>
use <workbench/blueprints/triangle.scad>
  
_THREAD = Collection(
  Template("thread_d, pilot_d, pitch"),
  [
    ["m3", 3, 2.5, 0.5],
    ["m4", 4, 3.3, 0.7],
    ["m8", 8, 6.8, 1.25]
  ]);

_screw_library = Collection(
  Template("socket_type, head_type, socket_d, head_h, head_d"),
  [
    ["m3", "hex", "cap", 2.5, 2.4, 5.5],
    ["m3", "hex", "set", 1.5],
    ["m4", "hex", "cap", 3, 4, 7],
    ["m8", "hex", "cap", 6, 8, 13],
    ["m8", "hex", "button", 5, 4.4, 14]
  ], [], range(0, 2), _THREAD);
  
function Screw(type, length) = Obj(Template("l"), [length], [v(_screw_library, type)]);

module screw(scr){
	
	module screw(){
	
		scale([1, 1, -1])
			cylinder(d = v(scr, "thread_d"), h = v(scr, "l"));
	}
	
	module socket(){
    t = v(scr, "socket_type");
		if(t == "hex"){
      linear_extrude(height = max(v(scr, "socket_d"), 2), center = true)
        regular_polygon(ns = 6, d = v(scr, "socket_d"));
    }
	}
	
	module cap_head(){
	
    intersection(){
      
      difference(){
      
        fillet(e = v(scr, "head_d") * 0.1, h = v(scr, "head_h") * 2, center = true) 
          circle(d = v(scr, "head_d"), h = v(scr, "head_h") * 2, center = true);

        translate(z(v(scr, "head_h")))
          socket();
      }

      cylinder(h = v(scr, "head_h") + 1, d = v(scr, "head_d") + 2);
    }
    
    screw(); 
	}
	
	module button_head(){
	
    difference(){

      intersection(){

        rh = v(scr, "head_d") / 2;
        rt = v(scr, "thread_d") / 2;
        edge = v(scr, "head_h") * 0.2;
        h = v(scr, "head_h") - edge;
        x = ((rh * rh) - (rt * rt) - (h * h)) / (2 * h);

        translate(z(edge - x))
          sphere(r = sqrt(rh * rh + x * x));

        cylinder(r = rh, h = v(scr, "head_h"));
      }

      translate(z(v(scr, "head_h")))
        socket();
    }
    
    screw();
	}
	
	module setscr(){
	
		difference(){
	
			screw();

			socket();
		}
	}
  
  type = v(scr, "head_type");
  
  echo(str("m", v(scr, "thread_d"), "x", v(scr, "l"), "mm ", v(scr, "socket_type"), " ", type, " screw"));
	
  render(convexity = 10)
    if(type == "cap"){
      cap_head();
    }else{
      
      if(type == "button"){
  
        button_head();
      }else{
  
        if(type == "set")
          setscr();
      }
    }
}


_nut_library = Collection(
  Template("type, h, flat_d"),
  [
    ["m3", "hex", 2.4, 5.5],
    ["m8", "thin-hex", 4, 13],
    ["m4", "hex", 3.2, 7]
  ], [], range(0, 1), _THREAD);

function Nut(type) = v(_nut_library, type);

module nut(nut){

	t = v(nut, "type");
	echo(str("m", v(nut, "thread_d"), " ", t, " nut"));
	
	module hex_nut(){
	
		linear_extrude(height = v(nut, "h"))
			difference(){

				regular_polygon(ns = 6, d = v(nut, "flat_d"));

				circle(d = v(nut, "thread_d"));
			}
	}
	
	module lock_nut(){
	
		difference(){

			union(){

				collar = v(nut, "thread_d") / 4;

				linear_extrude(height = v(nut, "h") - collar * 1.25)
					regular_polygon(ns = 6, d = v(nut, "flat_d"));

				fillet(h = v(nut, "h"), e = collar) circle(d = v(nut, "flat_d"));
			}

			translate(z(-1))
				cylinder(d = v(nut, "thread_d"), h = v(nut, "h") + 2);
		}
	}
	
  render(convexity = 10)
    if(t == "hex" || t == "thin-hex"){
    
      hex_nut();
    }else{

      if(t == "nylock")
        lock_nut();
    }
}
  
_washer_library = Collection(
  Template("type, h, od, id"),
  [
    ["m3", "flat", 0.5, 7, 3.2],
    ["m3", "internal-tooth-lock", 0.5, 6, 3.2],
    ["m8", "flat", 1.5, 16, 8.4],
    ["m8", "internal-tooth-lock", 0.9, 15, 8.4],
    ["m4", "flat", 0.8, 9, 4.3],
    ["m4", "internal-tooth-lock", 0.6, 8, 4.3]
  ], [], range(0, 1), _THREAD);

function Washer(type) = v(_washer_library, type);

module washer(wsh){

	t = v(wsh, "type");
	echo(str("m", v(wsh, "thread_d"), " ", t, " washer"));

	module flat_washer(){

		linear_extrude(height = v(wsh, "h"))
			difference(){
		
				circle(d = v(wsh, "od"));
		
				circle(d = v(wsh, "id"));
			
				children();
			}
	}
	
	module tooth_lock_washer(){
	
		flat_washer(wsh)
			for(x = [0:7])
				rotate(z(x * 360 / 8))
					intersection(){

						r = (v(wsh, "od") + v(wsh, "id")) / 4;
						triangle(a = 360 / 30, h = r);

						circle(r = r);
					}
	}
	
  render(convexity = 10)
    if(t == "flat"){

      flat_washer();
    }else{

      if(t == "internal-tooth-lock")
        tooth_lock_washer();		
    }
}
// test code

$fs = 0.05;
$fa = 5;
grid_array(spacing = 20, max_per_line = 5){
  screw(Screw("m8_hex_button", 20));
  screw(Screw("m3_hex_set", 10));
  screw(Screw("m4_hex_cap", 15));
  nut(Nut("m3_hex"));
  washer(Washer("m8_internal-tooth-lock"));
  washer(Washer("m3_flat"));

}

