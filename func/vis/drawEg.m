%# This script is to draw edges providing two sets of coordinates

function [] = drawEg(xy1, xy2)

    xx = [xy1(:,1) xy2(:,1)];
    yy = [xy1(:,2) xy2(:,2)];
    plot(xx',yy');

end