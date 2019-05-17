clc
clear
close all

%Define location of data file
Folder='iec_data';
File='srgb_CR1E6_D50';

%Define the D65 white point
D65=[95.047 100 108.883]/100;

Header=read_header(Folder,File,22);
%Import data file
Data=read_data(Folder,File,22,604);

%Parse data into RGB and XYZ tristimulus arrays
RGB=[Data{2} Data{3} Data{4}];                  
XYZ=[Data{5} Data{6} Data{7}];

%Find the measured white point tristimulus values
IX=find(RGB(:,1)==255&RGB(:,2)==255&RGB(:,3)==255);
XYZn=XYZ(IX,:);

%Chromatically adapt CIE XYZ to D65 using CIECAM02 chromatic adaptation transaform
%assuming full adaptation and using the 'fairchild' coefficients ('bradford and 'cie' similarly available)

if XYZn(1)~=D65(1)|XYZn(2)~=D65(2)|XYZn(3)~=D65(3)
    XYZ = camcat_cc(XYZ, XYZn, D65, 1, 'bradford');
    XYZn=D65;
end

%Convert to CIE 1971 L*a*b* (CIELAB) color space

CIELAB=XYZ2Lab(XYZ',XYZn)';

V=Gamut_Volume_V3(RGB,CIELAB)

