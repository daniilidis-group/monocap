function vis2Dcar(W,edge,varargin)


linewidth = 1;
visibility = true(1,length(W));

i = 1;
while i <= length(varargin)
    switch lower(varargin{i})
        case 'linewidth'
            i = i+1;
            linewidth = varargin{i};
        case 'visibility';
            i = i+1;
            visibility = varargin{i};
    end
    i = i+1;
end

for i=1:length(edge);
    if visibility(edge(i,1)) && visibility(edge(i,2))
        plot(W(1,edge(i,:)),W(2,edge(i,:)),'r-','linewidth',linewidth);
    else
        plot(W(1,edge(i,:)),W(2,edge(i,:)),'b--','linewidth',linewidth);
    end
    hold on;
end

axis equal
axis off



