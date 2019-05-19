function output = camcat_cc(XYZ1, XYZn, XYZa)

% function output = camcat_cc(XYZ1, XYZn, XYZa)
%
% Function to calculate corresponding colors based upon
% the Bradford chromatic adaptation transform. 
%
% input:    XYZ1, Tristimulus values of original stimulus
%           XYZn, Tristimulus values of "white" under first condition
%           XYZa, Tristimulus values of new viewing condtion
%
% output:   Corresponding XYZ tristimulus values under new viewing
% conditions.

% Use Bradford chromatic adaption
M = [ 0.8951,  0.2664, -0.1614;...
     -0.7502,  1.7135,  0.0367;...
      0.0389, -0.0685,  1.0296]';

% change into new "cone" space
RGBn = XYZn*M;
RGBa = XYZa*M;

% calculate corresponding colors
A = diag(RGBa./RGBn);
MAM = M*A/M;

% correct the XYZ tristimulus values
output = XYZ1*MAM;

