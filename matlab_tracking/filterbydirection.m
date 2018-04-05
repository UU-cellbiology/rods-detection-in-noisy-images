function obj = filterbydirection(trackcharact, nCosThreshold, dDisplThresh, nSeqTreshold)

    if(~isstruct(trackcharact))
        error('please provide track characteristics');
    end
   
    ffilter=trackcharact.directions>nCosThreshold;
    filter_marks=zeros(trackcharact.n_of_points,1);
    
    dsig = diff( vertcat(0,ffilter,0));
    startIndex = find(dsig > 0);
    endIndex = find(dsig < 0)-1;
    duration = endIndex-startIndex+1;


    %filtering by number of points in the sequence
    durationfilter = (duration >= nSeqTreshold);
    startIndex = startIndex(durationfilter);
    endIndex = endIndex(durationfilter);
    duration = duration(durationfilter)+1;
    runs_displacements = zeros(numel(duration),1);
    runsnumber = length(startIndex);

    %filtering on displacements
    for i=1:runsnumber    
        runs_displacements(i)=sum(trackcharact.displacements(startIndex(i):endIndex(i)+1));        
    end
    filter_displ = runs_displacements>=dDisplThresh;
    runs_displacements = runs_displacements(filter_displ);
    
    vel_runs_instant = [];
    vel_runs_average = [];
    runs_durations = [];
    vel_avrg_direction = [];
    begin_index=[];
    end_index=[];
    for i=1:runsnumber    
        if(filter_displ(i))
            vel_runs_instant = vertcat(vel_runs_instant,trackcharact.velocities(startIndex(i):endIndex(i)+1,3));   
            vel_runs_average = vertcat(vel_runs_average,mean(trackcharact.velocities(startIndex(i):endIndex(i)+1,3)));  
            %vel_runs_average = vertcat(vel_runs_average,mean(trackcharact.velocities(startIndex(i)+1:endIndex(i),3)));  
            vel_avrg_direction = vertcat(vel_avrg_direction,horzcat(mean(trackcharact.velocities(startIndex(i):endIndex(i)+1,1)), ...
                mean(trackcharact.velocities(startIndex(i):endIndex(i)+1,2))));
            runs_durations   = vertcat(runs_durations,sum(trackcharact.timeintervals(startIndex(i):endIndex(i)+1)));   

            begin_index = vertcat(begin_index,startIndex(i)+1);
            end_index = vertcat(end_index,endIndex(i)+1);
            filter_marks(startIndex(i)+1:endIndex(i)+1)= 1;            
        end
    end   
    runsnumber = sum(filter_displ);
    
    obj=struct('vel_runs_instant', vel_runs_instant,...
        'vel_runs_average', vel_runs_average,...
        'vel_avrg_direction', vel_avrg_direction,...
        'runs_durations', runs_durations,...
        'runsnumber', runsnumber,...
        'runs_displacements', runs_displacements,...
        'filter_marks', filter_marks,...
        'begin_index', begin_index,...
        'end_index', end_index,...
        'nCosThreshold', nCosThreshold,...                
        'dDisplThresh', dDisplThresh,...                
        'nSeqTreshold', nSeqTreshold);
    
end