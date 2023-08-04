Frontpanel=0;
Backpanel=1;
Doos=0;
VoetjeVoor=0;
VoetjeAchter=0;
$fn=150;

//translate([0,0,10])LCDFrame();

if(VoetjeVoor) translate([0,0,-60]){
 cylinder(d=3.8,h=2.2);
 translate([0,0,-4])
  cylinder(d1=10,d2=12,h=4); 
}

if(VoetjeAchter) translate([20,0,-60]){
 cylinder(d=3.8,h=2.2);
 translate([0,0,-2])
  cylinder(d1=6,d2=8,h=2); 
}

if(Backpanel) rotate([0,180,0])translate([-2,-2,-50]) {
 difference() {
  color("green")Balk(184,64,2,4);
  translate([6.2,6.2,-1]) cylinder(d=2.6,h=10);
  translate([184-6.2,6.2,-1]) cylinder(d=2.6,h=10);
  translate([184-6.2,64-6.2,-1]) cylinder(d=2.6,h=10);
  translate([6.2,64-6.2,-1]) cylinder(d=2.6,h=10);
  translate([6.2,6.2,-1]) cylinder(d=5,h=1.6);
  translate([184-6.2,6.2,-1]) cylinder(d=5,h=1.6);
  translate([184-6.2,64-6.2,-1]) cylinder(d=5,h=1.6);
  translate([6.2,64-6.2,-1]) cylinder(d=5,h=1.6);
  
  // USB-doorvoer
  translate([0,14,-1]) cube([3.6,5.4,10]);
  // Koelgaten
  hull() {
   translate([92-20,54,-1]) cylinder(d=2.2,h=10);
   translate([92+20,54,-1]) cylinder(d=2.2,h=10);
  }
  hull() {
   translate([92-30,48,-1]) cylinder(d=2.2,h=10);
   translate([92+30,48,-1]) cylinder(d=2.2,h=10);
  }
  hull() {
   translate([92-20,42,-1]) cylinder(d=2.2,h=10);
   translate([92+20,42,-1]) cylinder(d=2.2,h=10);
  }
 }
}

if(Doos) translate([-2,-2,-45]){
 difference() {
  color("green")Bak(184,64,40,2,4);
  translate([2,2,-3])Balk(180,60,10,4);
  
  // Gaatjes voor voetjes
 translate([10,4,6])rotate([90,0,0])cylinder(d=4,h=10);
 translate([184-10,4,6])rotate([90,0,0])cylinder(d=4,h=10);
 translate([14,4,32])rotate([90,0,0])cylinder(d=4,h=10);
 translate([184-14,4,32])rotate([90,0,0])cylinder(d=4,h=10);
 }
 translate([6.2,6.2,0])Pilaar(10,34);
 translate([184-6.2,6.2,0])Pilaar(10,34);
 translate([184-6.2,64-6.2,0])Pilaar(10,34);
 translate([6.2,64-6.2,0])Pilaar(10,34);  
}

module LCDFrame() { 
 difference() {
  union() {
   Frame(3);
   translate([0,0,-3]) {
    difference() {
     translate([0,0,1])Frame(2);
     translate([(80-72)/2+2,(36-25)/2,-1])cube([52,40,4]);
     translate([80-(80-72)/2-5,(36-25)/2+3,-1])cube([20,19,4]);      
    }
   }
  }//union 
  // 4 gaten
  translate([2.5,2.5,-3]) {       
   cylinder(d=3.4,h=5);
   translate([75,0,0])cylinder(d=3.4,h=5);
   translate([75,31,0])cylinder(d=3.4,h=5);
   translate([0,31,0])cylinder(d=3.4,h=5);
  }  
 }// diff
}

module Frame(H=4) {
 difference() {
  //cube([80,36,H]);
  Balk(80,36,H,2);
  // LCD zelf
  translate([(80-72)/2,(36-25)/2,-1])cube([72,25,20]);
 }
}//module Frame

module Cube(xdim ,ydim ,zdim,rdim=1) {
 hull(){
  translate([rdim,rdim,0])cylinder(h=zdim,r=rdim);
  translate([xdim-rdim,rdim,0])cylinder(h=zdim,r=rdim);
  translate([rdim,ydim-rdim,0])cylinder(h=zdim,r=rdim);
  translate([xdim-rdim,ydim-rdim,0])cylinder(h=zdim,r=rdim);
 }
}

