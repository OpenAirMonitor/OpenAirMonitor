/*
Original version licensed under [CC-BY-SA](https://creativecommons.org/licenses/by-sa/3.0/)
by [mcseven on Thingiverse](https://www.thingiverse.com/thing:1680291)
https://www.thingiverse.com/thing:1680291

Modified by [Gerrit Niezen](https://github.com/OpenAirMonitor/OpenAirMonitor/tree/main/enclosure)

Also contains bent pipe segments from:
https://github.com/fo-am/sonic-kayaks/blob/master/hardware/3dp/pm-box-home-print.scad
Sonic Kayak sensors, electronics designs and waterproofing systems Copyright (C) 2020 FoAM Kernow
CERN Open Hardware Licence Version 2 - Strongly Reciprocal

*/

lid = true;
box = true;

use <include/zip_tie_cable_holder.scad>;

/* [Box Options] */
// Dimension: Box outer X-Size [mm]
box_Size_X          = 112.6;
// Dimension: Box outer Y-Size [mm]
box_Size_Y          = 100;
// Dimension: Box Inner height [mm]
box_Inner_Height    = 33.6;
// Box bottom/top thickness
box_BottomTop_Thickness =  1.2; // [0.6:0.2:3]
// Edge corner radius 
box_Screw_Corner_Radius   =  7; // [2:1:10]
// four outer screw hole diameters
box_Screw_Diameter     =  3.2; // [2:0.2:4]
// Box wall thickness
box_Wall_Thickness     =  2.5; // [0.4:0.2:3.2]
/* [Top Barrier Options] */
// Box barrier thickness
barrier_Thickness  =  1; // [0.4:0.2:3.2]
// Box barrier height
barrier_Height     =  3.8;   // [1.0:0.2:8]
// Additional width on the lid to correct for badly calibrated printers
barrier_Tolerance  =  0.5; // [0.0:0.1:1]
/* [Mouting Screw Nose Options] */
// Number of screw noses
screwnose_Number        = 2; // [0:No noses, 2: one top/one bottom, 4: two top/two bottom]
// Diameter of the noses' screw holes
screwnose_Diameter      = 4; // [2:0.2:8]
// Height of the noses
screwnose_Height        = 5; // [2:0.2:10]
// Wall thickness
screwnose_Wall_Thickness = 2.8; // [2:0.2:5]

$fn = 40;
sideLength = 100;
faceplateLength = 120;
height = 20;
holeLength = 12;

%rotate([0, 0, 180])
translate([-1130, 774, 2])
resize([88, 0, 0], true)
import("include/PCB.stl");

// **************************
// ** Calculated globals
// **************************
boxHeight = box_Inner_Height+box_BottomTop_Thickness;

