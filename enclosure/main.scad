$fn = 40;
sideLength = 100;
faceplateLength = 95;
height = 20;


%rotate([0, 0, 180])
translate([-1123, 775, 2])
resize([88, 0, 0], true)
import("PCB.stl");


// faceplate
rotate([90, 0, 0]) {
    difference() {
        union() {
            cube([faceplateLength, height, 1]);
            translate([6, 0, -2])
                cube([16, height, 2]);
        }
        
        //antenna hole
        translate([14.5, 11, -3])
            cylinder(3, d = 8);
        
        translate([7.5, 1, -1])
            cube([14, 20, 3]);

        
        // PMS7003 holes
        translate([38, 13, -1]) {
            cube([10, 3, 3]);
            
            translate([26, -3, 0])
                cube([12.5, 6, 3]);
        }
    }
}


// bottom
cube([faceplateLength, sideLength, 1]);

translate([6, 9.7, 0]) {
    cylinder(5, d = 1.7);
    cylinder(3, d = 3);
}

translate([86.2, 7.8, 0]) {
    cylinder(5, d = 1.7);
    cylinder(3, d = 3);
}

translate([86.1, 69.4, 0]) {
    cylinder(5, d = 1.7);
    cylinder(3, d = 3);
}

translate([9.2, 68.5, 0]) {
    cylinder(5, d = 1.7);
    cylinder(3, d = 3);
}


// sides
rotate([90, 0, 90]) {
    cube([sideLength, height, 1]);
    translate([0, 0, faceplateLength - 1])
        cube([sideLength, height, 1]);
}

// backplate
translate([0, sideLength, 0])
    rotate([90, 0, 0])
        difference() {
            cube([faceplateLength, height, 1]);
            
            translate([70, 10, -1])
                cylinder(3, d = 12);
        }