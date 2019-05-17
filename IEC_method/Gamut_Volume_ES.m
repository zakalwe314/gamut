function V = Gamut_Volume_ES(RGB_in,CIELAB_in)

%find the RGB centre (just the centroid of the points)
RGB_cent = mean(RGB_in);

%get the RGB points mapped onto a unit sphere - this avoids the problem of
%concave surfaces.  The triangulation can then be re-applied to the CIELAB
%points
RGBd = RGB_in - repmat(RGB_cent,size(RGB_in,1),1);
RGBu = RGBd ./ repmat(sqrt(sum(RGBd.^2,2)),1,3);

%get the convex hull of this
K = convhulln(RGBu);

%calculate the volume - using the divergence theorem
triVectors = cross(CIELAB_in(K(:,2),:)-CIELAB_in(K(:,3),:),...
                   CIELAB_in(K(:,1),:)-CIELAB_in(K(:,2),:),2);
V = abs(sum(sum(CIELAB_in(K),2).*triVectors(:,1))/6);

%plot the hull mapped into CIELab
trisurf(K, CIELAB_in(:,2),CIELAB_in(:,3),CIELAB_in(:,1),'FaceVertexCData',RGB_in/255,'FaceColor','interp');
view([30 30])

xlabel('CIE a^*','FontSize',14)
ylabel('CIE b^*','FontSize',14)
zlabel('CIE L^*','FontSize',14)
end