module box() {
	barrier_Thickness = box_Wall_Thickness-barrier_Thickness;
	difference() {
		union() {
			// solid round box, corners
			translate([box_Screw_Corner_Radius, box_Screw_Corner_Radius, 0]) cylinder(r=box_Screw_Corner_Radius, h=boxHeight, $fn=50); // bottom left
			translate([box_Size_X-box_Screw_Corner_Radius, box_Screw_Corner_Radius, 0]) cylinder(r=box_Screw_Corner_Radius, h=boxHeight, $fn=50); // bottom right
			translate([box_Screw_Corner_Radius, box_Size_Y-box_Screw_Corner_Radius, 0]) cylinder(r=box_Screw_Corner_Radius, h=boxHeight, $fn=50); // top left
			translate([box_Size_X-box_Screw_Corner_Radius, box_Size_Y-box_Screw_Corner_Radius, 0]) cylinder(r=box_Screw_Corner_Radius, h=boxHeight, $fn=50); // bottom right
			// solid round box, inner filling
			translate([0, box_Screw_Corner_Radius, 0]) cube([box_Size_X, box_Size_Y-2*box_Screw_Corner_Radius, boxHeight]);
			translate([box_Screw_Corner_Radius, 0, 0]) cube([box_Size_X-2*box_Screw_Corner_Radius, box_Size_Y, boxHeight]);
			// solid round box, top border
			translate([barrier_Thickness, box_Screw_Corner_Radius+barrier_Thickness, 0]) cube([box_Size_X-2*barrier_Thickness, box_Size_Y-2*box_Screw_Corner_Radius-2*barrier_Thickness, boxHeight+(barrier_Height/2)]);
			translate([box_Screw_Corner_Radius+barrier_Thickness, barrier_Thickness, 0]) cube([box_Size_X-2*box_Screw_Corner_Radius-2*barrier_Thickness, box_Size_Y-2*barrier_Thickness, boxHeight+(barrier_Height/2)]);
      
      // antenna cover
      translate([21.5, -53, 0]) cylinder(r=8, h=21, $fn=20);   
      rotate([90, 0, 0]) translate([13.5, 0, 0]) cube([16, 21, 53]);
		}
		// inner cut-out
		translate([box_Wall_Thickness, box_Screw_Corner_Radius+box_Wall_Thickness, box_BottomTop_Thickness]) cube([box_Size_X-2*box_Wall_Thickness, box_Size_Y-2*box_Screw_Corner_Radius-2*box_Wall_Thickness, boxHeight+barrier_Height]);
		translate([box_Screw_Corner_Radius+box_Wall_Thickness, box_Wall_Thickness, box_BottomTop_Thickness]) cube([box_Size_X-2*box_Screw_Corner_Radius-2*box_Wall_Thickness, box_Size_Y-2*box_Wall_Thickness, boxHeight+barrier_Height]);
		// Screw holes
		translate([(box_Screw_Corner_Radius+box_Wall_Thickness)/2,(box_Screw_Corner_Radius+box_Wall_Thickness)/2,0]) cylinder(r=box_Screw_Diameter/2, h=boxHeight+1, $fn=20);
		translate([(box_Screw_Corner_Radius+box_Wall_Thickness)/2,box_Size_Y-(box_Screw_Corner_Radius+box_Wall_Thickness)/2,0]) cylinder(r=box_Screw_Diameter/2, h=boxHeight+1, $fn=20);
		translate([box_Size_X-(box_Screw_Corner_Radius+box_Wall_Thickness)/2,(box_Screw_Corner_Radius+box_Wall_Thickness)/2,0]) cylinder(r=box_Screw_Diameter/2, h=boxHeight+1, $fn=20);
		translate([box_Size_X-(box_Screw_Corner_Radius+box_Wall_Thickness)/2,box_Size_Y-(box_Screw_Corner_Radius+box_Wall_Thickness)/2,0]) cylinder(r=box_Screw_Diameter/2, h=boxHeight+1, $fn=20);
		// **************************
		// ** YOUR OWN CUTOUTS HERE!
		// **************************
        
        // faceplate
        rotate([90, 0, 0]) {

            translate([7, 0, 0]) {
                
                //antenna hole
                translate([8.5, 1.2, -4])
                   cube([12, 18, 59]);

                
                // PMS7003 holes
                translate([38, 14.5, -(holeLength/2)]) {
                    cube([10, 3, holeLength]);
                    
                    translate([26, -3, 0])
                        cube([12.5, 6, holeLength]);
                }
                
                // hole for solar panel
                translate([70, 17, -(holeLength/2)-sideLength])
                    cylinder(holeLength, d = 12);
                
                // inset for PMS7003 sensor
                // translate([34, 1, -3])
                //     cube([55, 20, 2]);
                
            }
        }

		// **************************
		// ** / CUTOUTS
		// **************************
	}
    /*
	// Lower nose(s)
	if (screwnose_Number==2) translate([box_Size_X/2, 0.001, 0]) mirror([0,1,0]) screwNose(screwnose_Diameter, screwnose_Height);
	if (screwnose_Number==4) {
		translate([box_Size_X*0.25, 0.001, 0]) mirror([0,1,0]) screwNose(screwnose_Diameter, screwnose_Height);
		translate([box_Size_X*0.75, 0.001, 0]) mirror([0,1,0]) screwNose(screwnose_Diameter, screwnose_Height);
	}
	// Upper nose(s)
	if (screwnose_Number==2) translate([box_Size_X/2, box_Size_Y-0.001, 0]) screwNose(screwnose_Diameter, screwnose_Height);
	if (screwnose_Number==4) {
		translate([box_Size_X*0.25, box_Size_Y-0.001, 0]) screwNose(screwnose_Diameter, screwnose_Height);
		translate([box_Size_X*0.75, box_Size_Y-0.001, 0]) screwNose(screwnose_Diameter, screwnose_Height);
	}
    */
}

