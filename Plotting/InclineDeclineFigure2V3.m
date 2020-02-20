function InclineDeclineFigure2V3(adaptDataList,params,conds,binWidth,trialMarkerFlag,indivSubFlag,IndivSubList,removeBias,groups, Study, results, epochs)
% This figure is to show the kinetic timecourses as well as the bar plots
% including stats


%% Set up the physical Figure
axesFontSize=10;
labelFontSize=0;
titleFontSize=12;
row=length(params);
col=7; subers1=[1:2; 8:9; 15:16; 22:23]; subers2=subers1+2;subers3=[5; 12; 19; 26];subers4=subers3+1; subers5=subers4+1; 
%col=10; subers1=[1:2; 11:12; 21:22; 31:32];subers2=subers1+2; subers3=[5; 15; 25; 35];subers4=subers3+1; subers5=subers4+1; BarWhere=[1:12];
[ah,figHandle]=optimizedSubPlot(row*col,row,col,'tb',axesFontSize,labelFontSize,titleFontSize);
%% Timecourse plots -- Adaptation

for p=1:length(params)
    sub=subers1(p, :);
    if strcmp(params{p}, 'FyBSmax')==1 || strcmp(params{p}, 'FyPSmax')==1
        removeBiasSpecial=2; % slow bias
    elseif  strcmp(params{p}, 'FyBFmax')==1 || strcmp(params{p}, 'FyPFmax')==1
        removeBiasSpecial=3; % fast bias
    end
    plotAvgTimeCourseSingle(adaptDataList,params(p),conds{1},binWidth,trialMarkerFlag,indivSubFlag,IndivSubList, [],0,removeBiasSpecial,groups,0,ah, row, col, sub)
    line([0 588], [0 0], 'Color', 'k')
end
%% Timecourse plots -- Post-Adaptation

for p=1:length(params)
    sub=subers2(p, :);
    removeBiasSpecial=1; % medium bias
    plotAvgTimeCourseSingle(adaptDataList,params(p),conds{2},binWidth,trialMarkerFlag,indivSubFlag,IndivSubList, [],0,removeBiasSpecial,groups,0,ah, row, col, sub)
    line([0 588], [0 0], 'Color', 'k')
end

%% Bar Plots

for p=1:length(params)
    sub=subers3(p, :);
    barGroupsSingle(Study,results,groups,params(p),epochs(1),0,[],[], row, col, sub)
end
%% Bar Plots

for p=1:length(params)
    sub=subers4(p, :);
    barGroupsSingle(Study,results,groups,params(p),epochs(3),0,[],[], row, col, sub)
end

%% Bar Plots
for p=1:length(params)
    sub=subers5(p, :);
    barGroupsSingle(Study,results,groups,params(p),epochs(2),0,[],[], row, col, sub)
end

%% Pretty
fh=gcf;
ah=findobj(fh,'Type','Axes');
clc
set(gcf,'Renderer','painters');