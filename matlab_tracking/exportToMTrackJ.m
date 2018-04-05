function [ output_args ] = exportToMTrackJ( tracks, filename,nPixelSize )
% export cell array of tracks to MTrackJ file format
% tracks are assumed to be in um or nm, nPixelSize
% is used to convert them back to the pixel coordinates (used by MTrackJ)
fileID = fopen(filename,'w');
fprintf(fileID, 'MTrackJ 1.5.1 Data File\n');
fprintf(fileID,'Displaying true true true 1 1 0 0 30 2 0 0 0 2 1 0 0 false true false false\n');
fprintf(fileID,'Assembly 1 FF0000\n');
fprintf(fileID,'Cluster 1 0096FF\n');
for(i=1:length(tracks))
    fprintf(fileID,'Track %d FF0000 true\n',i);
    sz=size(tracks{i,1});
    for(j=1:sz(1))
        fprintf(fileID,'Point %d %.1f %.1f 1.0 %.1f 1.0\n',j,tracks{i,1}(j,2)/nPixelSize,tracks{i,1}(j,3)/nPixelSize,tracks{i,1}(j,1));
    end
end
fprintf(fileID,'End of MTrackJ Data File');
end

 
