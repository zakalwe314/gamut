function tess_meas

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

M = [2.7548 -0.9935 0.0771; % XYZ to Rec.709 RGB D50
    -1.3068 1.9229 -0.2826;
    -0.4238 0.0426 1.4644];
 
WhiteXYZ = [96.42957  100.0000  82.51046]; % D50 white

DISP_GAMMA = 2.2; % Display gamma (for CIELAB)

SPACE = 'CIELAB'; % CIELAB or ICTCP

%Black = 0;
White = 100; % nits (must be 100 for CIELAB and <=10000 for ICTCP)
N = 11; % Nodes

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read measured data and Bradform transform (from IEC doc)
%Define location of data file
Folder='dby_data';
File='vivid';

%Define the D50 white point
D50=[96.42956764 100 82.51046025]/100;

Header=read_header(Folder,File,22);
%Import data file
Data=read_data(Folder,File,22,726);

%Parse data into RGB and XYZ tristimulus arrays
RGB=[Data{2} Data{3} Data{4}];                  
XYZ=[Data{5} Data{6} Data{7}];
%Find the measured white point tristimulus values
IX=find(RGB(:,1)==1&RGB(:,2)==1&RGB(:,3)==1);
XYZn=XYZ(IX,:);

%Chromatically adapt CIE XYZ to D50 using CIECAM02 chromatic adaptation transaform
%assuming full adaptation and using the 'fairchild' coefficients ('bradford and 'cie' similarly available)

if XYZn(1)~=D50(1)|XYZn(2)~=D50(2)|XYZn(3)~=D50(3)
    XYZ = camcat_cc(XYZ, XYZn, D50, 1, 'bradford');
    XYZn=D50;
end

Black=XYZ(1,2);
XYZ=XYZ/XYZ(726,2)*White;

switch SPACE
  case 'ICTCP'
    EOTF=@PQEOTF; OETF=@PQOETF;
    XYZ2CAM=@XYZ2ICTCP; GAIN=[2048, 1024, 2048];
    LABEL={'C_T','C_P','I'};GAINFIG=1/10000;
  case 'CIELAB'
    EOTF=@(x) x.^DISP_GAMMA; OETF=@(x) x.^(1/DISP_GAMMA);
    XYZ2CAM=@(xyz) xyz2lab(xyz,WhiteXYZ); GAIN=[1 1 1];
    LABEL={'a*','b*','L*'};GAINFIG=1;
end

Nodes = linspace(0,1,N);
[C1,C2,C3] = meshgrid(Nodes,Nodes,[0 1]);
%RGB = [C1(:) C2(:) C3(:); C2(:) C3(:) C1(:); C3(:) C1(:) C2(:)];
%XYZ = EOTF(RGB*(OETF(White)-OETF(Black))+OETF(Black))/M;
% XYZ = EOTF(RGB*(OETF(White)-OETF(Black))+OETF(Black))/inv(colormatrix(xy))';
LAB = XYZ2CAM(XYZ).* GAIN;

% COMPUTING MDC, Create tessellation of the surface
[i,j,f] = meshgrid(0:N-2, 0:N-2, 0:5);
startidx = f*N*N + i*N + j + 1;
tri = [[startidx(:), startidx(:)+1, startidx(:) + N+1]; ...
[startidx(:), startidx(:)+N, startidx(:) + N+1]];

% Calculate the volume of the tessellation
v321 = LAB (tri(:,3),1) .* LAB (tri(:,2),2) .* LAB (tri(:,1),3);
v231 = LAB (tri(:,2),1) .* LAB (tri(:,3),2) .* LAB (tri(:,1),3);
v312 = LAB (tri(:,3),1) .* LAB (tri(:,1),2) .* LAB (tri(:,2),3);
v132 = LAB (tri(:,1),1) .* LAB (tri(:,3),2) .* LAB (tri(:,2),3);
v213 = LAB (tri(:,2),1) .* LAB (tri(:,1),2) .* LAB (tri(:,3),3);
v123 = LAB (tri(:,1),1) .* LAB (tri(:,2),2) .* LAB (tri(:,3),3);
v = sum(abs((1/6)*(-v321 + v231 + v312 - v132 - v213 + v123)));

patch('faces',tri,'vertices', LAB(:,[2 3 1]),'facevertexc',(EOTF(RGB)*GAINFIG).^(1/2),'facec','interp','edgea',0.1);
xlabel(LABEL{1}), ylabel(LABEL{2}), zlabel(LABEL{3});  grid on; box on; view([-37.5 15])

title(['Volume:' num2str(v) ' (' num2str(N^2+(N-1)^2*4+(N-2)^2) ' grid points)'])

function E=PQOETF(O)
E =  (((3424/4096)+(2413/128).*(max(0,O)/10000).^(2610/16384)) ./ ...
                 (1+(2392/128).*(max(0,O)/10000).^(2610/16384))).^(2523/32);
               
function O=PQEOTF(E)
O = (max(E.^(32/2523)-(3424/4096),0) ./ ...
                  ((2413/128)-(2392/128)*E.^(32/2523))).^(16384/2610)*10000;

function ICTCP=XYZ2ICTCP(XYZ)
XYZ2LMSmat = [0.3593  0.6976 -0.0359; -0.1921 1.1005 0.0754; 0.0071 0.0748 0.8433];
LMS2ICTCPmat = [2048 2048 0; 6610 -13613 7003; 17933 -17390 -543]/4096;
ICTCP=(LMS2ICTCPmat*PQOETF(XYZ2LMSmat*XYZ'))'; % 0<ICTCP<1


function lab=xyz2lab(xyz,xyzw)
lab=nan(size(xyz));
ind=xyz(:,2)/xyzw(2) > 0.008856;
lab(ind,1)  = 116*(xyz(ind,2)./xyzw(2)).^(1/3) - 16;
lab(~ind,1) = 903.3*(xyz(~ind,2)/xyzw(2));
fx=nan(size(xyz,1),3);
for k=1:3
 ind=xyz(:,k)/xyzw(k) > 0.008856;
 fx(ind,k)  = (xyz(ind,k)./xyzw(k)).^(1/3);
 fx(~ind,k) = 7.787*(xyz(~ind,k)./xyzw(k)) + 16/116;
end
lab(:,2:3) = [500*(fx(:,1)-fx(:,2)) 200*(fx(:,2)-fx(:,3))];