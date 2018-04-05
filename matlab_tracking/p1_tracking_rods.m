%% rods tracking Matlab routine
% by Eugene Katrukha, email katpyxa@gmail.com for any questions
% makes tracks from rods detection by ImageJ macro
% requires modified simple tracker routine folder SimpleTrackerOrient
%(add to path -> selected folder)
%
% Original Simple Tracker by Jean-Yves Tinevez is available here
% https://nl.mathworks.com/matlabcentral/fileexchange/34040-simple-tracker
%
% requires exportToMTrackJ function


%% parameters

%weight of angle difference
global coeff_angle;
coeff_angle=0.3;

%maximum distance between detections (including angle difference with weight specified above) 
max_linking_distance=22;

%maximum gap in frames to close between "missed" detections
max_gap_closing=1;

%reaf results file from 'rods_detection_in_noisy_images.ijm' macro
[filename,path] = uigetfile('*.*','Select output of rods detection');


dataraw=importdata(strcat(path,filename));

dataxy=dataraw.data;
%filter out bad detections
filtAdd=dataxy(:,11)<1;
dataxy=dataxy(filtAdd,:);

%creating input for SimpleTracker
maxFrame=max(dataxy(:,12));
points= cell(maxFrame, 1); 
for(i=1:maxFrame)
    filtFrame=dataxy(:,12)==i;
    %orientation angle comes with weight
    points{i,1}=horzcat(dataxy(filtFrame,4:5),coeff_angle*dataxy(filtFrame,7));
    
end


%linking
disp('linking');

%'NearestNeighbor' method by default
[ tracks adjacency_trackscol ] = simpletracker(points,...                       
            'MaxLinkingDistance', max_linking_distance, ...
            'MaxGapClosing', max_gap_closing);


n_tracks = numel(tracks);        
all_points = vertcat(points{:});
trackfin={};
nTotTrackN=0;
for i_track = 1 : n_tracks
    
    track = adjacency_trackscol{i_track};
    track_points = all_points(track, :);
    %add time
    timepoints=tracks{i_track,1}*0;
    timepoints=timepoints+(1:maxFrame)';
    filt=~isnan(timepoints);
    timepoints=timepoints(filt);
    if(numel(timepoints)>2)
         nTotTrackN=nTotTrackN+1;
         trackfin{nTotTrackN,1}=horzcat(timepoints,track_points);
    end
end   
% }
disp('saving');
exportToMTrackJ(trackfin, strcat(path,filename,'_tracks.mdf'),1);
disp('done');