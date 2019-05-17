function [v,gp]=tess2(N,FIG)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Matlab function tess.m
% by Kenichiro Masaoka (NHK), 2018
%
% I modified Dolby's matlab script. Reference:
% Perceptual color volume, white paper, Dolby Laboratories, Inc., 2017.

% M = [ 3.2410 -0.9692  0.0556; % XYZ to Rec.709 RGB
%      -1.5374  1.8760 -0.2040;
%      -0.4986  0.0416  1.0570];
 
M = [ 1.7167 -0.6667  0.0176; % XYZ to Rec.2020 RGB
     -0.3557  1.6165 -0.0428;
     -0.2534  0.0158  0.9421];
   
WhiteXYZ = [95.0456  100.0000  108.9058]; % D65 white

DISP_GAMMA = 2.2; % Display gamma (for CIELAB)

% SPACE = 'ICTCP'; % CIELAB or ICTCP
SPACE = 'CIELAB'; % CIELAB or ICTCP

Black = 0;
White = 100; % nits (must be 100 for CIELAB and <=10000 for ICTCP)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch SPACE
  case 'ICTCP'
    EOTF=@PQEOTF; OETF=@PQOETF;
    XYZ2CAM=@XYZ2ICTCP; GAIN=[2048, 1024, 2048];
    LABEL={'C_T','C_P','I'};GAINFIG=1/10000;
  case 'CIELAB'
    EOTF=@(x) x.^DISP_GAMMA; OETF=@(x) x.^(1/DISP_GAMMA);
    XYZ2CAM=@(xyz) xyz2lab(xyz,WhiteXYZ); GAIN=[1 1 1];
    LABEL={'\ita\rm*','\itb\rm*','\itL\rm*'};GAINFIG=1;
end

Nodes = linspace(0,1,N);
[C1,C2,C3] = meshgrid(Nodes,Nodes,[0 1]);
RGB = [C1(:) C2(:) C3(:); C2(:) C3(:) C1(:); C3(:) C1(:) C2(:)];
XYZ = EOTF(RGB*(OETF(White)-OETF(Black))+OETF(Black))/M;
LAB = XYZ2CAM(XYZ).* repmat(GAIN,[size(XYZ,1) 1]);

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
v  = sum(abs((1/6)*(-v321 + v231 + v312 - v132 - v213 + v123)));
gp = N^2+(N-1)^2*4+(N-2)^2;
if FIG
 patch('faces',tri,'vertices', LAB(:,[2 3 1]),'facevertexc',(EOTF(RGB)*GAINFIG).^(1/2),'facec','interp','edgea',0.1);
 xlabel(LABEL{1}), ylabel(LABEL{2}), zlabel(LABEL{3});  grid on; box on; view([-37.5 15])
 title(['Volume:' num2str(v) ' (' num2str(gp) ' grid points)'])
end


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
