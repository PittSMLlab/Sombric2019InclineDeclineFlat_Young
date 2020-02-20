function results = getResults(SMatrix,params,groups,maxPerturb,plotFlag,indivFlag, removeBias)
%getResultsPerceptionStudy(SMatrix,params,groups,maxPerturb,plotFlag,indivFlag, removeBias)

% define number of points to use for calculating values
catchNumPts = 3; %catch
steadyNumPts = 40; %end of adaptation
transientNumPts = 5; %OG and Washout
EarlyStrides=[1:5];
%EarlyStrides=[2:6];
% EarlyStrides=[3:7];
% EarlyStrides=[4:8];
%EarlyStrides=[5:9];
%EarlyStrides=[6:10];
%EarlyStrides=[7:11];
%EarlyStrides=[8:12];
%EarlyStrides=[9:13];
%EarlyStrides=[6:15];
%EarlyStrides=[1:10];
%EarlyStrides=[1:15];
%EarlyStrides=[1:20];
%EarlyStrides=[1:30];
%EarlyStrides=[1:40];
%EarlyStrides=[1:50];
%EarlyStrides=[11:15];

if nargin<3 || isempty(groups)
    groups=fields(SMatrix);  %default
end
ngroups=length(groups);


% Initialize values to calculate
results.OGbase.avg=[];
results.OGbase.se=[];

results.TMbase.avg=[];
results.TMbase.se=[];

results.AvgAdaptBeforeCatch.avg=[];
results.AvgAdaptBeforeCatch.se=[];

results.AvgAdaptAll.avg=[];
results.AvgAdaptAll.se=[];

results.ErrorsOut.avg=[];
results.ErrorsOut.se=[];

results.TMsteadyBeforeCatch.avg=[];
results.TMsteadyBeforeCatch.se=[];

results.catch.avg=[];
results.catch.se=[];

results.TMsteady.avg=[];
results.TMsteady.se=[];

results.OGafter.avg=[];
results.OGafter.se=[];

results.TMafter.avg=[];
results.TMafter.se=[];

results.Transfer.avg=[];
results.Transfer.se=[];

results.Washout.avg=[];
results.Washout.se=[];

results.Transfer2.avg=[];
results.Transfer2.se=[];

results.Washout2.avg=[];
results.Washout2.se=[];

results.BFWashout.avg=[];
results.BFWashout.se=[];

results.DeltaAdapt.avg=[];
results.DeltaAdapt.se=[];

results.FlatWash.avg=[];
results.FlatWash.se=[];

results.PLearn.avg=[];
results.PLearn.se=[];

results.EarlyA.avg=[];
results.EarlyA.se=[];

results.ExtentA.avg=[];
results.ExtentA.se=[];
results.DeltaDeAdapt.avg=[];
results.DeltaDeAdapt.se=[];

results.TMafterEVEN.avg=[];
results.TMafterEVEN.se=[];
results.TMafterODD.avg=[];
results.TMafterODD.se=[];

for g=1:ngroups
    
    % get subjects in group
    subjects=SMatrix.(groups{g}).ID;

