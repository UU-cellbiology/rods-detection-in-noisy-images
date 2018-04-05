function [ output_args ] = exportToMTrackJ2color( tracks, filename,nPixelSize, color_array)
% Exports cell array of tracks to MTrackJ file format.
% Tracks are assumed to be in um or nm, nPixelSize
% is used to convert them back to the pixel coordinates (used by MTrackJ).
% color_array array contains indexes of tracks with directional segments,
% which are saved to cluster 1 with red color.
% The rest of tracks are saved as cluster 2 with yellow color

fileID = fopen(filename,'w');
fprintf(fileID, 'MTrackJ 1.5.1 Data File\n');
fprintf(fileID,'Displaying true true true 1 1 0 0 30 2 0 0 0 2 1 0 0 false true false false\n');
fprintf(fileID,'Assembly 1 FF0000\n');
fprintf(fileID,'Cluster 1 0096FF\n');
nTotTrackIndex=0;
for(i=1:length(tracks))
    if(sum(color_array==i)>0)
        nTotTrackIndex=nTotTrackIndex+1;
            fprintf(fileID,'Track %d FF0000 true\n',nTotTrackIndex);

        sz=size(tracks{i,1});
        for(j=1:sz(1))
            fprintf(fileID,'Point %d %.1f %.1f 1.0 %.1f 1.0\n',j,tracks{i,1}(j,2)/nPixelSize,tracks{i,1}(j,3)/nPixelSize,tracks{i,1}(j,1));
        end
    end
end
nTotTrackIndex=0;
fprintf(fileID,'Cluster 2 0096FF\n');
for(i=1:length(tracks))
    if(sum(color_array==i)==0)
        nTotTrackIndex=nTotTrackIndex+1;
            fprintf(fileID,'Track %d FF0000 true\n',nTotTrackIndex);

        sz=size(tracks{i,1});
        for(j=1:sz(1))
            fprintf(fileID,'Point %d %.1f %.1f 1.0 %.1f 1.0\n',j,tracks{i,1}(j,2)/nPixelSize,tracks{i,1}(j,3)/nPixelSize,tracks{i,1}(j,1));
        end
    end
end
fprintf(fileID,'End of MTrackJ Data File');
end

 
