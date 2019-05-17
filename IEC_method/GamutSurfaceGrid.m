% Progarm:  GamutSurfaceGrid.m
% To select points on the gamut surface from
% a uniform subdivision of the RGB cube.
% Level selection rounded.
 
clear all
clc
m = 25; 				% number of points along gamut edge 
wht = 255; 			% maximum level assuming zero minimum
a = round(linspace(0,wht,m)); 	% levels along RGB edges
R=a ; G=a ; B=a; 			% define RGB levels
n=1;
for i=1:m; 			% G-C-B-K surface
    for j=1:m;
        Q(n,1:3)=[0,G(i),B(j)];
        n=n+1;
    end
end
for i=2:m; 			% R-M-B-K surface
    for j=1:m;
        Q(n,1:3)=[R(i),0,B(j)];
        n=n+1;
    end
end
for i=2:m; 			% R-Y-G-K surface
    for j=2:m;
        Q(n,1:3)=[R(i),G(j),0];
        n=n+1;
    end
end
for i=2:m; 			% G-Y-W-C surface
    for j=2:m;
        Q(n,1:3)=[R(i),G(m),B(j)];
        n=n+1;
    end
end
for i=2:m-1; 			% R-M-W-Y surface
    for j=2:m;
        Q(n,1:3)=[R(m),G(i),B(j)];
        n=n+1;
    end
end
for i=2:m-1; 			%B -C-W-M surface
    for j=2:m-1;
        Q(n,1:3)=[R(i),G(j),B(m)];
        n=n+1;
    end
end
S=sortrows(Q);
S %Colors on the surface of the gamut
disp(['Number of colors on gamut surface:  '...
    , num2str(size(S,1))])