DeltaDeAdapt=[];
   OGbase=[];
    TMbase=[];
    avgAdaptBC=[];
    avgAdaptAll=[];
    errorsOut=[];
    tmsteadyBC=[];
    tmCatch=[];
    tmsteady=[];
    ogafter=[];
    tmafter=[];
    transfer=[];
    washout=[];
    transfer2=[];
    washout2=[];
    BFWashout=[];
    DeltaAdapt=[];
    FlatWash=[];
    plearn=[];
    EarlyA=[];
    ExtentA=[];
    tmafterEVEN=[];
    tmafterODD=[];
    for s=1:length(subjects)
        % load subject
        adaptData=SMatrix.(groups{g}).adaptData{s};
        
        % remove baseline bias
        adaptData=adaptData.removeBadStrides;
        
        if  ~exist('removeBias') || removeBias==1
            adaptData=adaptData.removeBias;
            %adaptData=adaptData.removeBias({'TM base'});
        end
        
        if nargin>3 && maxPerturb==1
            
            % compute TM and OG base in same manner as calculating OG after and TM after
            stepAsymData=adaptData.getParamInCond('stepLengthAsym','OG base');
            OGbaseData=adaptData.getParamInCond(params,'OG base');
            OGbase=[OGbase; smoothedMax(OGbaseData(1:10,:),transientNumPts,stepAsymData(1:10))];
            
            stepAsymData=adaptData.getParamInCond('stepLengthAsym','TM base');
            TMbaseData=adaptData.getParamInCond(params,'TM base');
            if isempty(TMbaseData)
                stepAsymData=adaptData.getParamInCond('stepLengthAsym',{'slow base','fast base'});
                TMbaseData=adaptData.getParamInCond(params,{'slow base','fast base'});
            end
            TMbase=[TMbase; smoothedMax(TMbaseData(1:10,:),transientNumPts,stepAsymData(1:10))];
            
            % compute catch as mean value during strides which caused a
            % maximum deviation from zero during 'catchNumPts' consecutive
            % strides
            stepAsymData=adaptData.getParamInCond('stepLengthAsym','catch');
            tmcatchData=adaptData.getParamInCond(params,'catch');
            tmCatch=[tmCatch; smoothedMax(tmcatchData,transientNumPts,stepAsymData)];
            
            % compute OG after as mean values during strides which cause a
            % maximum deviation from zero in STEP LENGTH ASYMMETRY during
            % 'transientNumPts' consecutive strides within first 10 strides
            stepAsymData=adaptData.getParamInCond('stepLengthAsym','OG post');
            ogafterData=adaptData.getParamInCond(params,'OG post');
            ogafter=[ogafter; smoothedMax(ogafterData(1:10,:),transientNumPts,stepAsymData(1:10))];
            
            % compute TM after-effects same as OG after-effect
            stepAsymData=adaptData.getParamInCond('stepLengthAsym','TM post');
            tmafterData=adaptData.getParamInCond(params,'TM post');
            tmafter=[tmafter; smoothedMax(tmafterData(1:10,:),transientNumPts,stepAsymData(1:10))];
            return
        else
            
            % calculate TM and OG base in same manner as calculating OG after and TM after
            if isempty(strcmp(adaptData.metaData.conditionName, 'OG base'))
                OGbaseData=adaptData.getParamInCond(params,'OG base');
                if ~isempty(OGbaseData)
                    OGbase=[OGbase; nanmean(OGbaseData(1:transientNumPts,:))];
                end
            else
                OGbase=NaN.*ones(s, length(params));%[OGbase; NaN];
            end
            
            TMbaseData=adaptData.getParamInCond(params,'TM base');
            if isempty(TMbaseData)
                if adaptData.isaCondition('slow base')
                TMbaseData=adaptData.getParamInCond(params,{'slow base','fast base'});
                else
                    TMbaseData=adaptData.getParamInCond(params,{'slow','fast'});
                end
            end
            if ~isempty(TMbaseData)
                TMbase=[TMbase; nanmean(TMbaseData(1:transientNumPts,:))];
            else
            end
            
            % compute catch
            if isempty(find(cellfun(@(x) ~isempty(x),(regexp(lower(adaptData.metaData.conditionName), 'catch')))))
                newtmcatchData=NaN.*ones(1, length(params));
            else
                tmcatchData=adaptData.getParamInCond(params,'catch');
                if isempty(tmcatchData)
                    newtmcatchData=NaN(1,length(params));
                elseif size(tmcatchData,1)<3
                    newtmcatchData=nanmean(tmcatchData);
                else
                    newtmcatchData=nanmean(tmcatchData(1:catchNumPts,:));
                    %newtmcatchData=nanmean(tmcatchData);
                end
            end
            tmCatch=[tmCatch; newtmcatchData];
            
            % compute OG post
            if isempty(strcmp(adaptData.metaData.conditionName, 'OG post'))
                ogafterData=adaptData.getParamInCond(params,'OG post');
                if ~isempty(ogafterData)
                    ogafter=[ogafter; nanmean(ogafterData(1:transientNumPts,:))];
                else
                end
            else
                ogafter=NaN.*ones(s, length(params));%[ogafter; NaN];
            end
            
            % compute TM post
            if ~isempty(find(cellfun(@(x) ~isempty(x),(regexp(lower(adaptData.metaData.conditionName), lower('TM post'))))))
                tmafterData=adaptData.getParamInCond(params,'TM post');
            elseif ~isempty(find(cellfun(@(x) ~isempty(x),(regexp(lower(adaptData.metaData.conditionName), 'washout')))))
                tmafterData=adaptData.getParamInCond(params,'washout');
            elseif ~isempty(find(cellfun(@(x) ~isempty(x),(regexp(lower(adaptData.metaData.conditionName), 'tm after')))))
                tmafterData=adaptData.getParamInCond(params,'TM after'); 
            end
            
            %if ~isempty(tmafterData)
                tmafter=[tmafter; nanmean(tmafterData(EarlyStrides,:))];
                %tmafter=[tmafter; nanmean(tmafterData(1:10,:))];
                tmafterEVEN=[tmafterEVEN; nanmean(tmafterData(2:2:10,:))];
                tmafterODD=[tmafterODD; nanmean(tmafterData(1:2:10,:))];
                %tmafter=[tmafter; nanmean(tmafterData(6:10,:))];
                DeltaDeAdapt=[DeltaDeAdapt; nanmean(tmafterData((end-5)-steadyNumPts+1:(end-5),:))-tmafter(s, :)];
                %DeltaDeAdapt=[DeltaDeAdapt; nanmean(tmafterData((end-5)-steadyNumPts+1:(end-5),:))-nanmean(tmafterData(1:20,:))];
