function PlottedMean=plotAvgTimeCourseSingle(adaptDataList,params,conditions,binwidth,trialMarkerFlag,indivFlag,indivSubs,colorOrder,biofeedback,removeBiasFlag,labels,medianFlag,plotHandles, row, col, sub)
%adaptDataList must be cell array of 'param.mat' file names
%params is cell array of parameters to plot, or cell array of adaptationData objects. List with commas to
%plot on separate graphs or with semicolons to plot on same graph.
%conditions is cell array of conditions to plot
%binwidth is the number of data points to average in time
%indivFlag - set to true to plot individual subject time courses
%indivSubs - must be a cell array of 'param.mat' file names that is
%a subset of those in the adaptDataList. Plots specific subjects
%instead of all subjects.
%
% figHandle = plotAvgTimeCourse(adaptDataList,params,conditions,binwidth,trialMarkerFlag,indivFlag,indivSubs)
% [Avg, Indiv] = plotAvgTimeCourse(figHandle,adaptDataList,params,conditions,binwidth,trialMarkerFlag)


%% Check inputs

% See if adaptDataList is a single subject (char), a cell
% array of subject names (one group of subjects), or a cell array of cell arrays of
% subjects names (several groups of subjects), and put all the
% cases into the same format
if isa(adaptDataList,'cell')
    if ~isa(adaptDataList{1},'cell')
        adaptDataList={adaptDataList};
    end
elseif isa(adaptDataList,'char') || isa(adaptDataList,'adaptationData')
    adaptDataList={{adaptDataList}};
end
legacyVersion=false;
if isa(adaptDataList{1}{1},'char')
    legacyVersion=true;
end
Ngroups=length(adaptDataList);

% make sure params is a cell array
if isa(params,'char')
    params={params};
end

% check condition input %TO DO: allow for condition numbers
if nargin>2
    if isa(conditions,'char')
        conditions={conditions};
    end
else
    if ~legacyVersion
        conditions=adaptDataList{1}{1}.metaData.conditionName; %default
    else
        error('No condition list provided')
    end
end
nConds=length(conditions);
cond=cell(1,nConds);
for c=1:nConds
    if isa(conditions{c},'cell')
        cond{c}=conditions{c}{1}(ismember(conditions{c}{1},['A':'Z' 'a':'z' '0':'9']));
    elseif isa(conditions{c},'char')
        cond{c}=conditions{c}(ismember(conditions{c},['A':'Z' 'a':'z' '0':'9'])); %remove non alphanumeric characters
    else
        error('Conditions argument is neither a string, a cell array of strings or a cell array of cell array of strings.')
    end
end


if nargin<4 || isempty(binwidth)
    binwidth=1; %default
end

if nargin<5 || length(trialMarkerFlag)~=length(cond)
    trialMarkerFlag=false(1,length(cond));
end

if nargin<6 || isempty(indivFlag)
    indivFlag=false;
end

if nargin>6
    if isa(indivSubs,'cell') && ~isempty(indivSubs)
        if ~isa(indivSubs{1},'cell')
            indivSubs{1}=indivSubs;
        end
    elseif isa(indivSubs,'char')
        indivSubs{1}={indivSubs};
    end
end

% if nargin<9
maxNumPts=false; %set to true to plot the maximum number of strides per trial/condition
%otherwise, the subject with the fewest strides in a particular trial/condition
%determines the number of strides plotted.
% end
if nargin<10 || isempty(removeBiasFlag)
    removeBiasFlag=0;
end

if nargin<12 || isempty(medianFlag)
    medianFlag=0;
end
%% Initialize plot

% axesFontSize=14;
% labelFontSize=0;
% titleFontSize=24;
axesFontSize=10;
labelFontSize=0;
titleFontSize=12;
% if  nargin<13 || isempty(plotHandles) || length(plotHandles)~=length(params)
%     [ah,figHandle]=optimizedSubPlot(size(params,2),4,1,'tb',axesFontSize,labelFontSize,titleFontSize);
% else
%     ah=plotHandles;
%     figHandle=gcf;
% end
legendStr=cell(1);
if isempty(colorOrder)==1
    poster_colors;
    if length(labels)==3
        colorOrder=[p_red;  p_orange; p_fade_green; p_fade_blue; p_plum; p_green; p_blue; p_fade_red; p_lime; p_yellow; [0 0 0]; p_red; p_orange; p_fade_green; p_fade_blue; p_plum];
    elseif length(labels)==2
        colorOrder=[ p_orange; p_fade_green;p_fade_blue; p_plum; p_green; p_blue; p_fade_red; p_lime; p_yellow; [0 0 0]; p_red; p_orange; p_fade_green; p_fade_blue; p_plum];
    end
