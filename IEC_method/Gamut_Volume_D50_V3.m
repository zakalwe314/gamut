% clc
% clear
% close all

Folder='iec_data';
File='bt2020_CR1305_D50_602';

D50=[96.42957  100.0000  82.51046]/100;

Header=read_header(Folder,File,22);

Data=read_data(Folder,File,22,3460);

RGB=[Data{2} Data{3} Data{4}];                  
XYZ=[Data{5} Data{6} Data{7}];

IX=find(RGB(:,1)==255&RGB(:,2)==255&RGB(:,3)==255);
XYZn=XYZ(IX,:);

%Chromatically adapt CIE XYZ to D50 using CIECAM02 chromatic adaptation transaform
%assuming full adaptation and using the 'fairchild' coefficients ('bradford and 'cie' similarly available)

if XYZn(1)~=D50(1)||XYZn(2)~=D50(2)||XYZn(3)~=D50(3)
    XYZ = camcat_cc(XYZ, XYZn, D50, 1, 'bradford');
    XYZn=D50;
end

%Convert to CIE 1971 L*a*b* (CIELAB) color space

CIELAB=XYZ2Lab(XYZ',XYZn)';
figure;
V=Gamut_Volume_ES2(RGB,CIELAB)

