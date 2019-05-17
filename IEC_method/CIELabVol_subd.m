CIELabVol_subd.m

function [v] = CIELabVol_subd(P)
%Each row of P contains XYZ tri-stimulus values of gamut corner points.
%The 3D gamut is defined as the convex hull of these points in XYZ space.
%The surface is recursively subdivided down to a threshold scale in CIELAB
%and the volume made by each surface tile to a central point is summed

thresh=10; %CIELab subdivision threshold

%Get the hull defined by the points
T=convhulln(P);

%Get the white point (taken as the primary with the maximum Y)
[W,i]=max(P(:,2));
W=P(i,:);

%Normalise the gamut to the white point
Pn=P./(repmat(W,size(P,1),1));

%get the mid-point
Pm=mean(Pn);

%add-on the CIELab points
Pn=[Pn, XYZ2Lab(Pn)];
Pm=[Pm, XYZ2Lab(Pm)];

%calculate and sum the Lab volume of each surface tile to the mid-point
v=0;
for n=1:size(T,1),
　　　　　v=v+SubDLabVol(Pn(T(n,:),:),Pm,thresh);
end

%% sub-functions
% XYZ2Lab converts XYZ values arranged in columns to L* a* b*
　　　　　function [ t ] = XYZ2Lab( t )
　　　　　i=(t>0.008856);
　　　　　t(i)=t(i).^(1/3);
　　　　　t(~i)=7.787*t(~i)+16/116;
　　　　　t=[116*t(:,2)-16, 500*(t(:,1)-t(:,2)), 200*(t(:,2)-t(:,3))];
　　　　　end

%Recursive function to devide up the surface tile then return the volume
　　　　　function [ v ] = SubDLabVol( vp,c,th )
　　　　　　　　　　%Get the max extent of each edge (quicker than length calculation)
　　　　　　　　　　m=max(abs(vp-circshift(vp,1)),[],2);
　　　　　　　　　　%Count how many edges have extents larger than the threshold
　　　　　　　　　　s=sum(m>th);

　　　　　　　　　　if (s==0), %no edges larger: return the volume
　　　　　　　　　　　　　　　v=abs(det(vp(:,4:6) - repmat(c(1,4:6),3,1))/6);

　　　　　　　　　　elseif (s==3),%all edges larger: divide tile in four
　　　　　　　　　　　　　　　%get edge mid-points
　　　　　　　　　　　　　　　ip=(vp(:,1:3)+circshift(vp(:,1:3),1))/2;
　　　　　%calculate CIELab points of the mid-points
　　　　　　　　　　　　ip=[ip,XYZ2Lab(ip)];
　　　　　%and call recursively for each sub-tile
　　　　　　　　　　　　v=SubDLabVol([vp(1,:);ip(1:2,:)],c,th);
　　　　　　　　　　　　v=v+SubDLabVol([vp(2,:);ip(2:3,:)],c,th);
　　　　　　　　　　　　v=v+SubDLabVol([vp(3,:);ip(1:2:3,:)],c,th);
　　　　　　　　　　　　v=v+SubDLabVol(ip,c,th);

　　　　　else %one or two edges larger: split the tile on the largest edge
　　　　　　　　　　　　%shift the order so 1-2 has the largest extent
　　　　　　　　　　　　[m,i]=max(m);
　　　　　　　　　　　　vp=circshift(vp,2-i);

　　　　　　　　　　　　%calculate the mid-point of 1-2 and the CIELab point
　　　　　　　　　　　　ip=(vp(1,1:3)+vp(2,1:3))/2;
　　　　　　　　　　　　ip=[ip,XYZ2Lab(ip)];

　　　　　　　　　　　　%and call recursively for the two sub-tiles
　　　　　　　　　　　　v=SubDLabVol([vp([1 3],:);ip],c,th);
　　　　　　　　　　　　v=v+SubDLabVol([vp(2:3,:);ip],c,th);
　　　　　　　　end
　　　　end
end