end

% % Set colors order
% if nargin<8 || isempty(colorOrder) || size(colorOrder,2)~=3
%     poster_colors;
%     colorOrder=[p_red; p_orange; p_fade_green; p_fade_blue; p_plum; p_green; p_blue; p_fade_red; p_lime; p_yellow; [0 0 0]];
% end

lineOrder={'-','--','-.',':'};

%% determine length of trials or conditions
s=1; %subject counter
values=struct([]);
for group=1:Ngroups
    for subject=1:length(adaptDataList{group})
        %Load subject
        adaptData = adaptDataList{group}{subject};
        if legacyVersion
            load(adaptData);
        end
        adaptData = adaptData.removeBadStrides;
        if removeBiasFlag==1
            adaptData = adaptData.removeBias;
        elseif removeBiasFlag==2
            adaptData = adaptData.removeBias({'slow', 'slow'});%CJS to make like OGAWA 2014
            %adaptData = adaptData.normalizeBias;
        elseif removeBiasFlag==3
            adaptData = adaptData.removeBias({'fast', 'fast'});%CJS to make like OGAWA 2014
        end
        
        for c=1:nConds
            if trialMarkerFlag(c)
                trials=num2cell(adaptData.getTrialsInCond({conditions{c}}));
            else
                trials={adaptData.getTrialsInCond({conditions{c}})}; %all trials in the condition are one "trial"
                if  length(trials{1})>1 && isempty(find(strcmp(conditions, 'slow')))==0%I only want to plot the last slow baseline collected because this is the one used for the mutliple linear coorelations
                    trials{:}(1)=[];%length(trials)>1 &&
                end
            end
            
            for t=1:length(trials)
                %Check
                if ~all(adaptData.data.isaParameter(params))
                    keyboard %This shouldnt happen
                end
                dataPts=adaptData.getParamInTrial(params,trials{t});
                nPoints=size(dataPts,1);
                if nPoints == 0
                    numPts.(cond{c}).(['trial' num2str(t)])(s)=NaN;
                else
                    numPts.(cond{c}).(['trial' num2str(t)])(s)=nPoints;
                end
                for p=1:length(params)
                    %itialize so there are no inconsistant dimensions or out of bounds errors
                    values(group).(params{p}).(cond{c}).(['trial' num2str(t)])(subject,:)=NaN(1,2000); %this assumes that the max number of data points that could exist in a single conition or trial is 2000
                    
                    %                     %%VELOCITY CONTRIBUTION IS FLIPPED HERE
                    %                     if strcmp(params{p},'velocityContribution')
                    %                         values(group).(params{p}).(cond{c}).(['trial' num2str(t)])(subject,1:nPoints)=-dataPts(:,p);
                    %                     else
                    values(group).(params{p}).(cond{c}).(['trial' num2str(t)])(subject,1:nPoints)=dataPts(:,p);
                    %                     end
                end
            end
        end
        s=s+1;
    end
end

%% Do the actual plotting
Li=cell(1);
avg=struct([]);
se=struct([]);
indiv=struct([]);

