function [TRI, RGB] = make_tesselation(gsv)
%MAKE_TESSELATION create an RGB gamut volume tesselation
%  [TRI, RGB] = make_tesselation(values) will construct a reference RGB
%  tesselation from a unique set of the given greyscale values.

%ensure a column vector and that the values are unique
gsv = unique(gsv);
N = length(gsv);
%build the reference RGB table
[J,K]=meshgrid(gsv,gsv);
J=J(:); K=K(:);
Lower=zeros(size(J)); Upper=Lower+255;
%on the bottom surface the order must be rotations of Lower,J,K
%on the top surface the order must be rotations of Upper,K,J 
RGB=[Lower, J, K; K, Lower, J; J, K, Lower;...
     Upper, K, J; J, Upper, K; K, J, Upper];

%build the required tessellation
TRI=zeros(12*(N-1)^2,3);
idx=1;
for s=1:6
    for q=1:N-1
        for p=1:N-1
            m=N^2*(s-1) + N*(q-1) + p;
            %The two triangles must have the same rotation
            %consider A B  triangle 1 = A-B-C
            %         C D  triangle 2 = B-D-C
            %both are clockwise
            TRI(idx,:)=[m, m+N, m+1];
            TRI(idx+1,:)=[m+N, m+N+1, m+1];
            idx=idx+2;
       end
    end
end

end

