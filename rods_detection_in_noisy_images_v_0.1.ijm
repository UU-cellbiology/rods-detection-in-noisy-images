print("rods detection in noisy images (version 0.1)");
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
Dialog.addNumber("Intensity threshold (in noise SD, around 3-7)", 4.5);
Dialog.addCheckbox("Show rejected detections in overlay", false);
Dialog.show();


//average rod length in pixels
line_length=Dialog.getNumber();
psf_width  =Dialog.getNumber();
dAngleStep =Dialog.getNumber();
SD_Threshold=Dialog.getNumber();
bAddtoOverlay=Dialog.getCheckbox();

//width of line removal from correlation map
remove_scale_width=5*psf_width;

//clear everything
roiManager("reset");
run("Clear Results");

if(bAddtoOverlay)
	{run("Remove Overlay");}



i=0;
line_length_remove=line_length*1.8;

setBatchMode(true);

currimagename=getTitle();
imageID=getImageID();
nSlicesOrig=nSlices;
//let's go through slices
for(nSl=1;nSl<=nSlicesOrig;nSl++)
{
	bMaskMade=false;
	selectImage(imageID);
	setSlice(nSl);
	print("Slice="+toString(nSl));
	//each orientation of the rod
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
		//one image of correlation remains unchanged
		//and called corr_fit_ID. It is used for fitting
		//along perpendicular direction to estimate width 
		corr_fit_ID=getImageID();
		run("Duplicate...", " ");
		//this correlation map image is used
		//to find maximum correlation value
		//remove it, find next, etc
		corrID=getImageID();
		imw=getWidth();
		imh=getHeight();
		
		//get intensity threshold value on correlation map
		getStatistics(area, mean, min, max, std);
		threshold = mean+SD_Threshold*std;
		
		//do we already have mask image? if not, make one
		if(!bMaskMade)
		{
			//make a map of detected lines
			//containing information on detections positions
			newImage("lines_mask"+toString(nSl), "RGB black", imw,imh, 1);
			
			mapID=getImageID();
			bMaskMade=true;
			selectImage(corrID);
		}
		
		//coordinates of line along template direction
		x1=line_length*0.5*sin(angle_rad);
		y1=line_length*0.5*cos(angle_rad);
		x2=-x1;
		y2=-y1;
		
		//line removal from correlation map		
		x1_r=line_length_remove*0.5*sin(angle_rad);
		y1_r=line_length_remove*0.5*cos(angle_rad);
		x2_r=-x1_r;
		y2_r=-y1_r;
		
		//half width/height of template image
		temp_half=0.5*round(line_length+psf_width*8);
		
		//perpendicular line for fitting and estimating line width at correlation map
		angle_p = angle+90;
		angle_p_rad=angle_p*PI/180;
		x1_p=psf_width*6*sin(angle_p_rad);
		y1_p=psf_width*6*cos(angle_p_rad);
		x2_p=-x1_p;
		y2_p=-y1_p;
				
		setForegroundColor(0, 0, 0);					
		bCont=true;						
		//cycle through maximums of correlation image:
		//maximum is detected then "template line" image
		//is removed (zeroed) from that location and
		//loop is looking for the next maximum
		while(bCont)
		{
			
			//finding maxima on correlation image	
			selectImage(corrID);
			makeRectangle(0, 0, imw, imh);
	  	    getStatistics(area, mean, min, max);
		   
		   
		   	run("Find Maxima...", "noise="+max+" output=[Point Selection]"); 		   
		   	getSelectionBounds(x, y, w, h); 

		   	//fitting intensity profile in perpendicular direction
		   	selectImage(corr_fit_ID);		    
		    makeLine(x1_p+x, y1_p+y, x2_p+x, y2_p+y);
		    profile = getProfile();
		    selectImage(corrID);
		    xfitvals= newArray(profile.length);
		    for(j=0;j<profile.length;j++)
		   		{xfitvals[j]=j;}		   	
		   	initialGuesses=newArray(max,mean,profile.length*0.5,psf_width*2.0);
			Fit.doFit("Gaussian", xfitvals, profile,initialGuesses);

			//estimate width from fitting
			//in case fitting provided some meaningful results
			if(Fit.p(3)<10*psf_width)
			{
				//in case width is too small
				if(Fit.p(3)<psf_width)
					remove_line_width=remove_scale_width;
				else
				   remove_line_width=5*Fit.p(3);
			}
			else
			{
				remove_line_width=remove_scale_width;
			}
			setForegroundColor(0, 0, 0);
			
		   //remove detected line from correlation plot
		   makeLine(x1_r+x, y1_r+y, x2_r+x, y2_r+y, remove_line_width);
		   run("Fill", "slice");

		   //nStatus describes detected line
		   nStatus=0;
		   // 0 = freshly detected line without conflicts (rendered in green in overlay and added to ROI Manager)
		   // 1 = line detected at position, where better line was detected before (rendered in blue in overlay)
		   // 2 = line, where next detection is better (rendered in red)
		   //some leftover, for the future
		   if(Fit.p(3)<psf_width*3.0 && Fit.rSquared>0.7)
		   {
		   	//nStatus=10;
		   }
		   
			//check the current pixel is occupied by line already
			selectImage(mapID);
			mapval=getPixel(x, y);
			v=mapval;
			red = (v>>16)&0xff;  // extract red byte (bits 23-17)
			green = (v>>8)&0xff; // extract green byte (bits 15-8)
			blue = v&0xff;
			mapval=((red << 16) + (green << 8) + blue);
	
			// it is already occupied by previous detection
			if(mapval>0)
			{
				//get value of correlation for previous detection
				occ_corr=getResult("correl", mapval-1);
				//previous is bigger (better)! keep it and mark current detection with nStatus=1;
				if(occ_corr>max)
				{
					nStatus=1;
				}
				//previous detection is worse!
				//mark it with nStatus=2 in Results table
				else
				{
					setResult("status",mapval-1,2);
					setResult("mapval",mapval-1,i+1);
				}
			}
			//add line to map image
			//only if it has nStatus 0, i.e. "freshly" detected
			//and not overlapped
			if (nStatus<1)
			{
				v=i+1;
				red = (v>>16)&0xff;  // extract red byte (bits 23-17)
				green = (v>>8)&0xff; // extract green byte (bits 15-8)
				blue = v&0xff;
				setForegroundColor(red, green, blue);				
				makeLine(x1_r+x, y1_r+y, x2_r+x, y2_r+y, remove_line_width);
		    	run("Fill", "slice");		    	
			}
		   	selectImage(corrID);
		   	
		   	//correlation map image dimensions are different
		   	//than original image dimensions, taking this into account
		   	x_image=x+temp_half; y_image=y+temp_half;

			//add detection to results table
		   	setResult("X_corr_coord(px)", i, x);
		   	setResult("Y_corr_coord(px)", i, y);
		   	setResult("X_image_coord(px)", i, round(x_image));
		   	setResult("Y_image_coord(px)", i, round(y_image));
		   	setResult("correl", i, max);
		   	setResult("angle(degrees)", i, angle);
		   	setResult("fit_SD_corr(px)", i,Fit.p(3));
		   	setResult("fit_R2", i,Fit.rSquared);
		   	setResult("mapval",i,mapval);
		   	setResult("status",i,nStatus);
		   	setResult("Slice",i,nSl);
		   	
		   	i++;
			
			//continue to the next maximum,
			//unless it is less than a threshold
		   	if(max<threshold)
		   		{bCont=false;}
		
		}
		//close correlation and fit images		   	
		selectImage(corrID);
		close();
		selectImage(corr_fit_ID);
		close();
		//close template		
		selectImage(templateID);
		close();
	
	}
	//map was used for current slice
	//and possible orientations, no need anymore
	selectImage(mapID);
	close();
	//update results every 50 slides, just in case something goes wrong
	if(nSl%50==0)
	{
		updateResults();

		//optional saving of intermediate results,
		//uncomment if needed
		/*
		selectWindow("Results");
		fileResultsString="D:\\Eugene\\Light_induced_motor\\20180112_gliding_assay_patterning\\s01_nd4_40x_on@51-100@301-400@551-650-global-local-horizon_1\\Results_149_400_f"+toString(nSl)+".csv";
		saveAs("Results", fileResultsString);
		*/
	}
}
//go back to original image
selectImage(imageID);
//add ROIs
addROIs(line_length,bAddtoOverlay);
setBatchMode(false);

