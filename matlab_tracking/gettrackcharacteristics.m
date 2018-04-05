%function calculating parameters of track
function obj = gettrackcharacteristics(track)

    n_of_points = length(track);
    velocities = zeros(n_of_points-1,3);
    directions = zeros(n_of_points-2,1);        
    timeintervals =  diff(track(:,1));
    
    %velocity component along x and y
    tempdir(:,1) = diff(track(:,2));
    tempdir(:,2) = diff(track(:,3));

    displacements = sqrt(tempdir(:,1).^2 + tempdir(:,2).^2);
    displacementscum = cumsum(displacements);
    velocities(:,1) = tempdir(:,1)./timeintervals;
    velocities(:,2) = tempdir(:,2)./timeintervals;
    %magnitude of velocity (speed)
    for j=1:n_of_points-1
        velocities(j,3) = sqrt(velocities(j,1)*velocities(j,1)+velocities(j,2)*velocities(j,2));
    end
    %cosine of the angle
    for j=1:n_of_points-2
        directions(j)=(velocities(j,1)*velocities(j+1,1)+velocities(j,2)*velocities(j+1,2))/(velocities(j+1,3)*velocities(j,3)); 
    end
    obj=struct('displacements', displacements,...
        'displacementscum', displacementscum,...
        'velocities', velocities,...
        'timeintervals', timeintervals,...
        'directions', directions,...
        'n_of_points', n_of_points);
%        'timeintervals', timeintervals,...
 %       'timeintervals', timeintervals,...
    %);
end