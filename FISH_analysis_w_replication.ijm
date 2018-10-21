var Lclick=false;
var Rclick=false;
var sphase=false;
function reset_butts() {
	Lclick=false;
	Rclick=false;
	sphase=false;
}
function measure_FISH(x,y,channel){
	probe="NA";
	makeOval(x, y, width, height);
	channel++;
	text="duplicate channels="+channel;
	run("Duplicate...", text);
	if (gaus) run("Gaussian Blur...", "sigma=1.5");
	getRawStatistics(nPixels, mean, min, max); 
	setAutoThreshold("Minimum dark");
	//run("Threshold...");
	setThreshold(max/2, max);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	b=nResults;//number of results before
	run("Analyze Particles...", "display");
	a=nResults;//number of results after
	if (channel==3) probe="Biotin";
	if (channel==4) probe="DIG";
	for (i=b+1;i<=a;i++){
		setResult("Probe", i-1, probe);
		setResult("S-Phase", i-1, sphase);
		updateResults();
	}
	close();
}

shift=1;
ctrl=2; 
rightButton=4;
alt=8;
leftButton=16;
insideROI = 32; // requires 1.42i or later

x2=-1; y2=-1; z2=-1; flags2=-1;
getPixelSize(unit, pixelWidth, pixelHeight); 
var radius=150;
var gaus=false;
var height;
var width;
Dialog.create("Settings"); 
Dialog.addNumber("Set radius of circle", radius);
Dialog.addCheckbox("Gaussian blur", gaus);
Dialog.show(); 
radius = Dialog.getNumber();
gaus = Dialog.getCheckbox();
height = 2*pixelHeight*radius; 
width = 2*pixelWidth*radius; 
logOpened = false;
//reset_butts();

if (getVersion>="1.37r")
  setOption("DisablePopupMenu", true);
print("let's begin");
if(gaus) 
	print("Gaussian blur is on");
else
	print("Gaussian blur is off");
while (!logOpened || isOpen("Log")) {
  getCursorLoc(x, y, z, flags);
  if (x!=x2 || y!=y2 || z!=z2 || flags!=flags2) {
  	x = x - width/2; 
    y = y - height/2;
	if (flags&leftButton!=0) Lclick=true;
    if (flags&rightButton!=0) Rclick=true;
    if (flags&shift!=0) sphase=true;
    //if (flags&ctrl!=0) s = s + "<ctrl> ";
    //if (flags&alt!=0) s = s + "<alt>";
    //if (flags&insideROI!=0) s = s + "<inside>";
    //print(x+" "+y+" "+z+" "+flags);
    if (Lclick&sphase){
    	print("Sphase");
      	measure_FISH(x,y,z);
      	}
      if (Lclick& !sphase){
      	print("G1");
      	measure_FISH(x,y,z);
      }
      logOpened = true;
      startTime = getTime();
  }
  reset_butts();
  x2=x; y2=y; z2=z; flags2=flags;
  wait(10);
}
if (getVersion>="1.37r")
  setOption("DisablePopupMenu", false);