function InclineDeclineFigure2_Stroke(adaptDataList,params,conds,binWidth,trialMarkerFlag,indivSubFlag,IndivSubList,removeBias,groups, Study, results, epochs)
% This figure is to show the kinetic timecourses as well as the bar plots
% including stats


%% Set up the physical Figure
axesFontSize=10;
labelFontSize=0;
titleFontSize=12;
row=length(params);
col=6; subers1=[1:3; 7:9];
[ah,figHandle]=optimizedSubPlot(row*col,row,col,'tb',axesFontSize,labelFontSize,titleFontSize);
bob=gcf;
%% Timecourse plots

for p=1:length(params)
    sub=subers1(p, :);
    plotAvgTimeCourseSingle(adaptDataList,params(p),conds,binWidth,trialMarkerFlag,indivSubFlag,IndivSubList, [],0,removeBias,groups,0,ah, row, col, sub)
end

%% Criss Cross Plot
poster_colors;
if length(groups)>=3
    colorOrder=[p_red;  p_orange;p_fade_green; p_fade_blue; p_plum; p_green; p_blue; p_fade_red; p_lime; p_yellow; [0 0 0]; p_red; p_orange; p_fade_green; p_fade_blue; p_plum];
elseif length(groups)==2
    colorOrder=[ p_orange; p_fade_green;p_fade_blue; p_plum; p_green; p_blue; p_fade_red; p_lime; p_yellow; [0 0 0]; p_red; p_orange; p_fade_green; p_fade_blue; p_plum];
end

CrissCrossSingle(adaptDataList,results,groups,{'stepLengthSlow', 'stepLengthFast'},colorOrder, 1, 2, [2], bob.Number)
axis square

%% Pretty
fh=gcf;
ah=findobj(fh,'Type','Axes');
set(gcf,'Renderer','painters');