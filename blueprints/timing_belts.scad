use <workbench/multitool.scad>

tooth_radius = 0.555;
blend_radius = 1;
tooth_height = 0.75;
blend_offset = 0.4;
fillet_radius = 0.15;
pitch = 2;
belt_profile_height = 1.38;

tip_rad_offset = tooth_height - tooth_radius;
fillet_center_point = sqrt(pow(blend_radius + fillet_radius, 2) - fillet_radius * fillet_radius) - blend_offset;
belt_thickness = belt_profile_height - tooth_height;
blend_height = blend_radius * (tip_rad_offset / sqrt(tip_rad_offset * tip_rad_offset + blend_offset * blend_offset));

module gt2_tooth_profile() {
  
  translate(y(tip_rad_offset))
    circle(r = tooth_radius);
  
  intersection() {
    
    intersection_for(x = [-1, 1]) {
      translate(x(x*blend_offset))
        circle(r = blend_radius);
    }
    
    translate([-pitch/2, -belt_thickness])
      square([pitch, belt_thickness + blend_height]);
  }
  
  difference() {
    translate([-fillet_center_point, -belt_thickness])
      square([fillet_center_point * 2, fillet_radius + belt_thickness]);
      
    for(x = [-1, 1])
      translate([x*fillet_center_point, fillet_radius])
        circle(r = fillet_radius);
  
  }
  
  translate([-pitch / 2 - 0.1, -belt_thickness])
    square([pitch + 0.2, belt_thickness]);
}

// test code

gt2_tooth_profile($fs = 0.1, $fa = 6);
