function InclineDeclineFigure6(SMatrix,RF, RK, groups)
close all

figure(1001)
CorrelationsSingle(SMatrix, RF,['DelFAdapt'],{'FyPSmax'}, RF,['EarlyA'],{'FyPSmax'}, groups, [], 2, 3, 1, 1001, 1)
CorrelationsSingle(SMatrix, RF,['TMafter'],{'FyPFmax'}, RF,['DelFAdapt'],{'FyPSmax'}, groups, [], 2, 3, 2, 1001)
CorrelationsSingle(SMatrix, RF,['TMafter'],{'XFast'}, RF,['TMafter'],{'FyPFmax'}, groups, [], 2, 3, 3, 1001)
CorrelationsSingle(SMatrix, RF,['TMafter'],{'stepLengthSlow'}, RF,['TMafter'],{'XFast'}, groups, [], 2, 3, 4, 1001)
CorrelationsSingle(SMatrix, RF,['TMafter'],{'netContributionNorm2'}, RF,['TMafter'],{'stepLengthSlow'}, groups, [], 2, 3, 5, 1001)
CorrelationsSingle(SMatrix, RF,['TMafter'],{'netContributionNorm2'}, RF,['EarlyA'],{'FyPSmax'}, groups, [], 2, 3, 6, 1001)

figure(54)
XallDATA=[RF.SlowBase.indiv.XSlow(:, :); RF.FastBase.indiv.XFast(:, :); RF.SlowBase.indiv.alphaSlow(:, :); RF.FastBase.indiv.alphaFast(:, :)];
YallDATA=[RF.TMSteadyWBias.indiv.XSlow(:, :); RF.TMSteadyWBias.indiv.XFast(:,:); RF.TMSteadyWBias.indiv.alphaSlow(:, :); RF.TMSteadyWBias.indiv.alphaFast(:, :)];
Parameters=[ones(length(RF.SlowBase.indiv.XSlow(:, :)), 1); 2.*ones(length(RF.SlowBase.indiv.XSlow(:, :)), 1);3.*ones(length(RF.SlowBase.indiv.XSlow(:, :)), 1); 4.*ones(length(RF.SlowBase.indiv.XSlow(:, :)), 1)];
paramLabels={'XSlow', 'XFast', 'alphaSlow', 'alphaFast'};
epochLabels={'Speed-Specific Baseline (mm)', 'Late Adaptation (mm)'};
%CorrelationsSingleXYNoIntercept(SMatrix, YallDATA,XallDATA, groups, Parameters, paramLabels, [], 1, 1, 1, 54, 1, epochLabels)
CorrelationsSingleXYABS(SMatrix, YallDATA,XallDATA, groups, Parameters, paramLabels, [], 1, 2, 1, 54, 1, epochLabels)

XallDATA_PA=[RF.TMSteadyWBias.indiv.XSlow(:, :); RF.TMSteadyWBias.indiv.XFast(:,:); RF.TMSteadyWBias.indiv.alphaSlow(:, :); RF.TMSteadyWBias.indiv.alphaFast(:, :)];
YallDATA_PA=[RF.TMafterWBias.indiv.XFast(:, :); RF.TMafterWBias.indiv.XSlow(:, :);  RF.TMafterWBias.indiv.alphaSlow(:, :); RF.TMafterWBias.indiv.alphaFast(:, :)];
Parameters=[ones(length(RF.SlowBase.indiv.XSlow(:, :)), 1); 2.*ones(length(RF.SlowBase.indiv.XSlow(:, :)), 1);3.*ones(length(RF.SlowBase.indiv.XSlow(:, :)), 1); 4.*ones(length(RF.SlowBase.indiv.XSlow(:, :)), 1)];
paramLabels={'XSlow/XFast', 'XFast/XSlow', 'alphaSlow', 'alphaFast'};
epochLabels={'Late Adaptation (mm)', 'Post-Adaptation (mm)'};
%CorrelationsSingleXYNoIntercept(SMatrix, YallDATA_PA,XallDATA_PA, groups, Parameters, paramLabels, [], 1, 1, 1, 55, 1, epochLabels)
CorrelationsSingleXYABS(SMatrix, YallDATA_PA,XallDATA_PA, groups, Parameters, paramLabels, [], 1, 2, 2, 54, 1, epochLabels)



return