%             else
%             end
            
%             %If BF TM post -- OLD
%             if ~isempty(find(cellfun(@(x) ~isempty(x),(regexp(lower(adaptData.metaData.conditionName), lower('Washout Error Clamp'))))))
%                 BFWashoutData=adaptData.getParamInCond(params,'Washout Error Clamp');
%             end
%             
%             if ~isempty(BFWashoutData)
%                 BFWashout=[BFWashout; nanmean(BFWashoutData(1:transientNumPts,:))];
%             end
            
            %If BF TM post -- NEw
            if ~isempty(find(cellfun(@(x) ~isempty(x),(regexp(lower(adaptData.metaData.conditionName), lower('Washout Error Clamp'))))))
                BFWashoutData=adaptData.getParamInCond(params,'Washout Error Clamp');
                BFWashout=[BFWashout; nanmean(BFWashoutData(1:transientNumPts,:))];
            else
                BFWashout=NaN.*ones(s, length(params));
            end  
        end

        % compute TM steady state before catch (mean of first transinetNumPts of last transinetNumPts+5 strides)
        adapt1Data=adaptData.getParamInCond(params,adaptData.metaData.conditionName(find(cellfun(@(x) ~isempty(x),(regexp(lower(adaptData.metaData.conditionName), 'ada'))), 1, 'first')));
        %         adapt1Data=adaptData.getParamInCond(params,'adaptation');
        tmsteadyBC=[tmsteadyBC; nanmean(adapt1Data((end-5)-transientNumPts+1:(end-5),:))];
        
        % compute average adaptation value before the catch
        avgAdaptBC=[avgAdaptBC; nanmean(adapt1Data)];
        
      
        % compute TM steady state before OG walking (mean of first steadyNumPts of last steadyNumPts+5 strides)
        if sum(strcmp(adaptData.metaData.conditionName, 're-adaptation'))~=0
            adapt2Data=adaptData.getParamInCond(params,'re-adaptation');
            tmsteady=[tmsteady; nanmean(adapt2Data((end-5)-steadyNumPts+1:(end-5),:))];
            
            % compute average adaptation of all adaptation walking (both
            % before and after catch)
            adaptAllData=adaptData.getParamInCond(params,{'adaptation','re-adaptation'});
            avgAdaptAll=[avgAdaptAll; nanmean(adaptAllData)];
        elseif sum(strcmp(adaptData.metaData.conditionName, 'adaptation'))~=0%For controls
            adapt2Data=adaptData.getParamInCond(params,'adaptation');
            tmsteady=[tmsteady; nanmean(adapt2Data((end-5)-steadyNumPts+1:(end-5),:))];
            
            % compute average adaptation of all adaptation walking (both
            % before and after catch)
            adaptAllData=adaptData.getParamInCond(params,{'adaptation'});
            avgAdaptAll=[avgAdaptAll; nanmean(adaptAllData)];
        else
            tmsteady= tmsteadyBC;
            adaptAllData=adaptData.getParamInCond(params,adaptData.metaData.conditionName(find(cellfun(@(x) ~isempty(x),(regexp(lower(adaptData.metaData.conditionName), 'ada'))), 1, 'first')));
            avgAdaptAll=NaN.*ones(s, length(params));%[avgAdaptAll; nanmean(adaptAllData)];
        end
        
        EarlyA=[EarlyA; nanmean(adapt1Data(EarlyStrides,:))];%NORMAL WAY
        %EarlyA=[EarlyA; nanmean(adapt1Data(1:5,:))];%NORMAL WAY
        %EarlyA=[EarlyA; nanmean(adapt1Data(6:10,:))];%NORMAL WAY
        %EarlyA=[EarlyA; nanmean(adapt1Data(1:20,:))];%New WAY
       %DeltaAdapt=[DeltaAdapt; nanmean(adapt2Data((end-5)-steadyNumPts+1:(end-5),:))-nanmean(adaptAllData(1:5,:))];
        DeltaAdapt=[DeltaAdapt; nanmean(adapt2Data((end-5)-steadyNumPts+1:(end-5),:))-EarlyA(s, :)];
        
        

        
        % Calculate Errors outside of baseline during adaptation
        mu=nanmean(TMbaseData);
        sigma=nanstd(TMbaseData);
        upperS=mu+2.*sigma;
        lowerS=mu-2.*sigma;
        for i=1:length(params)
            outside(i)=sum(adapt1Data(:,i)>upperS(i) | adapt1Data(:,i)<lowerS(i));
        end
        errorsOut=[errorsOut; 100.*(outside./size(adapt1Data,1))];
        
        %If inclince decline then flat post -- NEw
        if ~isempty(find(cellfun(@(x) ~isempty(x),(regexp(lower(adaptData.metaData.conditionName), lower('flat post'))))))
            FlatWashoutData=adaptData.getParamInCond(params,'flat post');
            FlatWash=[FlatWash; nanmean(FlatWashoutData(1:transientNumPts,:))];
        else
            FlatWash=[FlatWash; NaN.*ones(1, length(params))];
        end
    end
    %Calcualte Extent of Adaptation if Appropriate
    if ~isempty(find(strcmp(params, 'velocityContributionNorm2'))) && ~isempty(find(strcmp(params, 'netContributionNorm2')))
        NetIndex=find(strcmp(params, 'netContributionNorm2'));
        VelIndex=find(strcmp(params, 'velocityContributionNorm2'));
        NetSS=tmsteady(:, NetIndex);
            VelSS= tmsteady(:, VelIndex);
            
            ExtentA=repmat([NetSS-VelSS], 1, length(params));
        else
            ExtentA=NaN.*tmsteady;
        end
    %calculate relative after-effects
    
    %     transfer=[transfer; 100*(ogafter./(tmcatch(:,3)*ones(1,3)))];
    idx = find(strcmp(params, 'stepLengthAsym'));
    if isempty(strcmp(adaptData.metaData.conditionName, 'OG post'))
        if ~isempty(idx)
            transfer=[transfer; 100*(ogafter./(tmCatch(:,idx)*ones(1,length(params))))];
        else
            transfer=[transfer; 100*(ogafter./tmCatch)];
        end
        
        transfer2=[transfer2; 100*(ogafter./tmsteady)];
    else
        transfer=NaN.*ones(s, length(params));%[transfer; NaN];
        transfer2=NaN.*ones(s, length(params));%[transfer2; NaN];
    end
    washout=[washout; 100-(100*(tmafter./tmCatch))];
    washout2=[washout2; 100-(100*(tmafter./tmsteady))];
    plearn=[plearn; (100*(tmafter./tmsteady))];
    
    nSubs=length(subjects);
    
    results.OGbase.avg(end+1,:)=nanmean(OGbase,1);
    results.OGbase.se(end+1,:)=nanstd(OGbase)./sqrt(nSubs);
    
    results.TMbase.avg(end+1,:)=nanmean(TMbase,1);
    results.TMbase.se(end+1,:)=nanstd(TMbase);
    
    results.AvgAdaptBeforeCatch.avg(end+1,:)=nanmean(avgAdaptBC,1);
    results.AvgAdaptBeforeCatch.se(end+1,:)=nanstd(avgAdaptBC)./sqrt(nSubs);
    
    results.AvgAdaptAll.avg(end+1,:)=nanmean(avgAdaptAll,1);
    results.AvgAdaptAll.se(end+1,:)=nanstd(avgAdaptAll)./sqrt(nSubs);
    
    results.ErrorsOut.avg(end+1,:)=nanmean(errorsOut,1);
    results.ErrorsOut.se(end+1,:)=nanstd(errorsOut)./sqrt(nSubs);
    
    results.TMsteadyBeforeCatch.avg(end+1,:)=nanmean(tmsteadyBC,1);
    results.TMsteadyBeforeCatch.se(end+1,:)=nanstd(tmsteadyBC)./sqrt(nSubs);
    
    results.catch.avg(end+1,:)=nanmean(tmCatch,1);
    results.catch.se(end+1,:)=nanstd(tmCatch)./sqrt(nSubs);
    
    results.TMsteady.avg(end+1,:)=nanmean(tmsteady,1);
    results.TMsteady.se(end+1,:)=nanstd(tmsteady)./sqrt(nSubs);
    
    results.OGafter.avg(end+1,:)=nanmean(ogafter,1);
    results.OGafter.se(end+1,:)=nanstd(ogafter)./sqrt(nSubs);
    
    results.TMafter.avg(end+1,:)=nanmean(tmafter,1);
    results.TMafter.se(end+1,:)=nanstd(tmafter)./sqrt(nSubs);
    
    results.TMafterEVEN.avg(end+1,:)=nanmean(tmafterEVEN,1);
    results.TMafterEVEN.se(end+1,:)=nanstd(tmafterEVEN)./sqrt(nSubs);
    results.TMafterODD.avg(end+1,:)=nanmean(tmafterODD,1);
    results.TMafterODD.se(end+1,:)=nanstd(tmafterODD)./sqrt(nSubs);
    
    results.Transfer.avg(end+1,:)=nanmean(transfer,1);
    results.Transfer.se(end+1,:)=nanstd(transfer)./sqrt(nSubs);
    
    results.Washout.avg(end+1,:)=nanmean(washout,1);
    results.Washout.se(end+1,:)=nanstd(washout)./sqrt(nSubs);
    
    results.Transfer2.avg(end+1,:)=nanmean(transfer2,1);
    results.Transfer2.se(end+1,:)=nanstd(transfer2)./sqrt(nSubs);
    
    results.Washout2.avg(end+1,:)=nanmean(washout2,1);
    results.Washout2.se(end+1,:)=nanstd(washout2)./sqrt(nSubs);
   
        results.BFWashout.avg(end+1,:)=nanmean(    BFWashout,1);
    results.BFWashout.se(end+1,:)=nanstd(    BFWashout)./sqrt(nSubs);
    
            results.DeltaAdapt.avg(end+1,:)=nanmean(    DeltaAdapt,1);
    results.DeltaAdapt.se(end+1,:)=nanstd(    DeltaAdapt)./sqrt(nSubs);
                results.DeltaDeAdapt.avg(end+1,:)=nanmean(    DeltaDeAdapt,1);
    results.DeltaDeAdapt.se(end+1,:)=nanstd(    DeltaDeAdapt)./sqrt(nSubs);
    
        results.FlatWash.avg(end+1,:)=nanmean(    FlatWash,1);
    results.FlatWash.se(end+1,:)=nanstd(FlatWash)./sqrt(nSubs);
    
            results.PLearn.avg(end+1,:)=nanmean(plearn ,1);
    results.PLearn.se(end+1,:)=nanstd(plearn)./sqrt(nSubs);
            
    results.EarlyA.avg(end+1,:)=nanmean(EarlyA,1);
    results.EarlyA.se(end+1,:)=nanstd(EarlyA,1)./sqrt(nSubs);
    
        results.ExtentA.avg(end+1,:)=nanmean(ExtentA,1);
    results.ExtentA.se(end+1,:)=nanstd(ExtentA,1)./sqrt(nSubs);
    if g==1 %This seems ridiculous, but I don't know of another way to do it without making MATLAB mad. The results.(whatever).indiv structure needs to be in this format to make life easier for using SPSS
        for p=1:length(params)
            results.OGbase.indiv.(params{p})=[g*ones(nSubs,1) OGbase(:,p)];
            results.TMbase.indiv.(params{p})=[g*ones(nSubs,1) TMbase(:,p)];
            results.AvgAdaptBeforeCatch.indiv.(params{p})=[g*ones(nSubs,1) avgAdaptBC(:,p)];
            results.AvgAdaptAll.indiv.(params{p})=[g*ones(nSubs,1) avgAdaptAll(:,p)];
            results.ErrorsOut.indiv.(params{p})=[g*ones(nSubs,1) errorsOut(:,p)];
            results.TMsteadyBeforeCatch.indiv.(params{p})=[g*ones(nSubs,1) tmsteadyBC(:,p)];
            results.catch.indiv.(params{p})=[g*ones(nSubs,1) tmCatch(:,p)];
            results.TMsteady.indiv.(params{p})=[g*ones(nSubs,1) tmsteady(:,p)];
            results.OGafter.indiv.(params{p})=[g*ones(nSubs,1) ogafter(:,p)];
            results.TMafter.indiv.(params{p})=[g*ones(nSubs,1) tmafter(:,p)];
            results.TMafterEVEN.indiv.(params{p})=[g*ones(nSubs,1) tmafterEVEN(:,p)];
            results.TMafterODD.indiv.(params{p})=[g*ones(nSubs,1) tmafterODD(:,p)];
            results.TMafter.indiv.(params{p})=[g*ones(nSubs,1) tmafter(:,p)];
            results.Transfer.indiv.(params{p})=[g*ones(nSubs,1) transfer(:,p)];
            results.Washout.indiv.(params{p})=[g*ones(nSubs,1) washout(:,p)];
            results.Transfer2.indiv.(params{p})=[g*ones(nSubs,1) transfer2(:,p)];
            results.Washout2.indiv.(params{p})=[g*ones(nSubs,1) washout2(:,p)];
            results.BFWashout.indiv.(params{p})=[g*ones(nSubs,1)     BFWashout(:,p)];
             results.DeltaAdapt.indiv.(params{p})=[g*ones(nSubs,1)     DeltaAdapt(:,p)];
              results.DeltaDeAdapt.indiv.(params{p})=[g*ones(nSubs,1)     DeltaDeAdapt(:,p)];
             results.FlatWash.indiv.(params{p})=[g*ones(nSubs,1) FlatWash(:,p)];
             results.PLearn.indiv.(params{p})=[g*ones(nSubs,1) plearn(:,p)];
             results.EarlyA.indiv.(params{p})=[g*ones(nSubs,1) EarlyA(:,p)];
             results.ExtentA.indiv.(params{p})=[g*ones(nSubs,1) EarlyA(:,p)];
            %             results.OGbase.indiv=[g*ones(nSubs,1) OGbase];
            %             results.TMbase.indiv=[g*ones(nSubs,1) TMbase];
            %             results.AvgAdaptBeforeCatch.indiv=[g*ones(nSubs,1) avgAdaptBC];
            %             results.AvgAdaptAll.indiv=[g*ones(nSubs,1) avgAdaptAll];
            %             results.ErrorsOut.indiv=[g*ones(nSubs,1) errorsOut];
            %             results.TMsteadyBeforeCatch.indiv=[g*ones(nSubs,1) tmsteadyBC];
            %             results.catch.indiv=[g*ones(nSubs,1) tmCatch];
            %             results.TMsteady.indiv=[g*ones(nSubs,1) tmsteady];
            %             results.OGafter.indiv=[g*ones(nSubs,1) ogafter];
            %             results.TMafter.indiv=[g*ones(nSubs,1) tmafter];
            %             results.Transfer.indiv=[g*ones(nSubs,1) transfer];
            %             results.Washout.indiv=[g*ones(nSubs,1) washout];
            %             results.Transfer2.indiv=[g*ones(nSubs,1) transfer2];
            %             results.Washout2.indiv=[g*ones(nSubs,1) washout2];
        end
    else
        for p=1:length(params)
            results.OGbase.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) OGbase(:,p)];
            results.TMbase.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) TMbase(:,p)];
            results.AvgAdaptBeforeCatch.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) avgAdaptBC(:,p)];
            results.AvgAdaptAll.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) avgAdaptAll(:,p)];
            results.ErrorsOut.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) errorsOut(:,p)];
            results.TMsteadyBeforeCatch.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) tmsteadyBC(:,p)];
            results.catch.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) tmCatch(:,p)];
            results.TMsteady.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) tmsteady(:,p)];
            results.OGafter.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) ogafter(:,p)];
            results.TMafter.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) tmafter(:,p)];
            results.TMafterEVEN.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) tmafterEVEN(:,p)];
            results.TMafterODD.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) tmafterODD(:,p)];
            results.Transfer.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) transfer(:,p)];
            results.Washout.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) washout(:,p)];
            results.Transfer2.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) transfer2(:,p)];
            results.Washout2.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) washout2(:,p)];
            results.BFWashout.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1)     BFWashout(:,p)];
            results.DeltaAdapt.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1)     DeltaAdapt(:,p)];
            results.DeltaDeAdapt.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1)     DeltaDeAdapt(:,p)];
            results.FlatWash.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1)     FlatWash(:,p)];
            results.PLearn.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1)     plearn(:,p)];
            results.EarlyA.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) EarlyA(:,p)];
            results.ExtentA.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) ExtentA(:,p)];
            %             results.OGbase.indiv(end+1:end+nSubs,:)=[g*ones(nSubs,1) OGbase];
            %             results.TMbase.indiv(end+1:end+nSubs,:)=[g*ones(nSubs,1) TMbase];
            %             results.AvgAdaptBeforeCatch.indiv(end+1:end+nSubs,:)=[g*ones(nSubs,1) avgAdaptBC];
            %             results.AvgAdaptAll.indiv(end+1:end+nSubs,:)=[g*ones(nSubs,1) avgAdaptAll];
            %             results.ErrorsOut.indiv(end+1:end+nSubs,:)=[g*ones(nSubs,1) errorsOut];
            %             results.TMsteadyBeforeCatch.indiv(end+1:end+nSubs,:)=[g*ones(nSubs,1) tmsteadyBC];
            %             results.catch.indiv(end+1:end+nSubs,:)=[g*ones(nSubs,1) tmCatch];
            %             results.TMsteady.indiv(end+1:end+nSubs,:)=[g*ones(nSubs,1) tmsteady];
            %             results.OGafter.indiv(end+1:end+nSubs,:)=[g*ones(nSubs,1) ogafter];
            %             results.TMafter.indiv(end+1:end+nSubs,:)=[g*ones(nSubs,1) tmafter];
            %             results.Transfer.indiv(end+1:end+nSubs,:)=[g*ones(nSubs,1) transfer];
            %             results.Washout.indiv(end+1:end+nSubs,:)=[g*ones(nSubs,1) washout];
            %             results.Transfer2.indiv(end+1:end+nSubs,:)=[g*ones(nSubs,1) transfer2];
            %             results.Washout2.indiv(end+1:end+nSubs,:)=[g*ones(nSubs,1) washout2];
        end
    end
