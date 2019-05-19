function [V,TRI] = Gamut_Volume(RGB,CIELAB)
%GAMUT_VOLUME calculate the CIELAB gamut volume.
%  [V, TRI] = Gamut_Volume(RGB, CIELAB) will calculate the CIELab gamut
%  volume based on the standard tesselation.  The input matrices must have
%  the same dimensions and contain the data for a complete set of gamut 
%  volume surface measurements.  It will return the volume V and,
%  optionally, the tesselation TRI (for use with e.g. trisurf)

%get the required standard tesselation
[TRI,RGB_ref] = make_tesselation(RGB);
  
%map the CIELAB data into a table in the same order as the reference data
map = zeros(size(RGB_ref,1));
for m=1:size(RGB_ref,1)
    [~,IX]=ismember(RGB_ref(m,:),RGB,'rows');
    if (isempty(IX)) 
        throw(MException('GamutVolume:missingData',...
          'Missing data for R=%d, G=%d, B=%d',RGB_ref(m,1),RGB_ref(m,2),RGB_ref(m,3)));
    elseif (length(IX)>1)
        throw(MException('GamutVolume:duplicateData',...
          'Duplicate data for R=%d, G=%d, B=%d',RGB_ref(m,1),RGB_ref(m,2),RGB_ref(m,3)));
    end
    map(m)=IX;
end
TRI = map(TRI);

%calculate the volume - using the divergence theorem.
a=CIELAB(TRI(:,1),:);
b=CIELAB(TRI(:,2),:);
c=CIELAB(TRI(:,3),:);
V = sum(dot(a,cross(b-c,a-b)))/6;
end
