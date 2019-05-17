GetGamutCorners.m

function [ P ] = GetGamutCorners( P ,wh)
%GET PRIM returns a set of colour corner points based on a standard gamut
%　　　input string must contain one of:
% 　　　　　　'sRGB', 'Rec709', 'EBU', 'NTSC'
% 　　　　　　　　　　　optionally one of
% 　　　　　　'D50', 'D55', 'D65', 'D75', 'IllA', 'IllE'
　　　　if ischar(P)
　　　　　　　　　if nargin<2
　　　　　　　　　　　　　　wh=P;
　　　　　　　　　end
　　　　　　　　　if strfind(P,'sRGB') || strfind(P,'Rec709')
　　　　　　　　　　　　　　prim=[0.64,0.33;0.3,0.6;0.15,0.06];
　　　　　　　　　elseif strfind(P,'EBU')
　　　　　　　　　　　　　　prim=[0.64,0.33;0.29,0.6;0.15,0.06];
　　　　　　　　　elseif strfind(P,'NTSC')
　　　　　　　　　　　　　　prim=[0.67,0.33;0.21,0.71;0.14,0.08];
　　　　　　　　　else
　　　　　　　　　　　　　　error('non-valid colour primary specification');
　　　　　　　　　end
　　　　　　　　　P=prim;
　　　　end
　　　　if ischar(wh)
　　　　　　　　　if strfind(wh,'D50')
　　　　　　　　　　　　　wh=[0.3457,0.3585];
　　　　　　　　　elseif strfind(wh,'D55')
　　　　　　　　　　　　　wh=[0.3324,0.3474];
　　　　　　　　　elseif strfind(wh,'D65')
　　　　　　　　　　　　　wh=[0.3127,0.3290];
　　　　　　　　　elseif strfind(wh,'D75')
　　　　　　　　　　　　　wh=[0.2990,0.3149];
　　　　　　　　　elseif strfind(wh,'IllA')
　　　　　　　　　　　　　wh=[0.44757,0.40745];
　　　　　　　　　elseif strfind(wh,'IllE')
　　　　　　　　　　　　　wh=[0.3333,0.3333];
　　　　　　　　　else
　　　　　　　　　　　　　wh=[0.3127,0.3290];
　　　　　　　　　display('Default D65 white used');
　　　　　　　　　end
　　　　end
　　　　wh=[wh, 1-sum(wh)]/wh(2);
　　　　P=[P, 1-sum(P,2)];
　　　　P=P.*repmat((wh/P)',1,3);
　　　　%P=[KRYGCBMW]'
　　　　P=[0 0 0;P(1,:);sum(P(1:2,:));P(2,:);sum(P(2:3,:));...
　　　　　　　　P(3,:);sum(P([1 3],:)); sum(P)];
end