end

%stats
if size(groups)==1
    resultNames=fieldnames(results);
for h=1:length(resultNames)
    for i=1:size(results.TMsteady.avg, 2)%size(StatReady, 2)
    [~, results.(resultNames{h}).p(i)]=ttest(results.(resultNames{h}).indiv.(params{i})(:, 2));
    end
end
end

% %stats
% resultNames=fieldnames(results);
% %if StatFlag==1
% namest=[];
% for h=1:length(resultNames)
%     group1=find(results.(resultNames{h}).indiv.(params{1})(:, 1)==1);
%     group2=find(results.(resultNames{h}).indiv.(params{1})(:, 1)==2);
%     for gg=1:length(results.(resultNames{h}).indiv.(params{1})(:, 2))
%         namest{gg}=[groups{results.(resultNames{h}).indiv.(params{1})(gg, 1)}];
%     end
%     for i=1:size(results.TMsteady.avg, 2)%size(StatReady, 2)
%         [~, results.(resultNames{h}).p(i)]=ttest(results.(resultNames{h}).indiv.(params{i})(:, 2));
%     end
% end
% close all

StatFlag=1;
resultNames=fieldnames(results);
indiData=[];
for h=1:length(resultNames)
    for i=1:size(results.TMsteady.avg, 2)%size(StatReady, 2)
        if size(results.TMsteady.avg, 1)==2 && length(find(results.(resultNames{h}).indiv.(params{i})(:, 1)==1))==length(find(results.(resultNames{h}).indiv.(params{i})(:, 1)==2))%Can just used a ttest, which will be PAIRED
            Group1=find(results.(resultNames{h}).indiv.(params{i})(:, 1)==1);
            Group2=find(results.(resultNames{h}).indiv.(params{i})(:, 1)==2);
            [~, results.(resultNames{h}).p(i)]=ttest(results.(resultNames{h}).indiv.(params{i})(Group1, 2), results.(resultNames{h}).indiv.(params{i})(Group2, 2));
        else% have to do an anova
            [results.(resultNames{h}).p(i), ~, stats]=anova1(results.(resultNames{h}).indiv.(params{i})(:, 2), results.(resultNames{h}).indiv.(params{i})(:, 1), 'off');
        end
    end
