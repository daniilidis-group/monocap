function vis2Dmarker(W,varargin)

markersize = 5;
markercolor = 'g';
annot = [];

ivargin = 1;
while ivargin <= length(varargin)
    switch lower(varargin{ivargin})
        case 'markersize'
            ivargin = ivargin + 1;
            markersize = varargin{ivargin};
        case 'markercolor'
            ivargin = ivargin + 1;
            markercolor = varargin{ivargin};
        case 'annot'
            ivargin = ivargin + 1;
            annot = varargin{ivargin};
        otherwise
            fprintf('Unknown option ''%s'' is ignored !!!\n',...
                varargin{ivargin});
    end
    ivargin = ivargin + 1;
end

plot(W(1,:),W(2,:),'o','MarkerSize',markersize,...
    'MarkerFaceColor',markercolor,'MarkerEdgeColor',markercolor);

if ~isempty(annot)
    for i = 1:size(W,2)
        text(W(1,i),W(2,i),strrep(annot{i},'_',' '),'HorizontalAlignment','right')
    end
end