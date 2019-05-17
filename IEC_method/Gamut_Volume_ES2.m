function V = Gamut_Volume_ES2(RGB_in,CIELAB_in)
 
%get the RGB values
d = unique(RGB_in);
N_Grid=size(d,1)-1;
 
%build a reference RGB table to get the data into a known order
[J,K]=meshgrid(d,d);
J=J(:); K=K(:);
Lower=zeros(size(J)); Upper=Lower+255;
%on the bottom surface the order must be rotations of Lower,J,K
%on the top surface the order must be rotations of Upper,K,J 
RGB=[Lower, J, K; K, Lower, J; J, K, Lower;...
     Upper, K, J; J, Upper, K; K, J, Upper];
 
%map the CIELAB data into a table in the same order as above
CIELAB = zeros(size(RGB));
for m=1:size(RGB,1)
    IX=RGB(m,1)==RGB_in(:,1)&RGB(m,2)==RGB_in(:,2)&RGB(m,3)==RGB_in(:,3);
    Lab = CIELAB_in(IX,:);
    if (numel(Lab)==0) 
        throw(MException('GamutVolume:missingData',...
          'Missing data for R=%d, G=%d, B=%d',RGB(m,1),RGB(m,2),RGB(m,3)));
    end
    CIELAB(m,:)= Lab;
end
 
%build the required tessellation
TRI=zeros(12*N_Grid*N_Grid,3);
idx=1;
for s=1:6
    for q=1:N_Grid
        for p=1:N_Grid
            m=(N_Grid+1)^2*(s-1)+(N_Grid+1)*(q-1)+p;
            %The two triangles must have the same rotation
            %consider A B  triangle 1 = A-B-C
            %         C D  triangle 2 = B-D-C
            %are clockwise
            TRI(idx,:)=[m, m+N_Grid+1, m+1];
            TRI(idx+1,:)=[m+N_Grid+1, m+N_Grid+2, m+1];
            idx=idx+2;
       end
    end
end
 
%calculate the volume - using the divergence theorem.
surfaceNormals = cross(CIELAB(TRI(:,2),:)-CIELAB(TRI(:,3),:),...
                   CIELAB(TRI(:,1),:)-CIELAB(TRI(:,2),:),2);
V = sum(sum(CIELAB(TRI),2).*surfaceNormals(:,1))/6;
 
%plot the gamut
trisurf(TRI, CIELAB(:,2),CIELAB(:,3),CIELAB(:,1),...
    'FaceVertexCData',RGB/255,'FaceColor','interp');
view([30 30])
xlabel('CIE a^*','FontSize',14)
ylabel('CIE b^*','FontSize',14)
zlabel('CIE L^*','FontSize',14)
axis equal;
end
