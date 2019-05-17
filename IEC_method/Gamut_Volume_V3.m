function V=Gamut_Volume_V3(RGB_in,CIELAB_in)

%Compute the gamut volume of the data in CIELAB

    %Input RGB_in (0 to 255) formated according to specification
        
    %Input CIELAB_in

%format data for tesselating the surface of the gamut volume

d=unique(RGB_in);
  
N_Grid=size(d,1)-1;

[J,K]=meshgrid(d,d);

RGB=[...
    [zeros((N_Grid+1)^2,1) J(:) K(:)];...
    [J(:) zeros((N_Grid+1)^2,1) K(:)];...
    [J(:) K(:) zeros((N_Grid+1)^2,1)];...
    [255*ones((N_Grid+1)^2,1) J(:) K(:)];...
    [J(:) 255*ones((N_Grid+1)^2,1) K(:)];...
    [J(:) K(:) 255*ones((N_Grid+1)^2,1)]...
    ];

    for m=1:size(RGB,1)

        IX=find(RGB(m,1)==RGB_in(:,1)&RGB(m,2)==RGB_in(:,2)&RGB(m,3)==RGB_in(:,3));
        CIELAB(m,:)=CIELAB_in(IX,:);

    end

Z=[CIELAB(:,2) CIELAB(:,3) CIELAB(:,1)];

%Tesselate the surface of the volume in RGB

TRI=[];

for s=1:6
    for q=1:N_Grid
        for p=1:N_Grid

            m=(N_Grid+1)^2*(s-1)+(N_Grid+1)*(q-1)+p;

            TRI=[TRI;[m m+1 m+N_Grid+1]];
            TRI=[TRI;[m+N_Grid+1 m+N_Grid+2 m+1]];
            
       end
    end
end

 %Plot the tesselated gamut surface
figure(1);H1=patch('Faces',TRI,'Vertices',Z,...
    'FaceColor','interp','facevertexcdata'...
    ,double(RGB)/255,'FaceAlpha',1,'EdgeColor','k','EdgeAlpha',1);

view([30 30])

xlabel('CIE a^*','FontSize',14)
ylabel('CIE b^*','FontSize',14)
zlabel('CIE L^*','FontSize',14)


%Find the minmum and maxmum L* in each triangle

Max_L=max(max(Z(TRI(:,1),3),Z(TRI(:,2),3)),Z(TRI(:,3),3));
Min_L=min(min(Z(TRI(:,1),3),Z(TRI(:,2),3)),Z(TRI(:,3),3));

%Define L* and Hue intervals for integrating the tesselated surace to obtain its volume

delta_L=1; 
delta_Hue=2*pi/360;

L=[min(Min_L):(max(Max_L)-min(Min_L))/100:max(Max_L)]';
Hue=[0:delta_Hue:2*pi]';

%Make sure the L*'s at maximum chroma are included in integrating to obtain the volume

[R,G,B]=meshgrid(0:1:1,0:1:1,0:1:1);
RGB_Max=[R(:) G(:) B(:)];
RGB_Max=255*RGB_Max(2:size(RGB_Max,1)-1,:);

%Integrate the tesselated surface in cylindrical coordates of CIELAB L*, Hue, and
%Chroma

vol=0;

for p=2:size(L,1)-1
    
    delta_L=L(p)-L(p-1);
    orig=[0 0 L(p)];

    IX=find(L(p)>=Min_L&L(p)<=Max_L);
	orig=repmat(orig,size(IX));
    
    for q=2:size(Hue,1)

        dir=[sin(Hue(q)) cos(Hue(q)) 0];

        vert0=Z(TRI(IX,1),:);
        vert1=Z(TRI(IX,2),:);
        vert2=Z(TRI(IX,3),:);

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

        ix=find(u>=0 & v>=0 & u+v<=1.15 & t>=0);

        c=max(t(ix));

        delta_Hue=Hue(q)-Hue(q-1);
        
        if ~isempty(c)

            vol=vol+(c^2)*delta_L*delta_Hue/2;%Compute the Volume increment in cylinrical coordinates
        end
                
    end
                    
end

V=vol; %Return the computed volume