module mountPCB() {
    translate([1, 1, 0]) {
        translate([12, 9.7, 0]) {
            cylinder(5, d = 1.7);
            cylinder(3, d = 3);
        }

        translate([92.2, 7.8, 0]) {
            cylinder(5, d = 1.7);
            cylinder(3, d = 3);
        }

        translate([92.1, 69.4, 0]) {
            cylinder(5, d = 1.7);
            cylinder(3, d = 3);
        }

        translate([15.2, 68.5, 0]) {
            cylinder(5, d = 1.7);
            cylinder(3, d = 3);
        }
    }
}

module mountSensor() {
    holeDiameter = 2.4;
    holeX = 20.32;
    holeY = 12.7;
    
    translate([20, 80, 0]) {

        cylinder(5, d = holeDiameter);
        cylinder(3, d = 4);


        translate([holeX, 0, 0]) {
            cylinder(5, d = holeDiameter);
            cylinder(3, d = 4);
        }

        translate([0, holeY, 0]) {
            cylinder(5, d = holeDiameter);
            cylinder(3, d = 4);
        }

        translate([holeX, holeY, 0]) {
            cylinder(5, d = holeDiameter);
            cylinder(3, d = 4);
        }
    }
}

module nutHole() {
    cylinder(r=box_Screw_Diameter/2, h=boxHeight, $fn=20);
    cylinder(d=6.2, h=2.6, $fn=6);
}

module lid() {
	boxHeight = box_BottomTop_Thickness+barrier_Height;
	difference() {
		union() {
			// solid round box, corners
			translate([box_Screw_Corner_Radius, box_Screw_Corner_Radius, 0]) cylinder(r=box_Screw_Corner_Radius, h=boxHeight, $fn=50); // bottom left
			translate([box_Size_X-box_Screw_Corner_Radius, box_Screw_Corner_Radius, 0]) cylinder(r=box_Screw_Corner_Radius, h=boxHeight, $fn=50); // bottom right
			translate([box_Screw_Corner_Radius, box_Size_Y-box_Screw_Corner_Radius, 0]) cylinder(r=box_Screw_Corner_Radius, h=boxHeight, $fn=50); // top left
			translate([box_Size_X-box_Screw_Corner_Radius, box_Size_Y-box_Screw_Corner_Radius, 0]) cylinder(r=box_Screw_Corner_Radius, h=boxHeight, $fn=50); // bottom right
			// solid round box, inner filling
			translate([0, box_Screw_Corner_Radius, 0]) cube([box_Size_X, box_Size_Y-2*box_Screw_Corner_Radius, boxHeight]);
			translate([box_Screw_Corner_Radius, 0, 0]) cube([box_Size_X-2*box_Screw_Corner_Radius, box_Size_Y, boxHeight]);
			// solid round box, top border
		}
		// inner cut-out X direction
		translate([
			box_Wall_Thickness-(barrier_Thickness+barrier_Tolerance),
			box_Screw_Corner_Radius+box_Wall_Thickness-(barrier_Thickness+barrier_Tolerance),
			box_BottomTop_Thickness
		]) cube([
			box_Size_X-2*(box_Wall_Thickness)+2*(barrier_Thickness+barrier_Tolerance),
			box_Size_Y-2*box_Screw_Corner_Radius-2*(box_Wall_Thickness)+2*(barrier_Thickness+barrier_Tolerance),
			box_BottomTop_Thickness+barrier_Height
		]);
		// inner cut-out Y direction
		translate([
			box_Screw_Corner_Radius+box_Wall_Thickness-(barrier_Thickness+barrier_Tolerance),
			box_Wall_Thickness-(barrier_Thickness+barrier_Tolerance),
			box_BottomTop_Thickness
		]) cube([
			box_Size_X-2*box_Screw_Corner_Radius-2*(box_Wall_Thickness)+2*(barrier_Thickness+barrier_Tolerance),
			box_Size_Y-2*(box_Wall_Thickness)+2*(barrier_Thickness+barrier_Tolerance),
			box_BottomTop_Thickness+barrier_Height
		]);
		
		// Screw holes
		translate([(box_Screw_Corner_Radius+box_Wall_Thickness)/2,(box_Screw_Corner_Radius+box_Wall_Thickness)/2,0]) cylinder(r=box_Screw_Diameter/2, h=boxHeight, $fn=20);
		translate([(box_Screw_Corner_Radius+box_Wall_Thickness)/2,box_Size_Y-(box_Screw_Corner_Radius+box_Wall_Thickness)/2,0]) nutHole();
		translate([box_Size_X-(box_Screw_Corner_Radius+box_Wall_Thickness)/2,(box_Screw_Corner_Radius+box_Wall_Thickness)/2,0]) cylinder(r=box_Screw_Diameter/2, h=boxHeight, $fn=20);
		translate([box_Size_X-(box_Screw_Corner_Radius+box_Wall_Thickness)/2,box_Size_Y-(box_Screw_Corner_Radius+box_Wall_Thickness)/2,0]) nutHole();
	}

