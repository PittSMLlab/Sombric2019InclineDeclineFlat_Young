%Figures & stats for Sombric et al. 2019 paper 
%(a.k.a. the incline decline study)
% You must have YoungSlopeData.mat in your path.

%% Initialize
clear all
close all
clc

load('YoungSlopeData.mat')
adaptDataList = {YoungSlopeData.DeclineYoungAbrupt.adaptData,YoungSlopeData.FlatYoungAbrupt.adaptData,YoungSlopeData.InclineYoungAbrupt.adaptData};
binWidth = 5;
trialMarkerFlag = [0  0  0];
indivSubFlag = 0;
IndivSubList = 0;
groups = {'DeclineYoungAbrupt','FlatYoungAbrupt','InclineYoungAbrupt'};

%% Figure

%Figure 5: Kinetics
params = {'FyBSmax','FyBFmax','FyPSmax','FyPFmax'}; removeBias =0;
epochs={'SpeedAdapDiscont',  'TMafter','DelFAdapt'}; %Which should be the same as.. epochs={'SpeedAdapDiscont',  'DelFDeAdapt2Base','DelFAdapt'};
RF=getForceResults(YoungSlopeData,params,groups,0, 0, 0, 1);
conds = {'adaptation', 'TM post'};
InclineDeclineFigure2V3(adaptDataList,params,conds,binWidth,trialMarkerFlag,indivSubFlag,IndivSubList,removeBias,groups, YoungSlopeData, RF, epochs)

%Figure 2: Step Length Asymmetry
params = {'netContributionNorm2'}; removeBias =1;
RF_K=getForceResults(YoungSlopeData,params,groups,0, 0, 0, removeBias);
epochs={'TMSteady', 'EarlyA', 'TMafter', 'DelFAdapt'};
conds = {'TM base','adaptation','TM post'};
InclineDeclineFigure3V3(adaptDataList,params,conds,binWidth,trialMarkerFlag,indivSubFlag,IndivSubList,removeBias,groups, YoungSlopeData, RF_K, epochs)

%Figre 3: Step Length 
params = {'stepLengthSlow','stepLengthFast'}; removeBias =0;
conds = {'slow', 'fast', 'TM base','adaptation','TM post'};
RF=getForceResults(YoungSlopeData,params,groups,0, 0, 0, removeBias);
epochs={'EarlyA', 'DelFAdapt', 'TMSteady'};
InclineDeclineFigure2V2(adaptDataList,params,conds,binWidth,trialMarkerFlag,indivSubFlag,IndivSubList,removeBias,groups, YoungSlopeData, RF, epochs)

%Figure 4, Step Length Visualization, most panels
StepLengthVis

%Figure 6 and Figure 4, Panel D and F
load('YoungSlopeData.mat')
groups = {'DeclineYoungAbrupt','FlatYoungAbrupt', 'InclineYoungAbrupt'};
params = {'FyBSmax','FyBFmax','FyPSmax','FyPFmax', 'FyPmaxSym', 'FyBmaxSym', 'stepLengthFast', 'stepLengthSlow', 'netContributionNorm2', 'XSlow', 'XFast', 'alphaSlow', 'alphaFast'};%, 'SYZmag', 'FYZMag',  'FzFmax', 'FzSmax'};,  'FySBmaxQS','FySPmaxQS','FyFBmaxQS','FyFPmaxQS'
RF=getForceResults(YoungSlopeData,params,groups,0, 0, 0, 1);
params = {'spatialContributionNorm2','stepTimeContributionNorm2','velocityContributionNorm2','netContributionNorm2', 'stepLengthFast', 'stepLengthSlow'};
RK=getResults(YoungSlopeData,params,groups,0, 0, 0, 1);
InclineDeclineFigure6V2(YoungSlopeData,RF, RK, groups)


