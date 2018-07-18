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
include <workbench/blueprints/blueprints.scad>

use <workbench/partsbin.scad>
use <workbench/multitool.scad>
use <workbench/handfile.scad>
use <workbench/geometry/regular_polygon.scad>
use <workbench/geometry/triangle.scad>

_thread_library = Collection(
  THREAD,
  [
    ["m3", 3, 2.5, 0.5],
    ["m4", 4, 3.3, 0.7],
    ["m8", 8, 6.8, 1.25],
    ["m2", 2, 1.6, 0.4],
    ["m2_5", 2.5, 1.75, 0.45]
  ]);

/*
 * [object] Return a thread-size object from the built-in library
 *
 * - type: [string] the lookup key
 */
function Thread(type) = v(_thread_library, type);

_screw_library = Collection(
  SCREW_HEAD,
  [
    ["m3", "hex", "cap", 2.5, 2.4, 5.5],
    ["m3", "hex", "set", 1.5],
    ["m4", "hex", "cap", 3, 4, 7],
    ["m4", "hex", "button", 2.5, 2.2, 7.6],
    ["m8", "hex", "cap", 6, 8, 13],
    ["m8", "hex", "button", 5, 4.4, 14],
    ["m2", "hex", "cap", 1.5, 2, 3.8]
  ], [], range(0, 2), _thread_library);

/*
 * [object] Return a screw object from the built-in library
 *
 * - type: [string] the screw type, e.g. philips cap head
 * - length: [number] the desired length of the screw
 */
function Screw(type, length) = Obj(Template("l"), [length], [v(_screw_library, type)]);

/*
 * [3D] render a screw
 *
 * - scr: [object] the screw object to render
 * - no_render: [boolean] proxy for the blueprint no_render parameter
 */
module screw(scr, no_render = false) {

  module shaft() {

    scale([1, 1, -1])
      cylinder(d = v(scr, "thread_d"), h = v(scr, "l"));
  }

	module socket() {
    
    t = v(scr, "socket_type");
    
		if(t == "hex") {
      
      linear_extrude(height = max(v(scr, "socket_d"), 2), center = true)
        regular_polygon(ns = 6, d = v(scr, "socket_d"));
    }
	}

	module cap_head() {

    intersection() {

      difference() {

        fillet(e = v(scr, "head_d") * 0.1, h = v(scr, "head_h") * 2, center = true)
          circle(d = v(scr, "head_d"), h = v(scr, "head_h") * 2, center = true);

        translate(z(v(scr, "head_h")))
          socket();
      }

      cylinder(h = v(scr, "head_h") + 1, d = v(scr, "head_d") + 2);
    }

    shaft();
	}

	module button_head() {

    difference() {

      intersection() {

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

    shaft();
	}

	module setscr() {

		difference() {

			shaft();

			socket();
		}
	}

  type = v(scr, "head_type");

  blueprint(str("m", v(scr, "thread_d"), "x", v(scr, "l"), "mm ", v(scr, "socket_type"), "-socket ", type, " screw"), no_render) {

    if(type == "cap") {
      cap_head();
    } else if(type == "button") {
      button_head();
    } else if(type == "set") {
      setscr();
    }
  }
}


_nut_library = Collection(
  NUT,
  [
    ["m3", "hex", 2.4, 5.5],
    ["m8", "thin-hex", 4, 13],
    ["m4", "hex", 3.2, 7],
    ["m4", "square", 3.2, 7],
    ["m2", "hex", 1.6, 4]
  ], [], range(0, 1), _thread_library);

/*
 * [object] Return a threaded-nut object from the built-in library
 *
 * - type: [string] the lookup key
 */
function Nut(type) = v(_nut_library, type);

/*
 * [3D] render a threaded nut
 *
 * - nut: [object] the nut object to render
 * - no_render: [boolean] proxy for the blueprint no_render parameter
 */
module nut(nut, no_render = false) {

	module hex_nut(ns = 6) {

		linear_extrude(height = v(nut, "h"))
			difference() {

				regular_polygon(ns = ns, d = v(nut, "flat_d"));

				circle(d = v(nut, "thread_d"));
			}
	}

	module lock_nut() {

		difference() {

			union() {

				collar = v(nut, "thread_d") / 4;

				linear_extrude(height = v(nut, "h") - collar * 1.25)
					regular_polygon(ns = 6, d = v(nut, "flat_d"));

				fillet(h = v(nut, "h"), e = collar) circle(d = v(nut, "flat_d"));
			}

			translate(z(-1))
				cylinder(d = v(nut, "thread_d"), h = v(nut, "h") + 2);
		}
	}

	t = v(nut, "type");
  
	blueprint(str("m", v(nut, "thread_d"), " ", t, " nut"), no_render) {

    if(t == "hex" || t == "thin-hex") {
      hex_nut();
    } else if(t == "nylock") {
      lock_nut();
    } else if(t == "square") {
      rotate(z(45))
        hex_nut(ns = 4);
    }
  }
}

_washer_library = Collection(
  WASHER,
  [
    ["m3", "flat", 0.5, 7, 3.2],
    ["m3", "internal-tooth-lock", 0.5, 6, 3.2],
    ["m8", "flat", 1.5, 16, 8.4],
    ["m8", "internal-tooth-lock", 0.9, 15, 8.4],
    ["m4", "flat", 0.8, 9, 4.3],
    ["m4", "internal-tooth-lock", 0.6, 8, 4.3]
  ], [], range(0, 1), _thread_library);

/*
 * [object] Return a washer object from the built-in library
 *
 * - type: [string] the lookup key
 */
function Washer(type) = v(_washer_library, type);

/*
 * [3D] render a washer
 *
 * - wsh: [object] the washer object to render
 * - no_render: [boolean] proxy for the blueprint no_render parameter
 */
module washer(wsh, no_render = false) {

	module flat_washer() {

		linear_extrude(height = v(wsh, "h"))
			difference() {

				circle(d = v(wsh, "od"));

				circle(d = v(wsh, "id"));

				children();
			}
	}

	module tooth_lock_washer() {

		flat_washer(wsh)
			for(x = [0:7])
				rotate(z(x * 360 / 8))
					intersection() {

						r = (v(wsh, "od") + v(wsh, "id")) / 4;
						triangle(a = 360 / 30, h = r);

						circle(r = r);
					}
	}

	t = v(wsh, "type");
  
	blueprint(str("m", v(wsh, "thread_d"), " ", t, " washer"), no_render) {
    
    if(t == "internal-tooth-lock") {
      tooth_lock_washer();
    } else {
        flat_washer();
    }
  }
}
// test code

$fs = 0.05;
$fa = 5;
grid_array(spacing = 20, max_per_line = 5) {
  screw(Screw("m8_hex_button", 20));
  screw(Screw("m3_hex_set", 10));
  screw(Screw("m4_hex_cap", 15));
  nut(Nut("m3_hex"));
  nut(Nut("m4_square"));
  washer(Washer("m8_internal-tooth-lock"));
  washer(Washer("m3_flat"));

}
