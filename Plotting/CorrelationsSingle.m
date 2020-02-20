function CorrelationsSingle(SMatrix, results,epoch1,param1,results2, epoch2, param2, groups, colorOrder, row, col, num, FigureNum, led, PairedData)
%CorrelationsNewThings(DumbTester7, results,['TMsteady'],params,results, ['TMafter'], params, groups,[])
%2= x-axis
%1= y-axis

%THIS MAY BE WHAT YOU ARE LOOKING FOR IF THIS DOESN'T WORK FOR YOU!
%lm=MetaCorrelations(SMatrix, results,epoch1,param1,meta, groups,colorOrder)

% % Set colors order
% if nargin<8 || exist('colorOrder')==0 || isempty(colorOrder) || size(colorOrder,2)~=3
%     poster_colors;
%     colorOrder=[p_red; p_orange; p_fade_green; p_fade_blue; p_plum; p_green; p_blue; p_fade_red; p_lime; p_yellow; [0 0 0]];
% end

if nargin<8 || exist('colorOrder')==0 || isempty(colorOrder) || size(colorOrder,2)~=3
    poster_colors;
    if length(groups)==3
        colorOrder=[p_red;  p_orange;p_fade_green; p_fade_blue; p_plum; p_green; p_blue; p_fade_red; p_lime; p_yellow; [0 0 0]; p_red; p_orange; p_fade_green; p_fade_blue; p_plum];
    elseif length(groups)==2
        colorOrder=[ p_orange; p_fade_green;p_fade_blue; p_plum; p_green; p_blue; p_fade_red; p_lime; p_yellow; [0 0 0]; p_red; p_orange; p_fade_green; p_fade_blue; p_plum];
    end
end