end

close all
%if StatFlag==1
for h=1:length(resultNames)
    for i=1:size(results.TMsteady.avg, 2)%size(StatReady, 2)
        if size(results.TMsteady.avg, 1)==2 %Can just used a ttest, which will be PAIRED
            Group1=find(results.(resultNames{h}).indiv.(params{i})(:, 1)==1);
            Group2=find(results.(resultNames{h}).indiv.(params{i})(:, 1)==2);
            %[~, results.(resultNames{h}).p(i)]=ttest(results.(resultNames{h}).indiv.(params{i})(Group1, 2), results.(resultNames{h}).indiv.(params{i})(Group2, 2));
        else% have to do an anova
            [results.(resultNames{h}).p(i), ~, stats]=anova1(results.(resultNames{h}).indiv.(params{i})(:, 2), results.(resultNames{h}).indiv.(params{i})(:, 1), 'off');
            results.(resultNames{h}).postHoc{i}=[NaN NaN];
            if results.(resultNames{h}).p(i)<=0.05 && exist('stats')==1
                [c,~,~,gnames]=multcompare(stats, 'CType', 'lsd');
                results.(resultNames{h}).postHoc{i}=c(find(c(:,6)<=0.05), 1:2);
                %postHoc{i-1, h}=c(find(c(:,6)<=0.05), 1:2);
            end
        end
    end
