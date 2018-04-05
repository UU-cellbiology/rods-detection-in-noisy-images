print("rods enhancement in noisy images (version 0.1)");
nBitDepth=bitDepth();
if(nBitDepth>16)
{
	exit("The macro works only with 8- or 16-bit images, sorry.") ;
}
// dialog with detection parameters
Dialog.create("Detection parameters");
Dialog.addNumber("Average rod length (px)", 24);
Dialog.addNumber("Rod width (SD of PSF, px)", 1.2);
Dialog.addNumber("Template angle step (degrees)", 30);
items=newArray("Max Intensity","Average Intensity","Min Intensity","Sum Slices","Standard Deviation","Median");
Dialog.addChoice("Correlation stack projection type", items) 
//Dialog.addNumber("Intensity threshold (in noise SD, around 3-7)", 4.5);
//Dialog.addCheckbox("Show rejected detections in overlay", false);
Dialog.show();


//average rod length in pixels
line_length=Dialog.getNumber();
psf_width  =Dialog.getNumber();
dAngleStep =Dialog.getNumber();
sProjType  =Dialog.getChoice();

//width of line removal from correlation map
remove_scale_width=5*psf_width;

//calculate number of orientations
nOrientationsN=0;
for(angle=0;angle<180;angle+=dAngleStep)	
	nOrientationsN++;

i=0;


setBatchMode(true);

currimagename=getTitle();
imageID=getImageID();
nSlicesOrig=nSlices;
bSliceStackMade=false;
//let's go through slices
for(nSl=1;nSl<=nSlicesOrig;nSl++)
{
	
	selectImage(imageID);
	setSlice(nSl);
	print("Slice="+toString(nSl));
	bAngleCCStackCreated=false;
	//each orientation of the rod
	i=1;
	for(angle=0;angle<180;angle+=dAngleStep)	
	{
		print("angle="+toString(angle));
		angle_rad=angle*PI/180;
		
		//make template image 		
		generateLineImage(line_length, angle, psf_width);
		templateID=getImageID();
		//calculate correlation map
		runstring="image=["+currimagename+"] method=[Normalized cross correlation] template=angle_template show tolerence=0.10 threshold=0";
		run("cvMatch_Template...", runstring);
	
		corrID=getImageID();
		run("Select All");
		run("Copy");
		imwCC=getWidth();
		imhCC=getHeight();
		if(!bAngleCCStackCreated)
		{
			newImage("orientationCC", "32-bit grayscale-mode", imwCC, imhCC, 1, nOrientationsN, 1);
			orientationStackID=getImageID();
			bAngleCCStackCreated=true;
		}
		selectImage(orientationStackID);
		setSlice(i);
		run("Paste");
		//close correlation and fit images		   	
		selectImage(corrID);
		close();
		//close template		
		selectImage(templateID);
		close();
		i++;
	
	}
	selectImage(orientationStackID);
	runstring="projection=["+sProjType+"]";
	run("Z Project...", runstring);
	projID=getImageID();
	selectImage(orientationStackID);
	close();
	selectImage(projID);
	run("Select All");
	run("Copy");
	if(!bSliceStackMade)
	{
		bSliceStackMade=true;
		Filter_stackName=currimagename+"_filtered_"+sProjType;
		newImage(Filter_stackName, "32-bit grayscale-mode", imwCC, imhCC, 1, nSlicesOrig, 1);
		filtStackID=getImageID();
	}
	selectImage(filtStackID);
	setSlice(nSl);
	run("Paste");
	selectImage(projID);
	close();
}
setBatchMode(false);
selectImage(filtStackID);

function generateLineImage(line_length, angle, psf_width) {
	//line_length = 23;
//angle = 30;
angle_rad=angle*PI/180;
//psf_width = 1.0;

temp_W=round(line_length+psf_width*8);
temp_H=round(line_length+psf_width*8);
if(nBitDepth==16)
	newImage("angle_template", "16-bit black", temp_W,temp_H, 1);
else
	newImage("angle_template", "8-bit black", temp_W,temp_H, 1);
center_x=temp_W*0.5;
center_y=temp_H*0.5;

x1=line_length*0.5*sin(angle_rad);
y1=line_length*0.5*cos(angle_rad);

x2=-x1;
y2=-y1;
x1+=center_x;
y1+=center_y;
x2+=center_x;
y2+=center_y;

makeLine(round(x1), round(y1), round(x2), round(y2),1);
setForegroundColor(255, 255, 255);
run("Fill", "slice");
setForegroundColor(0, 0, 0);
stringact="sigma="+toString(psf_width);
run("Gaussian Blur...", stringact);
run("Add Noise");

}
