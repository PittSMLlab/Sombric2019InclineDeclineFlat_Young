function CorrelationsSingleXYABS(SMatrix, Y,X, groups, things, paramLabels, colorOrder, row, col, num, FigureNum,  led,epochLabels, PairedData)
%CorrelationsNewThings(DumbTester7, results,['TMsteady'],params,results, ['TMafter'], params, groups,[])

%THIS MAY BE WHAT YOU ARE LOOKING FOR IF THIS DOESN'T WORK FOR YOU!
%lm=MetaCorrelations(SMatrix, results,epoch1,param1,meta, groups,colorOrder)


if nargin<8 || exist('colorOrder')==0 || isempty(colorOrder) || size(colorOrder,2)~=3
    poster_colors;
    if length(groups)==3
        colorOrder=[p_red;  p_orange;p_fade_green; p_fade_blue; p_plum; p_green; p_blue; p_fade_red; p_lime; p_yellow; [0 0 0]; p_red; p_orange; p_fade_green; p_fade_blue; p_plum];
    elseif length(groups)==2
        colorOrder=[ p_orange; p_fade_green;p_fade_blue; p_plum; p_green; p_blue; p_fade_red; p_lime; p_yellow; [0 0 0]; p_red; p_orange; p_fade_green; p_fade_blue; p_plum];
    end
end


markerOrder={'o', '.' 's', '^'};

groupKey=X(:,1);
Y=abs(Y(:,2));
X=abs(X(:,2));


if exist('PairedData') && PairedData==1 % New 6/13/2018 CJS
    LastFirst=find(groupKey(:)==groupKey(1), 1, 'last');
    X=[X(LastFirst+1:end)-X(1:LastFirst)];
    Y=[Y(LastFirst+1:end)-Y(1:LastFirst)];
    groupKey=groupKey(1:LastFirst);
end

if ~ isempty(find(isnan(Y)==1)) || length(X)~=length(Y)
    X(find(isnan(Y)==1))=[];
    groupKey(find(isnan(Y)==1))=[];
    Y(find(isnan(Y)==1))=[];
end


groupNums=unique(groupKey);
eval(['figure(' num2str(FigureNum) ')']);
eval(['subplot(', num2str(row), ',', num2str(col), ',', num2str(num), '); hold on']);

for g=groupNums'
    for m=1:length(unique(things))
        if m==1 || m==3
            plot(X(groupKey==g & things==m),Y(groupKey==g& things==m),markerOrder{m},'MarkerEdgeColor',colorOrder(g,:), 'MarkerFaceColor', colorOrder(g,:), 'LineWidth', 1.2);%'markerSize',15,
        elseif m==2 || m==4
            plot(X(groupKey==g & things==m),Y(groupKey==g& things==m),markerOrder{m-1},'MarkerEdgeColor',colorOrder(g,:), 'MarkerFaceColor', 'w', 'LineWidth', 1.2)
        end
        
    end
end
tbl=table(X, Y, 'VariableNames',{['X'],['Y']});
lm = fitlm(tbl,'linear','Intercept',true);
Y_fit=lm.Fitted;
Rsquared1=lm.Rsquared.Ordinary;
%plot(X,Y_fit,'k');
KittyCat=find(~isnan(X));
plot(X(KittyCat),Y_fit(KittyCat),'k');


%Pearson Coefficient
FullMeta=find(isnan(X)~=1);
[RHO_Pearson,PVAL_Pearson] = corr(X(FullMeta),Y(FullMeta),'type', 'Pearson');


% % % 
% % % for d=1:length(X)
% % %     groupAng{d, 1}=groups{groupKey(d)};
% % % end
% % % 
% % % % Want to re-order so that we compare to flat, so flat has to go first...
% % % tbl2=table(X, groupAng, Y, 'VariableNames',{['X'],'group',['Y']});
% % % tbl2.group = categorical(tbl2.group);
% % % lm2=fitlm(tbl2, 'linear');
% % % Rsquared2=lm2.Rsquared.Ordinary;
% % % T=anova(lm2,'summary');% The only way to get the F and model p value
% % % F2=table2array(T(2,4));
% % % Fp2=table2array(T(2,5));
% % % Rsquared2=lm2.Rsquared.Ordinary;
% % % stpData=lm2.Coefficients{2, 4};
% % % stpGroup=lm2.Coefficients{[3:(3+length(groupNums)-2)], 4};

%% To know the 95% CI... in case I might wish to know this information...
cat=coefCI(lm);
CISlope=cat(1, :);
clear cat

hold on

% if g<=2
    %         %Summary Correlation, regression, and multiple linear regression
    %label1B = sprintf('Lin: R^2 = %0.2f (p_{rho} = %0.3f) \n MLin: XData = %0.2f,   Groups = %0.2f', Rsquared1, PVAL_Pearson, stpData,stpGroup);
    label1B = sprintf('Lin: R^2 = %0.2f (p_{rho} = %0.3f) \n slope=%0.2f [%0.2f, %0.2f] and NON-ZERO INTERCEPT', Rsquared1, PVAL_Pearson, lm.Coefficients{1,1}, CISlope(1), CISlope(2));
% else
%     %Detailed multiple linear regression
%     %label1B = sprintf('MLin: p_{mdl}=%0.3f (R^2 = %0.2f) \n XData = %0.2f,   Groups = [%0.2f; %0.2f]', Fp2,Rsquared2, stpData,stpGroup(1),stpGroup(2) );
%     label1B = sprintf('Lin: R^2 = %0.2f (p_{rho} = %0.3f)\n slope=%0.2f [%0.2f, %0.2f]', Rsquared2, PVAL_Pearson, lm.Coefficients{1,1}, CISlope(1), CISlope(2));
% end
title(label1B,'fontsize',10)

set(gca,'fontsize',8)

fh=gcf;
ah=findobj(fh,'Type','Axes');
dog=[ah.YLim; ah.XLim];
set(ah,'Ylim',[min(dog(:,1)) max(dog(:,2))]);
set(ah,'Xlim',[min(dog(:,1)) max(dog(:,2))]);
hline = refline([1 0]);
hline.Color = 'c';

axis equal
axis tight
axis square


if exist('epochLabels')==1
    xlabel(['|' epochLabels{1} '|'])
ylabel(['|' epochLabels{2} '|'])
else
xlabel('|Speed Specific Baseline| (mm)')
ylabel('|Late Adaptation| (mm)')
end


for g=1:length(groups)
    for p=1:length(paramLabels)
        if p==1 && g==1
            LegendLabeler=[groups{g} ': ' paramLabels{p}];
        else
            LegendLabeler=strvcat(LegendLabeler, [groups{g} ': ' paramLabels{p}]);
        end
    end
end
legend(LegendLabeler)


set(gcf,'renderer','painters')
