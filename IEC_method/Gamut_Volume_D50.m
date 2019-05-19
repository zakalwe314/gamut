[Data,filename] = ui_read_data('iec_data\*.txt');

RGB=[Data{2} Data{3} Data{4}];                  
XYZ=[Data{5} Data{6} Data{7}];
RGBmax = max(RGB(:));
XYZn = XYZ(all(RGB==RGBmax,2),:);

D50=[96.42957  100.0000  82.51046]/100;

%Chromatically adapt CIE XYZ to D50 using CIECAM02 CAT
%assuming full adaptation and using the 'Bradford' coefficients

if ~all(XYZn==D50)
    XYZ = camcat_cc(XYZ, XYZn, D50);
end

%Convert to CIE 1971 L*a*b* (CIELAB) color space

CIELAB=XYZ2Lab(XYZ,D50);
[V,TRI]=Gamut_Volume(RGB,CIELAB);

%plot the gamut
trisurf(TRI, CIELAB(:,2),CIELAB(:,3),CIELAB(:,1),...
    'FaceVertexCData',RGB/RGBmax,'FaceColor','interp');
view([30 30]);
xlabel('CIE a^*','FontSize',14);
ylabel('CIE b^*','FontSize',14);
zlabel('CIE L^*','FontSize',14);
t=sprintf('CIELab gamut volume = %g from file "%s"\n', V,filename);
title(t,'Interpreter', 'none');
fprintf('%s\n',t);
axis equal;