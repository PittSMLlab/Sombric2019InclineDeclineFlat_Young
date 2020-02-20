function CrissCross(Study,results,groups,params,colorOrder, row, col, sub, fnum)
%Make a bar plot to compare groups for a given epoch and parameter
%   TO DO: make function be able to accept a group array that is different
%   thand the groups in the results matrix

   
% poster_colors;
% colorOrder=[p_red; p_orange; p_fade_green; p_fade_blue; p_plum; p_green; p_blue; p_fade_red; p_lime; p_yellow; [0 0 0]];
% Set grey colors to use when individual subjects are plotted 
if size(results.DelFAdapt.avg, 2)>2
    display('THERE ARE TOO MANY PARAMETERS IN RESULTS!')
    return
end

EAEpoch='DelFAdapt';
PAEpoch='DelFDeAdapt';

% EAEpoch='EarlyA';
% PAEpoch='TMafter';

%% DO STATS    
grp=[results.(EAEpoch).indiv.(params{1})(:,1); results.(PAEpoch).indiv.(params{1})(:,1);...
    results.(EAEpoch).indiv.(params{2})(:,1); results.(PAEpoch).indiv.(params{2})(:,1)];
leg=[2.*ones(length(results.(EAEpoch).indiv.(params{1})(:,1))*2, 1); 1.*ones(length(results.(EAEpoch).indiv.(params{1})(:,1))*2, 1)];
epoch=[1.*ones(length(results.(EAEpoch).indiv.(params{1})(:,1)), 1); 2.*ones(length(results.(EAEpoch).indiv.(params{1})(:,1)), 1);1.*ones(length(results.(EAEpoch).indiv.(params{1})(:,1)), 1); 2.*ones(length(results.(EAEpoch).indiv.(params{1})(:,1)), 1)];
data=[results.(EAEpoch).indiv.(params{1})(:,2); results.(PAEpoch).indiv.(params{1})(:,2);...
    results.(EAEpoch).indiv.(params{2})(:,2); results.(PAEpoch).indiv.(params{2})(:,2)];
[p, ~,stats] =anovan(data, {grp, leg, epoch}, 'model', 'full', 'varnames', {'slope', 'leg', 'epoch'});
AnovaOrder={'slope, ', 'leg, ', 'epoch, ', 'slope#leg, ', 'slope#epoch, ', 'leg#epoch, ', 'slope#leg#epoch, '}

%titleTEXT=strcat(AnovaOrder{find(p<0.05)});
titleTEXT = sprintf('Slope = %0.1d Leg = %0.1d \n Epoch = %0.1d Slope#Leg = %0.1d \n Slope#Epoch = %0.1d Leg#Epoch = %0.1d \n Slope#Leg#Epoch = %0.1d', p(1), p(2), p(3), p(4), p(5), p(6), p(7))
      

eval(['figure(', num2str(fnum), ')'])
ax7=subplot(row, col, sub);
title([titleTEXT]);
for g=1:length(groups)
eval(['g', num2str(g) '=line([1+.1*(', num2str(g), '-1), 2+.1*(', num2str(g), '-1)], [results.' (EAEpoch) '.avg(', num2str(g), ', 1) results.' (PAEpoch) '.avg(', num2str(g), ', 1)], ''Color'',colorOrder(', num2str(g), ', :), ''LineWidth'', 2) ; hold on'])

    sleg=errorbar(1+.1*(g-1), results.(EAEpoch).avg(g, 1), -1.*results.(EAEpoch).se(g, 1), results.(EAEpoch).se(g, 1), 'ok', 'MarkerFaceColor', 'w');
    errorbar(2+.1*(g-1), results.(PAEpoch).avg(g, 1), -1.*results.(PAEpoch).se(g, 1), results.(PAEpoch).se(g, 1), 'ok', 'MarkerFaceColor', 'w')
    
    line([1+.1*(g-1), 2+.1*(g-1)], [results.(EAEpoch).avg(g, 2) results.(PAEpoch).avg(g, 2)], 'Color',colorOrder(g, :), 'LineWidth', 2) ; hold on
    fleg=errorbar(1+.1*(g-1), results.(EAEpoch).avg(g, 2), -1.*results.(EAEpoch).se(g, 2), results.(EAEpoch).se(g, 2), 'ok', 'MarkerFaceColor', 'k');
    errorbar(2+.1*(g-1), results.(PAEpoch).avg(g, 2), -1.*results.(PAEpoch).se(g, 2), results.(PAEpoch).se(g, 2), 'ok', 'MarkerFaceColor', 'k')
end

line([.8 2.2], [0 0], 'Color', 'k', 'LineStyle',':')
% line([1.5 1.5],[-100 400],  'Color', 'k', 'LineStyle',':')
ax7.XTick=[1, 2]; ax7.XTickLabel={EAEpoch, PAEpoch};
ylabel([params{1} '; ' params{2} ' Change'])
if length(groups)==2
    legend([fleg sleg g1 g2 ], {'Slow Leg','Fast Leg',  groups{1}, groups{2}})
elseif length(groups)==3
    legend([fleg sleg g1 g2 g3], {'Slow Leg','Fast Leg',  groups{1}, groups{2}, groups{3}})
else
    legend([fleg sleg g1 g2 g3 g4], {'Slow Leg','Fast Leg',  groups{1}, groups{2}, groups{3}, groups{4}})
end
set(gcf,'Renderer','painters');

end

