function InclineDeclineFigure3V3(adaptDataList,params,conds,binWidth,trialMarkerFlag,indivSubFlag,IndivSubList,removeBias,groups, Study, results, epochs)
% This figure is to show the kinetic timecourses as well as the bar plots
% including stats

%% Set up the physical Figure
axesFontSize=10;
labelFontSize=0;
titleFontSize=12;
row=2;
col=4;
[ah,figHandle]=optimizedSubPlot(row*col,row,col,'tb',axesFontSize,labelFontSize,titleFontSize);
%%
poster_colors;
if length(groups)==3
    colorOrder=[p_red;  p_fade_green;p_orange; p_fade_blue; p_plum; p_green; p_blue; p_fade_red; p_lime; p_yellow; [0 0 0]; p_red; p_orange; p_fade_green; p_fade_blue; p_plum];
elseif length(groups)==2
    colorOrder=[ p_orange; p_fade_green;p_fade_blue; p_plum; p_green; p_blue; p_fade_red; p_lime; p_yellow; [0 0 0]; p_red; p_orange; p_fade_green; p_fade_blue; p_plum];
end

%% Timecourse plots
subers=[1:col];
for p=1:length(params)
    sub=subers(p, :);
    plotAvgTimeCourseSingle(adaptDataList,params(p),conds,binWidth,trialMarkerFlag,indivSubFlag,IndivSubList,colorOrder,0,removeBias,groups,0,ah, row, col, sub); hold on
    line( [125.6+51 138.4+51],[.1 .1], 'Color', 'k')
line( [128.8+51 142.4+51],[.2 .2], 'Color', 'k')
line( [84.66+51 97.86+51],[.3 .3],  'Color', 'k')
plot( [132+51], [.1], 'ko', 'MarkerFaceColor', colorOrder(1, :))
plot( [135.6+51], [.2], 'ko', 'MarkerFaceColor', colorOrder(3, :))
plot( [91.27+51], [.3], 'ko', 'MarkerFaceColor', colorOrder(2, :))
end

%% Bar Plots
subers=[col+1:col*row];
fh=gcf;

barGroupsSingle(Study,results,groups,params(p),epochs(1),0,colorOrder,[], row, col, subers(1))
barGroupsSingle(Study,results,groups,params(p),epochs(2),0,colorOrder,[], row, col, subers(2))
barGroupsSingle(Study,results,groups,params(p),epochs(4),0,colorOrder,[], row, col, subers(3))
barGroupsSingle(Study,results,groups,params(p),epochs(3),0,colorOrder,[], row, col, subers(4))

%% Pretty
ah=findobj(fh,'Type','Axes');
set(gcf, 'render', 'painter')

return
figure(100)
CorrelationsSingle(Study, results,['TMSteady'],params(p), results,['EarlyA'],params(p), groups, colorOrder, 1, 3, 1, 100, 1)
CorrelationsSingle(Study, results,['TMafter'],params(p), results,['DelFAdapt'],params(p), groups, colorOrder, 1, 3, 2, 100)
CorrelationsSingle(Study, results,['TMafter'],params(p), results,['EarlyA'],params(p), groups, colorOrder, 1, 3, 3, 100)