	// inner add X direction
	translate([box_Wall_Thickness+barrier_Tolerance, box_Screw_Corner_Radius+box_Wall_Thickness+barrier_Tolerance, box_BottomTop_Thickness])
		cube([box_Size_X-2*(box_Wall_Thickness+barrier_Tolerance), box_Size_Y-2*(box_Screw_Corner_Radius+box_Wall_Thickness+barrier_Tolerance), barrier_Height]);
	// inner add Y direction
	translate([box_Screw_Corner_Radius+box_Wall_Thickness+barrier_Tolerance, box_Wall_Thickness+barrier_Tolerance, box_BottomTop_Thickness])
		cube([box_Size_X-2*(box_Screw_Corner_Radius+box_Wall_Thickness+barrier_Tolerance), box_Size_Y-2*(box_Wall_Thickness+barrier_Tolerance), barrier_Height]);
}

module screwNose(screwholeDiameter=4, noseHeight=5) {
	additionalDistanceFromWall = 1;
	translate([0,screwholeDiameter/2+screwnose_Wall_Thickness+additionalDistanceFromWall, 0]) difference() {
		union() {
			translate([-(screwholeDiameter/2+screwnose_Wall_Thickness), -(screwholeDiameter/2+screwnose_Wall_Thickness+additionalDistanceFromWall),0]) cube([(screwholeDiameter/2+screwnose_Wall_Thickness)*2, screwholeDiameter/2+screwnose_Wall_Thickness+additionalDistanceFromWall, noseHeight]);
			cylinder(r=(screwholeDiameter/2)+screwnose_Wall_Thickness, h=noseHeight, $fn=60);
		}
		cylinder(r=screwholeDiameter/2, h=noseHeight, $fn=60);
	}
}

module bent_pipe() {
    nipple_width=13.0;
    nipple_hole_width=11.0;
    nipple_height=6.0;
    nipple_hole_height=4.0;
    
    rotate([0,90,90]) {
        rotate_extrude(angle=90) {
            translate([5,0,0])
            difference() {
                square([nipple_height,nipple_width],true);
                square([nipple_hole_height,nipple_hole_width],true);
            }            
        }
        translate([5,-1.5,0]) {
            difference() {
                cube([nipple_height,3,nipple_width],true);
                cube([nipple_hole_height,3.1,nipple_hole_width],true);
            }
            
            rotate([0,0,90])
                translate([6.48,11,0])
                    difference() {
                        cube([nipple_height,12,nipple_width],true);
                        cube([nipple_hole_height,12.1,nipple_hole_width],true);
                    }
        }
    }
}



if (box) {
    box();
    mountPCB();
    mountSensor();

    difference() {
        translate([50, -2, 11])
            rotate([0, 180, -90]) {
                bent_pipe();
                
                translate([0, 27.2, 3.9])
                    scale([1, 1.2, 1.4])
                        bent_pipe();
            }
        translate([10,0,0])
            rotate([180,0,0])
                cube([box_Size_X, 20, 10]);
    }
}

if (lid) {
    if (box_Size_X>box_Size_Y) {
        translate([0, box_Size_Y+5+screwnose_Diameter+screwnose_Wall_Thickness, 0]) lid();	
    } else {
        translate([box_Size_X+5, 0, 0]) lid();	
    }

    translate([93, 175, box_BottomTop_Thickness+barrier_Height]) {
        zip_tie_anchor();
        
        translate([-75, 0, 0])
            zip_tie_anchor();
    }
}


// distance between screw holes should match solar panel
translate([6.3,5,34])
rotate([0, 90, 0])
%cylinder(100, d=5);

// o-ring
translate([2,170,5])
rotate([90, 0, 0])
%cylinder(40, d=1.8);

rotate([90, 0, 0])
translate([14.5, 11, 0])
%cylinder(54, d=10);