X=[];
for var=1:length(param1)
    
    Y=results.(epoch1).indiv.(param1{var})(:,2);
    
    for cog=1:size(param2, 2)
        X=results2.(epoch2).indiv.(param2{cog})(:,2);
        groupKey=results.(epoch1).indiv.(param1{var})(:,1);
        
        if exist('PairedData') && PairedData==1 % New 6/13/2018 CJS
            LastFirst=find(groupKey(:)==groupKey(1), 1, 'last');
            X=[X(LastFirst+1:end)-X(1:LastFirst)];
            Y=[Y(LastFirst+1:end)-Y(1:LastFirst)];
            groupKey=groupKey(1:LastFirst);
        end
        
        if ~ isempty(find(isnan(Y)==1)) || length(X)~=length(Y)
            %Y=results.(epoch1).indiv.(param1{var})(:,2); %6/13/2018 CJS
            X(find(isnan(Y)==1))=[];
            groupKey(find(isnan(Y)==1))=[];
            Y(find(isnan(Y)==1))=[];
        end
        %         X([16, 3])=[];
        %         Y([16, 3])=[];
        %         groupKey([16, 3])=[];
        
        groupNums=unique(groupKey);
        %axes(ah(i)); hold on
        eval(['figure(' num2str(FigureNum) ')']);
        eval(['subplot(', num2str(row), ',', num2str(col), ',', num2str(num), '); hold on']);
        
        for g=groupNums'
            plot(X(groupKey==g),Y(groupKey==g),'.','markerSize',15,'color',colorOrder(g,:))
        end
        
        tbl=table(X, Y, 'VariableNames',{[epoch2 '_' param2{1}],[epoch1 '_' param1{1}]});
        lm = fitlm(tbl,'linear');
        %         Pslope=double(lm.Coefficients{2,4});
        %         Pintercept=double(lm.Coefficients{1,4});
        Y_fit=lm.Fitted;
        %         coef=double(lm.Coefficients{:,1});%Intercept=(1, 1), slop=(2,1)
        Rsquared1=lm.Rsquared.Ordinary;
        %         R=corr(X, Y);
        %         Resid=lm.Residuals.Studentized;
        plot(X,Y_fit,'k');
        
        
        
        %Pearson Coefficient
        FullMeta=find(isnan(X)~=1);
        [RHO_Pearson,PVAL_Pearson] = corr(X(FullMeta),Y(FullMeta),'type', 'Pearson');
        
        %         %Spearman Coefficient
        %         [RHO_Spearman,PVAL_Spearman] = corr(X(FullMeta),Y(FullMeta),'type', 'Spearman');
        
        %         %         %Multiple Linear Refression
        %         %         [b,bint,r,rint,stats] =regress(Y, [X groupKey])
                [b1,b2,st] =glmfit([X groupKey], Y, 'normal');
                stpData=st.p(2);
                stpGroupWRONG=st.p(3);
        
        
        %% ULTRA LABEL
        
        %
        % groupAng=[];
        % for g=1:length(groupNums)
        %                 if g==2
        %                     groupAng(find(groupKey==g), 1)=0;
        %                 else
        %                     groupAng(find(groupKey==g), 1)=g;
        %                 end
        % %     if g==2
        % %         namename='Flat';
        % %     elseif g==1
        % %         namename='FlatDecline';
        % %     elseif g==3
        % %         namename='FlatIncline';
        % %     end
        % %     HERE=(find(groupKey==g));
        % %     for p=1:8
        % %         groupAng{1}(HERE(p), 1)=namename;
        % %     end
        % end
        
        for d=1:length(X)
            groupAng{d, 1}=groups{groupKey(d)};
        end
        
        % Want to re-order so that we compare to flat, so flat has to go first...
        tbl2=table(X, groupAng, Y, 'VariableNames',{[epoch2 '_' param2{1}],'group',[epoch1 '_' param1{1}]});
        tbl2.group = categorical(tbl2.group);
        % Downer=find(groupKey==1);
        % Flatter=find(groupKey==2);
        % Uper=find(groupKey==3);
        %  tbl2=table([X(Flatter(1):Flatter(end));X(Downer(1):Downer(end));X(Uper(1):Uper(end))], [groupAng(Flatter(1):Flatter(end));groupAng(Downer(1):Downer(end));groupAng(Uper(1):Uper(end))], [Y(Flatter(1):Flatter(end));Y(Downer(1):Downer(end));Y(Uper(1):Uper(end))], 'VariableNames',{[epoch2 '_' param2{1}],'group',[epoch1 '_' param1{1}]});
        %  tbl2.group = categorical(tbl2.group);
        lm2=fitlm(tbl2, 'linear');
        Rsquared2=lm2.Rsquared.Ordinary;
        T=anova(lm2,'summary');% The only way to get the F and model p value
        F2=table2array(T(2,4));
        Fp2=table2array(T(2,5));
        Rsquared2=lm2.Rsquared.Ordinary;
        stpData=lm2.Coefficients{2, 4};
        stpGroup=lm2.Coefficients{[3:(3+length(groupNums)-2)], 4};
        T=lm2.anova; %THe only way to get one p value for the group factor
        pGROUP=table2array(T(2,5));
        % CX2=double(lm2.Coefficients{1,1});
        % CX1=double(lm2.Coefficients{2,1});
        % CX2=double(lm2.Coefficients{3,1});
        % PX1=double(lm2.Coefficients{2,4});
        % PX2=double(lm2.Coefficients{3,4});
        
        %% Is a categorical group variable coorelated to the X variable?
        %Pearson Coefficient
        FullMeta=find(isnan(X)~=1);
        [~,PVAL_PearsonGRPX] = corr(X(FullMeta),groupKey(FullMeta),'type', 'Pearson');
        
        %% Are the groups signficantly differently...
        %[p,tbl,stats] = anova1([X(find(groupKey==1)) X(find(groupKey==2)) X(find(groupKey==3))]);
        %% To know the 95% CI... in case I might wish to know this information...
        cat=coefCI(lm);
        CISlope=cat(2, :);
        clear cat
        
        %% Display the relavent stats
        hold on
        
        if g<=2
            %Summary Correlation, regression, and multiple linear regression
            %label1B = sprintf('Lin: R^2 = %0.2f (p_{rho} = %0.3f) \n MLin: XData = %0.2f,   Groups = %0.2f', Rsquared1, PVAL_Pearson, stpData,stpGroup);
            label1B = sprintf('Lin: R^2 = %0.2f (p_{rho} = %0.3f) \n slope95CI=[%0.2f, %0.2f]', Rsquared1, PVAL_Pearson, CISlope(1), CISlope(2));
        else
            %Detailed multiple linear regression
            %label1B = sprintf('MLin: p_{mdl}=%0.3f (R^2 = %0.2f) \n XData = %0.2f,   Groups = [%0.2f; %0.2f]', Fp2,Rsquared2, stpData,stpGroup(1),stpGroup(2) );
            %label1B = sprintf('Lin: R^2 = %0.2f (p_{rho} = %0.3f)\n slope95CI=[%0.2f, %0.2f]', Rsquared2, PVAL_Pearson, CISlope(1), CISlope(2));
            label1B = sprintf('Lin: R^2 = %0.2f (p_{rho} = %0.3f)\n PearP_{GRPvsX}=%0.3f; MLinGrpP=%0.3f', Rsquared2, PVAL_Pearson, PVAL_PearsonGRPX,pGROUP);% stpGroup(1), stpGroup(2));
        end
        
        %                 % ALL THE DETAILS
        %                 if length(stpGroup)==1
        %                     label1B = sprintf('Lin: R^2 = %0.2f (p_{rho} = %0.3f) \n MLin: p_{mdl}=%0.3f (R^2 = %0.2f) \n X = %0.2f,   Grp = [%0.2f]', Rsquared1, PVAL_Pearson, Fp2,Rsquared2, stpData,stpGroup(1) );
        %                 else
        %                 label1B = sprintf('Lin: R^2 = %0.2f (p_{rho} = %0.3f) \n MLin: p_{mdl}=%0.3f (R^2 = %0.2f) \n X = %0.2f,   Grp = [%0.2f; %0.2f]', Rsquared1, PVAL_Pearson, Fp2,Rsquared2, stpData,stpGroup(1),stpGroup(2) );
        %                 end
        %
        
        %label1B = sprintf('Lin: R^2 = %0.2f (p_{rho} = %0.3f) \n MLin: XData = %0.2f,   Groups = %0.2f', Rsquared1, PVAL_Pearson, stpData,stpGroup);
        %label1B = sprintf('Lin: R^2 = %0.2f (p_{rho} = %0.3f) \n MLin: XData = %0.2f,   Groups = %0.2f \n RealXp = %0.2f', Rsquared1, PVAL_Pearson, stpData,stpGroup, XDataP);
        
        %label1B=lm.Formula.LinearPredictor;
        %label1B=lm2.Formula.LinearPredictor;
        title(label1B,'fontsize',10)
        %ylabel({[epoch1 ', ' param1{var}]},'fontsize',12)
        ylabel({epoch1; param1{var}},'fontsize',12)
        xlabel({[epoch2 ', ' param2{cog}]},'fontsize',12)
        
        
        set(gca,'fontsize',8)
        
        axis equal
        axis tight
        axis square
        %if var==1 && cog==1
        if exist('led')==1 && led==1
            if exist('PairedData') && PairedData==1 % New 6/13/2018 CJS
                legend([groups{2} ' - ' groups{1}]);
            else
                legend(groups)
            end
        end
        %i=i+1;
        X=[];
    end
    if length(param1)<=4 && length(param2)<=4
        clearvars -except SMatrix results epoch1 param1 meta  groups colorOrder i ah results2 epoch2 param2 MultReg
        set(gcf,'renderer','painters')
        X=[];
    else
        clearvars -except SMatrix results epoch1 param1 meta  groups colorOrder metalabels results2 epoch2 param2 MultReg
        X=[];
    end
end

set(gcf,'renderer','painters')
end