function addROIs(line_length,bAddtoOverlay)
{
	x_coords=newArray(nResults);
	y_coords=newArray(nResults);
	angles=newArray(nResults);
	statuses=newArray(nResults);
	slices=newArray(nResults);
	//read results
	for(i=0;i<nResults;i++)
	{
		x_coords[i]=getResult("X_image_coord(px)",i);
		y_coords[i]=getResult("Y_image_coord(px)",i);
		angles[i]=getResult("angle(degrees)",i);
		statuses[i]=getResult("status",i);
		slices[i]=getResult("Slice",i);
		
	}
	//add ROIs
	roiManager("reset");
	nTrueDetections=0;
	for(i=0;i<nResults;i++)
	{
		angle_rad=angles[i]*PI/180;
		//line along direction
		x1=line_length*0.5*sin(angle_rad);
		y1=line_length*0.5*cos(angle_rad);
		x2=-x1;
		y2=-y1;
		x1+=x_coords[i];
		x2+=x_coords[i];
		y1+=y_coords[i];
		y2+=y_coords[i];
		setSlice(slices[i]);
		
		makeLine(x1, y1, x2, y2);
		if(statuses[i]==0)
		{
			roiManager("add");	
			nTrueDetections++;
			setResult("ROI_Number",i,nTrueDetections);
			if(bAddtoOverlay)
				Overlay.addSelection("green");			
		}
		if(bAddtoOverlay)
		{
			if(statuses[i]==1)
				Overlay.addSelection("blue");
			if(statuses[i]==2)
				Overlay.addSelection("red");
		   	Overlay.setPosition(slices[i]);
		}
	}
	
}

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

   