end
% p(1)=[];
%end
close all

%plot stuff
if nargin>4 && plotFlag
    epochs={ 'TMsteady','EarlyA','TMafter','DeltaAdapt','DeltaDeAdapt'};
    %epochs={'TMsteady', 'catch','TMafter'};
   %epochs={'DeltaAdapt','DeltaDeAdapt','DeltaAdapt','DeltaDeAdapt','DeltaAdapt','DeltaDeAdapt'};
    %epochs={'DeltaAdapt'};% Incline Decline
    %epochs={'TMsteady','EarlyA' ,'DeltaAdapt','ExtentA', 'TMafter'};%, 'DeltaAdapt'};% Incline Decline
    %epochs={'TMsteady', 'catch',  'TMafter'};% Incline Decline
    %epochs={'DeltaAdapt', 'catch','TMsteady','BFWashout', 'TMafter'};% BF
    %epochs={'TMbase', 'TMsteady','catch', 'BFWashout', 'TMafter'};% BF
    %epochs={'TMafter', 'TMafter','TMafter', 'TMafter', 'TMafter','TMafter'};% BF
    if nargin>5 %I imagine there has to be a better way to do this...
        barGroups(SMatrix,results,groups,params,epochs,indivFlag)
    else
        barGroups(SMatrix,results,groups,params,epochs)
    end
    
    %     % SECOND: plot average adaptation values?
    %     epochs={'AvgAdaptBeforeCatch','TMsteadyBeforeCatch','AvgAdaptAll','TMsteady'};
    %     if nargin>5
    %         barGroups(SMatrix,results,groups,params,epochs,indivFlag)
    %     else
    %         barGroups(SMatrix,results,groups,params,epochs)
    %     end
    
    %     % SECOND: plot average adaptation values?
    %     epochs={'AvgAdaptAll','TMsteady','catch','Transfer'};
    %     if nargin>5
    %         barGroups(SMatrix,results,groups,params,epochs,indivFlag)
    %     else
    %         barGroups(SMatrix,results,groups,params,epochs)
    %     end
end


