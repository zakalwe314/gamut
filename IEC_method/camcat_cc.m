function output = camcat_cc(XYZ1, XYZn, XYZa, D, transform)

% function output = camcat_cc(XYZ1, XYZn, XYZa, D, transform)
%
% Function to calculate corresponding colors based upon a choice
% of chromatic adaptation transform. 
%
% input:    XYZ1, Tristimulus values of original stimulus
%           XYZn, Tristimulus values of "white" under first condition
%           XYZa, Tristimulus values of new viewing condtion
%           D, Degree of incomplete adaptation [0, 1]
%           transform, categorical "fairchild", "bradford", "cie"
%
% output:   Corresponding XYZ tristimulus values under new viewing
% conditions.

% find which 3x3 to use
switch lower(transform)
    case 'fairchild'
        M = [[.8562, .3372, -.1934];...
                [-.8360, 1.8327, .0033];...
                [.0357, -.0469, 1.0112]] ;
        
    case 'bradford'
        M = [[.8951, .2664, -.1614];...
                [-.7502, 1.7135, .0367];...
                [.0389, -.0685, 1.0296]] ;
        
    otherwise % 'ciecam02'
        M = [[.7328, .4296, -.1624];...
                [-.7036, 1.6974, .0061];...
                [.0030, .0136, .9834]] ;
end

% change into new "cone" space
RGBn=(M*XYZn')';
RGBa=(M*XYZa')';

% calculate corresponding colors
Rc = D.*RGBa(1)./RGBn(1) + (1-D) ;
Gc = D.*RGBa(2)./RGBn(2) + (1-D) ;
Bc = D.*RGBa(3)./RGBn(3) + (1-D) ;

A = diag([Rc; Gc; Bc]) ;
MAM = inv(M)*A*M ;

% go back to XYZ tristimulus values
output = (MAM*XYZ1')';

