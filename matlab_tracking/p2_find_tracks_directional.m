%% find tracks with directional segments Matlab routine
% by Eugene Katrukha, email katpyxa@gmail.com for any questions
%
% must be run only after 'p1_tracking_rods.m' script is executed
%
% saves tracks in the same folder to MTrackJ ImageJ plugin format 
% for visualization (with '_tracks2color.mdf' suffix)
% https://imagescience.org/meijering/software/mtrackj/
% 
% tracks containing directional runs are saved to cluster 1 with red trajectories
% tracks containing directional runs are saved to cluster 2 with yellow trajectories
%
% requires exportToMTrackJ2color, filterbydirection,gettrackcharateristics functions

%% parameters
% orientation threshold (min cosine of angle between two consecutive
% displacements)
threshold = 0.6;
%displacement threshold (px)
dDisplThresh = 10;
%sequence threshold in frames
nSeqTreshold = 6;

%% reorder tracks after SimpleTracker
tracks=cell(numel(trackfin),1);
for i_track = 1 : numel(trackfin)
    tracks{i_track ,1}=trackfin{i_track,1}(:,1:3);
end

%%find directional runs in tracks

trackschar = {};
tracksfilt = {};

for i=1:length(tracks)
	trackschar{i} = gettrackcharacteristics(tracks{i}); 
	tracksfilt{i} = filterbydirection(trackschar{i},threshold,dDisplThresh,nSeqTreshold);
end

nTracksWithRuns=0;
nTotalRunsNumber=0;
runTracksindex=[];
for i=1:length(tracks)
	if(tracksfilt{i}.runsnumber>0) 
        nTracksWithRuns=nTracksWithRuns+1;
        runTracksindex=vertcat(runTracksindex,i);
        nTotalRunsNumber=nTotalRunsNumber+tracksfilt{i}.runsnumber;
    end
end

exportToMTrackJ2color( trackfin,  strcat(path,filename,'_tracks2color.mdf'),1,runTracksindex);