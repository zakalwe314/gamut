function c = Intersection(orig, dir, vert0, vert1, vert2)

orig=repmat(orig,size(vert0,1),1);
dir=repmat(dir,size(vert0,1),1);

edge1 = vert1-vert0;          % find vectors for two edges sharing vert0
edge2 = vert2-vert0;
tvec  = orig -vert0;          % vector from vert0 to ray origin
pvec  = cross(dir, edge2,2);  % begin calculating determinant - also used to calculate U parameter
det   = sum(edge1.*pvec,2);   
u    = sum(tvec.*pvec,2)./det;

qvec = cross(tvec, edge1,2);    % prepare to test V parameter
v    = sum(dir  .*qvec,2)./det; % 2nd barycentric coordinate
t    = sum(edge2.*qvec,2)./det; % 'position on the line' coordinate
  
IX=find(u>=0 & v>=0 & u+v<=1.15 & t>=0);

c=mean(t(IX));