for group=1:Ngroups
    Xstart=1;
    lineX=0;
    for c=1:nConds
        for t=1:length(fields(values(group).(params{p}).(cond{c})))
            
            % 1) find the length of each trial
            if maxNumPts
                %to plot the MAX number of pts in each trial:
                [maxPts,loc]=nanmax(numPts.(cond{c}).(['trial' num2str(t)]));
                while maxPts>1.25*nanmax(numPts.(cond{c}).(['trial' num2str(t)])([1:loc-1 loc+1:end]))
                    numPts.(cond{c}).(['trial' num2str(t)])(loc)=nanmean(numPts.(cond{c}).(['trial' num2str(t)])([1:loc-1 loc+1:end])); %do not include min in mean (?)
                    [maxPts,loc]=nanmax(numPts.(cond{c}).(['trial' num2str(t)]));
                end
                if maxPts==0
                    continue
                end
            else
                %to plot the MIN number of pts in each trial:
                [maxPts,loc]=nanmin(numPts.(cond{c}).(['trial' num2str(t)]));
                while maxPts<0.75*nanmin(numPts.(cond{c}).(['trial' num2str(t)])([1:loc-1 loc+1:end]))
                    numPts.(cond{c}).(['trial' num2str(t)])(loc)=nanmean(numPts.(cond{c}).(['trial' num2str(t)])([1:loc-1 loc+1:end])); %do not include min in mean (?)
                    [maxPts,loc]=nanmin(numPts.(cond{c}).(['trial' num2str(t)]));
                end
                if maxPts==0
                    continue
                end
            end
            
            for p=1:length(params)
                
                if ~isnan(maxPts)%do not try to plot if maxPts is NaN, this indicates that there is no c3d for this trial
                    allValues=values(group).(params{p}).(cond{c}).(['trial' num2str(t)])(:,1:maxPts);
                else
                    allValues = NaN;%set plot values to NaN when there is no c3d data
                end
                
                % 2) average across subjuects within bins
                
                %Find (running) averages and standard deviations for bin data
                start=1:size(allValues,2)-(binwidth-1);
                stop=start+binwidth-1;
                %                 %Find (simple) averages and standard deviations for bin data
                %                 start = 1:binwidth:(size(allValues,2)-binwidth+1);
                %                 stop = start+(binwidth-1);
                
                for i = 1:length(start)
                    t1 = start(i);
                    t2 = stop(i);
                    bin = allValues(:,t1:t2);
                    
                    if length(adaptDataList{group})>1
                        %errors calculated as standard error of averaged subject points
                        if medianFlag==0
                            subBin=nanmean(bin,2);
                        else
                            subBin=nanmedian(bin,2);
                        end
                        if medianFlag==0
                            avg(group).(params{p}).(cond{c}).(['trial' num2str(t)])(i)=nanmean(subBin);
                            se(group).(params{p}).(cond{c}).(['trial' num2str(t)])(i)=nanstd(subBin)/sqrt(length(subBin));
                        else %Using median and 15.87-84.13 percentiles
                            avg(group).(params{p}).(cond{c}).(['trial' num2str(t)])(i)=nanmedian(subBin);
                            se(group).(params{p}).(cond{c}).(['trial' num2str(t)])(i)=.5*diff(prctile(subBin,[16,84]))/sqrt(length(subBin));
                        end
                        indiv(group).(params{p}).(cond{c}).(['trial' num2str(t)])(:,i)=subBin;
                    else
                        %errors calculated as standard error of all data
                        %points within a bin
                        if medianFlag==0
                            avg(group).(params{p}).(cond{c}).(['trial' num2str(t)])(i)=nanmean(reshape(bin,1,numel(bin)));
                            indiv(group).(params{p}).(cond{c}).(['trial' num2str(t)])(:,i)=nanmean(bin,2);
                            se(group).(params{p}).(cond{c}).(['trial' num2str(t)])(i)=nanstd(reshape(bin,1,numel(bin)))/sqrt(binwidth);
                        else
                            avg(group).(params{p}).(cond{c}).(['trial' num2str(t)])(i)=nanmedian(reshape(bin,1,numel(bin)));
                            indiv(group).(params{p}).(cond{c}).(['trial' num2str(t)])(:,i)=nanmedian(bin,2);
                            se(group).(params{p}).(cond{c}).(['trial' num2str(t)])(i)=.5*diff(prctile(reshape(bin,1,numel(bin)),[16,84]))/sqrt(binwidth);
                        end
                    end
                end
                
                % 3) plot data
                subplot(row, col, sub)
                g=group;
                Cdiv=1;
                
                
                hold on
                afterTrialPad=5; %adds empty sapce to end of trial/condition (in strides)
                y=[avg(group).(params{p}).(cond{c}).(['trial' num2str(t)]), NaN(1,afterTrialPad)];
                E=[se(group).(params{p}).(cond{c}).(['trial' num2str(t)]), NaN(1,afterTrialPad)];
                condLength=length(y);
                x=Xstart:Xstart+condLength-1;
                
                %Biofeedback
                if nargin>8 && ~isempty(biofeedback)
                    if biofeedback==1 && strcmp(params{p},'alphaFast')
                        w=adaptData{group}{1}.getParamInCond('TargetHitR',conditions{c});
                    elseif biofeedback==1 &&  strcmp(params{p},'alphaSlow')
                        w=adaptData{group}{1}.getParamInCond('TargetHitL',conditions{c});
                    elseif biofeedback==0
                        biofeedback=[];
                    else
                        w=adaptData.getParamInCond('TargetHit',conditions{c});
                    end
                else
                    biofeedback=[];
                end
                
                if indivFlag %plotting all individual subjects
                    nSubs=length(adaptDataList{group});
                    subjects=cell(1,nSubs);
                    for s=1:nSubs
                        if ~legacyVersion
                            subjects{s}=adaptDataList{group}{s}.subData.ID;
                        else
                            subjects{s}=adaptDataList{group}{s}(1:end-6);
                        end
                    end
                    if ~isempty(indivSubs) && ~isempty(indivSubs{group}{1}) %plot specific individual subjects
                        subsToPlot=indivSubs{group};
                    else
                        subsToPlot=adaptDataList{group};
                    end
                    for s=1:length(subsToPlot)
                        if ~legacyVersion
                            id=subsToPlot{s}.subData.ID;
                        else
                            id=subsToPlot{s}(1:end-6);
                        end
                        subInd=find(ismember(subjects,id),1,'first');
                        y_ind=[indiv(group).(params{p}).(cond{c}).(['trial' num2str(t)])(subInd,:), NaN(1,afterTrialPad)];
                        %%to plot as dots:
                        %plot(x,y_ind,'o','MarkerSize',3,'MarkerEdgeColor',colorOrder(subInd,:),'MarkerFaceColor',colorOrder(subInd,:));
                        %%to plot as lines:
                        Li{group}(s)=plot(x,y_ind,lineOrder{g},'color',colorOrder(mod(subInd-1,size(colorOrder,1))+1,:),'Tag',id);
                        if ~legacyVersion
                            legendStr{group}(s)={subsToPlot{s}.subData.ID};
                        else
                            legendStr{group}(s)={subsToPlot{s}};
                        end
                    end
                    %plot average of group if there is more than one person
                    %in the group
                    if length(adaptDataList{group})>1
                        Li{group}(length(subsToPlot)+1)=plot(x,y,'o','MarkerSize',5,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.7 0.7 0.7].^group);
                        legendStr{group}(length(subsToPlot)+1)={['Average ' adaptDataList{group}{1}.metaData.ID]};
                    end
                else %only plot group averages
                    if Ngroups==1 && ~(size(params,1)>1) && isempty(biofeedback)  %one group (each condition colored different)
                        if isempty(biofeedback)
                            [Pa, Li{c}]=nanJackKnife(x,y,E,colorOrder(c,:),colorOrder(c,:)+0.5.*abs(colorOrder(c,:)-1),0.7);
                        else
                            [Pa, Li{c}]=nanJackKnife(x,y,E,colorOrder(c,:),colorOrder(c,:)+0.5.*abs(colorOrder(c,:)-1),0.7,w);
                        end
                        %set(Li{c},'Clipping','off')
                        H=get(Li{c},'Parent');
                        legendStr={adaptData.metaData.conditionName(adaptData.getConditionIdxsFromName(conditions))};
                    elseif size(params,1)>1 && isempty(biofeedback)%Each parameter colored differently (and shaded differently for different groups)
                        ind=(group-1)*size(params,1)+p;
                        color=colorOrder(mod(g-1,size(colorOrder,1))+1,:)./Cdiv;
                        [Pa, Li{ind}]=nanJackKnife(x,y,E,color,color+0.5.*abs(color-1),0.7);
                        %set(Li{ind},'Clipping','off')
                        H=get(Li{ind},'Parent');
                        legendStr{ind}=legStr;
                    elseif  isempty(biofeedback) %Each group colored differently
                        color=colorOrder(g,:)./Cdiv;
                        [Pa, Li{g}]=nanJackKnife(x,y,E,color,color+0.5.*abs(color-1),0.7);
                        %set(Li{g},'Clipping','off')
                        H=get(Li{g},'Parent');
                        if ~legacyVersion
                            if length(adaptDataList{g})>1
                                legendStr{g}={adaptDataList{g}{1}.metaData.ID};
                            else
                                legendStr{g}={adaptDataList{g}{1}.subData.ID};
                            end
                        else
                            if length(adaptDataList{g})>1
                                legendStr{g}={adaptDataList{g}{1}};
                            else
                                legendStr{g}={adaptDataList{g}{1}};
                            end
                            
                        end
                    elseif ~(size(params,1)>1) && ~isempty(biofeedback)
                        color=colorOrder(g,:)./Cdiv;
                        [Pa, Li{g}]=nanJackKnife(x,y,E,color,color+0.5.*abs(color-1),0.7,w);
                        %set(Li{g},'Clipping','off')
                        H=get(Li{g},'Parent');
                        group=adaptData{g}{1}.subData.ID;
                        abrevGroup=[group];
                        legendStr{g}={[ abrevGroup]};
                    elseif Ngroups==1 && ~(size(params,1)>1) && ~isempty(biofeedback)
                        [Pa, Li{c}]=nanJackKnife(x,y,E,colorOrder(c,:),colorOrder(c,:)+0.5.*abs(colorOrder(c,:)-1),0.7,w);
                        %set(Li{c},'Clipping','off')
                        H=get(Li{c},'Parent');
                        legendStr={conditions};
                    elseif ~(size(params,1)>1) && ~isempty(biofeedback)
                        color=colorOrder(g,:)./Cdiv;
                        [Pa, Li{g}]=nanJackKnife(x,y,E,color,color+0.5.*abs(color-1),0.7,w);
                        %set(Li{g},'Clipping','off')
                        H=get(Li{g},'Parent');
                        load([adaptDataList{g}{1,1}])
                        group=adaptData.subData.ID;
                        abrevGroup=[group];
                        legendStr{g}={[ abrevGroup]};
                    end
                    %set(Pa,'Clipping','off')
                    set(H,'Layer','top')
                end
                
                PlottedMean{group, c}=y;
         
            end
            if sum(strcmp(conditions, 'adaptation'))~=0 && find(strcmp(conditions, 'adaptation'))==c && group==nanmax(Ngroups)% CJS 5/7/2018 
                line([Xstart Xstart+100], [nanmax(y) nanmax(y)], 'Color', 'k', 'LineWidth', 3)
            end
            Xstart=Xstart+condLength;
        end

            
        if c==length(conditions) && group==Ngroups
            %on last iteration of conditions loop, add title and
            %vertical lines to seperate conditions
            for p=1:length(params)
                if ~(size(params,1)>1)
                    subplot(row, col, sub)
                    title(params{p},'fontsize',titleFontSize)
                else
                    subplot(row, col, sub)
                end
                axis tight
                line([lineX; lineX],ylim,'color','k')
                xticks=lineX+diff([lineX Xstart])./2;
                set(gca,'fontsize',axesFontSize,'Xlim',[0 Xstart],'Xtick', xticks, 'Xticklabel', adaptData.metaData.conditionName(adaptData.getConditionIdxsFromName(conditions)))
                %h=refline(0,0);
                %set(h,'color','k')
            end
            hold off
        end
        lineX(end+1)=Xstart-0.5;
    end
end

%linkaxes(ah,'x')
%set(gcf,'Renderer','painters');
if nargin<11 || isempty(labels) || indivFlag==1
    legend([Li{:}],[legendStr{:}]);
else
    labels={labels}';
    legend([Li{:}],[labels{:}]);
end
%% outputs
% if nargout<2
%     varargout{1}=figHandle;
% elseif nargout==2
%     varargout{1}=avg;
%     varargout{2}=indiv;
% elseif nargout==3
%     varargout{1}=figHandle;
%     varargout{2}=avg;
%     varargout{3}=indiv;
% else
%     varargout{1}=figHandle;
%     varargout{2}=avg;
%     varargout{3}=indiv;
%     varargout{4}=ah; %axes handles
% end