if(Frontpanel) {
 difference() {  
  //cube([180,60,3]);
  Balk(180,60,3,4);
  //Cube(180,60,3);
  
  // Schroefgaten
  translate([4.2,4.2,-1]) cylinder(d=2.6,h=10);
  translate([180-4.2,4.2,-1]) cylinder(d=2.6,h=10);
  translate([180-4.2,60-4.2,-1]) cylinder(d=2.6,h=10);
  translate([4.2,60-4.2,-1]) cylinder(d=2.6,h=10);
  
  translate([4.2,4.2,1.6]) cylinder(d=5,h=10);
  translate([180-4.2,4.2,1.6]) cylinder(d=5,h=10);
  translate([180-4.2,60-4.2,1.6]) cylinder(d=5,h=10);
  translate([4.2,60-4.2,1.6]) cylinder(d=5,h=10);
      
  // Tuimelschakelaars  
  Tuimelschakelaar(105,40);    
  Tuimelschakelaar(105,25);
  Tuimelschakelaar(144,40);
  Tuimelschakelaar(144,25);  
  
  // LCD
  translate([0,-4,0])  translate([15,20,-1]) cube([72,25,10]);   
  translate([83,18,-3])cube([8,20,5]);
  translate([15,25,-3])cube([48,20,5]);
 
  // LCD gaten 
  translate([13.5,13.5,-1]) {
   cylinder(d=3.4,h=5);
   translate([75,0,0])cylinder(d=3.4,h=5);
   translate([75,31,0])cylinder(d=3.4,h=5);
   translate([0,31,0])cylinder(d=3.4,h=5);  
  }
 }
 
 translate([0,-4,0])
  color("grey")translate([11,14.5,2]) {
   difference() {
    LCDFrame();
   }
  }
 translate([11,52.4,3]) Txt("3D-Printer Monitor",5.2,"left");  
 
 translate([112,40,3]) Txt("MK3.9",5,"left");
 translate([112,25,3]) Txt("MK4",5,"left");
 translate([151,40,3]) Txt("MK4-2",5,"left");
 translate([151,25,3]) Txt("Mini",5,"left");
 
 // Schroefgaatjes
 //translate([(151+112)/2,15,3]) Txt("< Off | On >",3.8);
 //#translate([15+72/2,18,3]) Txt("________________",5.2);
 //#translate([15+72/2,15,3]) Txt("Prntr Temp. Cpl.",5.2);  
//#translate([17,50,3]) Txt("Filename",5.2,"left");  
 
}

module Tuimelschakelaar(X,Y) {
 translate([X,Y,-1]) cylinder(d=6,h=10);
 translate([X-5.8,Y,-1]) cylinder(d=2.8,h=3);
}

module Txt(t,size=4,halign="center") {
 color("grey") linear_extrude(height=0.6) 
  text(t,size=size,font="Bitstream Vera Sans Mono:style=Bold",
   valign="center",halign=halign);
}

include <polyround.scad>
// Holle 'Bak': L,B,H en muurdikte en radius
module Bak(L,B,H,Muurdikte=2,Radius=8) {
 P=[
  [0,0,Radius],
  [L,0,Radius],
  [L,B,Radius],
  [0,B,Radius]
 ];
 P2=[
  [0,0,Radius],
  [L-Muurdikte*2,0,Radius],
  [L-Muurdikte*2,B-Muurdikte*2,Radius],
  [0,B-Muurdikte*2,Radius]
 ];
 difference() {
  linear_extrude(height=H) 
   polygon(
    polyRound(P,30)
   );
  translate([Muurdikte,Muurdikte,Muurdikte])
  linear_extrude(height=H) 
   polygon(
    polyRound(P2,30)
   );
 }
}

module Balk(L,B,H,Radius=8) {
 P=[
  [0,0,Radius],
  [L,0,Radius],
  [L,B,Radius],
  [0,B,Radius]
 ];
 linear_extrude(height=H) 
  polygon(
   polyRound(P,30)
  );  
}

module Pilaar(W=10,H=40) {
 difference() {
  cylinder(d=W,h=H);
  translate([0,0,H-4]) cylinder(d=3.2,h=5);
  translate([0,0,-1]) cylinder(d=3.2,h=5);
 }
}