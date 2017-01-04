%# calculate distances between two sets of coordinates

function d=distance(n1,n2)    
    n1_update = n1;
    if(size(n1,1) < size(n2,1))
        n1_update = repmat(n1,[size(n2,1),1]);
    end

    n=n1_update-n2;
    d=n(:,1).^2+n(:,2).^2;
    d=sqrt(d);
return