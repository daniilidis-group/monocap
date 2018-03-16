function vis3Dcar(S,edge,varargin)

color = [0.3 0.3 0.3];
linewidth = 1;
vp = [0,0];
camera = false;

i = 1;
while i <= length(varargin)
    switch lower(varargin{i})
        case 'color'
            i = i+1;
            color = varargin{i};
        case 'linewidth'
            i = i+1;
            linewidth = varargin{i};
        case 'viewpoint';
            i = i+1;
            vp = varargin{i};
        case 'camera'
            i = i+1;
            camera = varargin{i};
    end
    i = i+1;
end

for i=1:length(edge);
    plot3(S(1,edge(i,:)),-S(3,edge(i,:)),S(2,edge(i,:)), ...
        'LineStyle','-','color',color,'linewidth',linewidth);
    hold on;
end
axis equal
axis off

if camera
    drawCam(eye(3),[0;0;5]);
end

view(vp);



function drawCam(R,t)

scale = 0.5;
P = scale*[0 0 0;0.5 0.5 0.8; 0.5 -0.5 0.8; -0.5 0.5 0.8;-0.5 -0.5 0.8];

%P = scale*[0 0 0;0.5 0.5 -0.8; 0.5 -0.5 -0.8; -0.5 0.5 -0.8;-0.5 -0.5 -0.8];

P1=R'*(P'-repmat(t,[1,5]));
%P1=R*P'+repmat(t,[1,5]);
P1=P1';

line([P1(1,1) P1(2,1)],[P1(1,3) P1(2,3)],[P1(1,2) P1(2,2)],'color','k')
line([P1(1,1) P1(3,1)],[P1(1,3) P1(3,3)],[P1(1,2) P1(3,2)],'color','k')
line([P1(1,1) P1(4,1)],[P1(1,3) P1(4,3)],[P1(1,2) P1(4,2)],'color','k')
line([P1(1,1) P1(5,1)],[P1(1,3) P1(5,3)],[P1(1,2) P1(5,2)],'color','k')

line([P1(2,1) P1(3,1)],[P1(2,3) P1(3,3)],[P1(2,2) P1(3,2)],'color','k')
line([P1(3,1) P1(5,1)],[P1(3,3) P1(5,3)],[P1(3,2) P1(5,2)],'color','k')
line([P1(5,1) P1(4,1)],[P1(5,3) P1(4,3)],[P1(5,2) P1(4,2)],'color','k')
line([P1(4,1) P1(2,1)],[P1(4,3) P1(2,3)],[P1(4,2) P1(2,2)],'color','k')


cameraPlane =[P1(2,1) P1(2,3) P1(2,2);  P1(4,1) P1(4,3) P1(4,2); P1(3,1) P1(3,3) P1(3,2);P1(5,1) P1(5,3) P1(5,2)];
faces =[2 1 3 4];
patch('Vertices',cameraPlane,'Faces',faces,'FaceVertexCData',hsv(6),'FaceColor','k','FaceAlpha',0.05);


C1=[P1(2,1) P1(2,3) P1(2,2)];
C2=[P1(3,1) P1(3,3) P1(3,2)];
C3=[P1(4,1) P1(4,3) P1(4,2)];
C4=[P1(5,1) P1(5,3) P1(5,2)];

O=[P1(1,1) P1(1,3) P1(1,2)];
Cmid =0.25*(C1+C2+C3+C4);

% Lz = [O; O+0.5*(Cmid-O)];
% Lx = [O; O+0.5*(C2-C1)];
% Ly = [O; O+0.5*(C3-C1)];

Lz = [O; O+0.5*(Cmid-O)];
Lx = [O; O+0.5*(C1-C3)];
Ly = [O; O+0.5*(C1-C2)];

line(Lz(:,1),Lz(:,2),Lz(:,3),'color','b','linewidth',2)
line(Lx(:,1),Lx(:,2),Lx(:,3),'color','g','linewidth',2)
line(Ly(:,1),Ly(:,2),Ly(:,3),'color','r','linewidth',2)

axis tight;