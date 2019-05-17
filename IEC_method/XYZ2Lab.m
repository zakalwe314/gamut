
function [Lab] = XYZ2Lab(XYZ,XYZn)

%create output same size as input

Lab = zeros(size(XYZ));

%create ratio matrix

ratio = diag(1./XYZn)*XYZ;

%calculate f(X/Xn),f(Y/Yn),f(Y/Yn)

fX = ratio.^(1/3);
idx = find(ratio <= 0.008856);
fX(idx) = ratio(idx).*7.787 + (16/116);

%calculate L*,a*,b*

Lab(1,:) = 116*fX(2,:)-16;
Lab(2,:) = 500*(fX(1,:)-fX(2,:));
Lab(3,:) = 200*(fX(2,:)-fX(3,:));
















