function vis3Dmarker(W,varargin)

markersize = 5;
markercolor = 'g';
numbers = false;

ivargin = 1;
while ivargin <= length(varargin)
    switch lower(varargin{ivargin})
        case 'markersize'
            ivargin = ivargin + 1;
            markersize = varargin{ivargin};
        case 'markercolor'
            ivargin = ivargin + 1;
            markercolor = varargin{ivargin};
        case 'numbers'
            ivargin = ivargin + 1;
            numbers = varargin{ivargin};
        otherwise
            fprintf('Unknown option ''%s'' is ignored !!!\n',...
                varargin{ivargin});
    end
    ivargin = ivargin + 1;
end

plot3(W(1,:),W(2,:),W(3,:),'o','MarkerSize',markersize,...
    'MarkerFaceColor',markercolor,'MarkerEdgeColor',markercolor);
xlabel('x');
ylabel('y');
zlabel('z');

axis equal vis3d

if numbers
    for i = 1:size(W,2)
        text(W(1,i),W(2,i),W(3,i),num2str(i),'HorizontalAlignment','right')
    end
end