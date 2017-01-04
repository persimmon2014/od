%# This script is to check the type of a highway. If the type is of one of the types we are addressing, return its numerical index.


function typeIdx = checkHighwayType(type)

    %# specify types of highway we are going to address
    highway = {'motorway', ...      % 1
               'trunk', ...         % 2
               'primary', ...       % 3
               'secondary', ...     % 4
               'tertiary', ...      % 5
               'unclassified', ...  % 6
               'residential', ...   % 7
               'motorway_link', ... % 8
               'trunk_link', ...    % 9
               'primary_link', ...  % 10
               'secondary_link', ...% 11
               'tertiary_link'};    % 12
    typeIdx = -1;
           
    for i = 1:length(highway)
        if(strcmp(type, highway(i)) == 1)
            typeIdx = i;
            break;
        end
    end

end