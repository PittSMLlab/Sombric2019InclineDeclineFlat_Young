function results = getForceResults( SMatrix,params,groups,maxPerturb,plotFlag,indivFlag, removeBias )
%This function returns a summary of groups level behavipr
%   For the inputed data (SMatrix) and groups (groups), for the specific
%   parameters (params) calculate the behavior at the defined epochs.

% define number of points to use for calculating values
catchNumPts = 3; %catch
steadyNumPts = 40; %end of adaptation
transientNumPts = 5; %OG and Washout
EarlyStrides=[1:5];


if nargin<3 || isempty(groups)
    groups=fields(SMatrix);  %default
end
ngroups=length(groups);

% Initialize values to calculate
results.DelFAdapt.avg=[];
results.DelFAdapt.se=[];

results.DelFDeAdapt.avg=[];
results.DelFDeAdapt.se=[];

results.DelFDeAdapt2Base.avg=[];
results.DelFDeAdapt2Base.se=[];

results.TMSteady.avg=[];
results.TMSteady.se=[];

results.TMafter.avg=[];
results.TMafter.se=[];

results.TMSteadyWBias.avg=[];
results.TMSteadyWBias.se=[];

results.TMafterWBias.avg=[];
results.TMafterWBias.se=[];

results.SlowBase.avg=[];
results.SlowBase.se=[];

results.FastBase.avg=[];
results.FastBase.se=[];

results.MidBase.avg=[];
results.MidBase.se=[];

results.BaseAdapDiscont.avg=[];
results.BaseAdapDiscont.se=[];

results.SS_PA_Discont.avg=[];
results.SS_PA_Discont.se=[];

results.BasePADiscont.avg=[];
results.BasePADiscont.se=[];

results.SpeedAdapDiscont.avg=[];
results.SpeedAdapDiscont.se=[];

results.SpeedSSDiscont.avg=[];
results.SpeedSSDiscont.se=[];

results.SpeedPADiscont.avg=[];
results.SpeedPADiscont.se=[];

results.EarlyA.avg=[];
results.EarlyA.se=[];

results.EarlyAish.avg=[];
results.EarlyAish.se=[];

results.EarlyAVar.avg=[];
results.EarlyAVar.se=[];

results.EarlyAWBias.avg=[];
results.EarlyAWBias.se=[];


results.DelFAPA.avg=[];
results.DelFAPA.se=[];


results.LateP.avg=[];
results.LateP.se=[];

results.Washout2.avg=[];
results.Washout2.se=[];

results.FlatWash.avg=[];
results.FlatWash.se=[];

results.PLearn.avg=[];
results.PLearn.se=[];

results.lenA.avg=[];
results.lenA.se=[];

results.SlowBasePosVar.avg=[];
results.SlowBasePosVar.se=[];
results.FastBasePosVar.avg=[];
results.FastBasePosVar.se=[];
results.TMSteadyPosVar.avg=[];
results.TMSteadyPosVar.se=[];
results.AllAdaptPosVar.avg=[];
results.AllAdaptPosVar.se=[];

results.SlowMediumBaseDiscont.avg=[];
results.SlowMediumBaseDiscont.se=[];
results.FastMediumBaseDiscont.avg=[];
results.FastMediumBaseDiscont.se=[];
results.RatioBaseDiscont.avg=[];
results.RatioBaseDiscont.se=[];

results.Height.avg=[];
results.Weight.avg=[];
results.Age.avg=[];
results.Male.avg=[];
results.RightLeg.avg=[];

results.EarlySlope.avg=[];
results.EarlySlope.se=[];
results.MiddleSlope.avg=[];
results.MiddleSlope.se=[];

results.FirstSteps.avg=[];
results.FirstSteps.se=[];
results.ShortExposure.avg=[];
results.ShortExposure.se=[];
results.ShortExposureAfter.avg=[];
results.ShortExposureAfter.se=[];

results.BaseShortExposureDiscont.avg=[];
results.BaseShortExposureDiscont.se=[];

results.EarlyShortExpoWBias.avg=[];
results.EarlyShortExpoWBias.se=[];

results.MBaseSL.avg=[];
results.MBaseSL.se=[];
results.MBaseSL_FLAT.avg=[];
results.MBaseSL_FLAT.se=[];


for g=1:ngroups
    
    % get subjects in group
    subjects=SMatrix.(groups{g}).ID;
    EarlyShortExpoWBias=[];
    DelFDeAdapt2Base=[];
    DelFAdapt=[];
    DelFDeAdapt=[];
    FBase=[];
    SBase=[];
    MBase=[];
    TMSteady=[];
    tmafter=[];
    BaseAdapDiscont=[];
    BasePADiscont=[];
    TMSteadyWBias=[];
    tmafterWBias=[];
    SpeedAdapDiscont=[];
    SpeedPADiscont=[];
    EarlyA=[];
    LateP=[];
    washout2=[];
    FlatWash=[];
    plearn=[];
    lenA=[];
    SpeedSSDiscont=[];
    EarlyAVar=[];
    SlowBasePosVar=[];
    FastBasePosVar=[];
    TMSteadyPosVar=[];
    AllAdaptPosVar=[];
    EarlyAWBias=[];
    SlowMediumBaseDiscont=[];
    FastMediumBaseDiscont=[];
    DelFAPA=[];
    Height=[];
    Weight=[];
    Age=[];
    Male=[];
    RightLeg=[];
    EarlySlope=[];
    MiddleSlope=[];
    FirstSteps=[];
    ShortExposure=[];
    ShortExposureAfter=[];
    BaseShortExposureDiscont=[];
    SS_PA_Discont=[];
    MBaseSL=[];
    MBaseSL_FLAT=[];
    EarlyAish=[];
    for s=1:length(subjects)
        % load subject
        adaptData=SMatrix.(groups{g}).adaptData{s};
        
        Height=[Height;adaptData.subData.height];
        Weight=[Weight;adaptData.subData.weight];
        Age=[Age; adaptData.subData.age];
        Male=[Male; strcmp(adaptData.subData.sex, 'Male')];
        RightLeg=[RightLeg; strcmp(adaptData.subData.dominantLeg, 'Right')];
        
        % remove baseline bias
        adaptData=adaptData.removeBadStrides;
        nSubs=length(subjects);
        
        %%Calculate Params
        %Paramerters with the BIAS included~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        if isempty(adaptData.metaData.conditionName{3})
            adaptData.metaData.conditionName{3}='';
            AANamesWBias=adaptData.metaData.conditionName(find(cellfun(@(x) ~isempty(x),(regexp(lower(adaptData.metaData.conditionName), 'ada'))), 1, 'first'));
            PANames=adaptData.metaData.conditionName(find(cellfun(@(x) ~isempty(x),(regexp(lower(adaptData.metaData.conditionName), 'ada'))), 1, 'first')+1);
            if strcmp(PANames, 'catch')
                PANames=adaptData.metaData.conditionName(find(cellfun(@(x) ~isempty(x),(regexp(lower(adaptData.metaData.conditionName), 'ada'))), 2, 'first')+1);
            end
        else
            AANamesWBias=adaptData.metaData.conditionName(find(cellfun(@(x) ~isempty(x),(regexp(lower(adaptData.metaData.conditionName), 'ada'))), 1, 'first'));
            PANames=adaptData.metaData.conditionName(find(cellfun(@(x) ~isempty(x),(regexp(lower(adaptData.metaData.conditionName), 'ada'))), 1, 'first')+1);
            if strcmp(PANames, 'catch')
                PANames=adaptData.metaData.conditionName(find(cellfun(@(x) ~isempty(x),(regexp(lower(adaptData.metaData.conditionName), 'ada'))), 2, 'first')+1);
            end
        end
        ADataWBias=adaptData.getParamInCond(params, AANamesWBias);
        
        PDataWBias=adaptData.getParamInCond(params,PANames);
        baseWBias=getEarlyLateData_v2(adaptData.removeBadStrides,params,{'TM base'},0,-40,5,10); %Last 40, exempting very last 5 and first 10
        baseWBias=nanmean(squeeze(baseWBias{1}));
        baseWBias(isnan(baseWBias))=0;
        if strcmp(groups(g), 'InclineStroke')
            EarlyPANamesWBias=adaptData.metaData.conditionName(find(cellfun(@(x) ~isempty(x),(regexp(lower(adaptData.metaData.conditionName), 'catch')))));
            LatePANamesWBias=adaptData.metaData.conditionName(find(cellfun(@(x) ~isempty(x),(regexp(lower(adaptData.metaData.conditionName), 'TM base')))));
            PDataEarlyWBias=adaptData.getParamInCond(params,EarlyPANamesWBias);
            PDataLateWBias=adaptData.getParamInCond(params,LatePANamesWBias);
        else
            PANamesWBias=adaptData.metaData.conditionName(find(cellfun(@(x) ~isempty(x),(regexp(lower(adaptData.metaData.conditionName), 'ada'))), 1, 'first')+1);
            if strcmp(PANamesWBias, 'catch')
                PANamesWBias=adaptData.metaData.conditionName(find(cellfun(@(x) ~isempty(x),(regexp(lower(adaptData.metaData.conditionName), 'ada'))), 2, 'first')+1);
            end
            PDataWBias=adaptData.getParamInCond(params,PANamesWBias);
        end
        
        if isempty(find(cellfun(@(x) ~isempty(x),(regexp(lower(adaptData.metaData.conditionName), 'fast')))))
            FBaseData=NaN*ones(1,length(params));
            Realfast=FBaseData;
        else
            FBaseData=adaptData.getParamInCond(params,'fast');
            if isempty(FBaseData)
                FBaseData=adaptData.getParamInCond(params,'fast base');
            end
            Realfast=getEarlyLateData_v2(adaptData.removeBadStrides,params,'fast',0,-40,5,10); %Last 40, exempting very last 5 and first 10
            Realfast=nanmean(squeeze(Realfast{1}));
        end
        
        if isempty(find(cellfun(@(x) ~isempty(x),(regexp(lower(adaptData.metaData.conditionName), 'slow')))))
            SBaseData=NaN*ones(1,length(params));
            Realslow=SBaseData;
        else
            SBaseData=adaptData.getParamInCond(params,'slow');
            if isempty(SBaseData)
                SBaseData=adaptData.getParamInCond(params,'slow base');
            end
            Realslow=getEarlyLateData_v2(adaptData.removeBadStrides,params,'slow',0,-40,5,10); %Last 40, exempting very last 5 and first 10
            Realslow=nanmean(squeeze(Realslow{1}));
        end
        
        if isempty(find(cellfun(@(x) ~isempty(x),(regexp(lower(adaptData.metaData.conditionName), 'tm base')))))
            MBaseData=NaN*ones(1,length(params));
            Realbase=MBaseData;
        else
            MBaseData=adaptData.getParamInCond(params,'TM base');
            Realbase=getEarlyLateData_v2(adaptData.removeBadStrides,params,'TM base',0,-40,5,10); %Last 40, exempting very last 5 and first 10
            Realbase=nanmean(squeeze(Realbase{1}));
        end
        
        
        FBase=[FBase; Realfast];
        SBase=[SBase; Realslow];
        MBase=[MBase; Realbase];
        
        RealbaseSL=getEarlyLateData_v2(adaptData.removeBadStrides,{'FyPSmax', 'FyPFmax'},'TM base',0,-40,5,10); %Last 40, exempting very last 5 and first 10
        RealbaseSL=nanmean(squeeze(RealbaseSL{1}));
        MBaseSL=[MBaseSL; ones(1,length(params)).*nanmean(RealbaseSL)];
        
        if isempty(find(cellfun(@(x) ~isempty(x),(regexp(lower(adaptData.metaData.conditionName), 'tm base flat')))))
            %display(adaptData.subData.ID)
            MBaseSL_FLAT=[MBaseSL_FLAT; ones(1,length(params)).*nanmean(RealbaseSL)];
        else
            RealbaseSL_FLAT=getEarlyLateData_v2(adaptData.removeBadStrides,{'FyPSmax', 'FyPFmax'},'TM base flat',0,-40,5,10); %Last 40, exempting very last 5 and first 10
            RealbaseSL_FLAT=nanmean(squeeze(RealbaseSL_FLAT{1}));
            MBaseSL_FLAT=[MBaseSL_FLAT; ones(1,length(params)).*nanmean(RealbaseSL_FLAT)];
            
        end
        
        % % %         %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        if  ~exist('removeBias') || removeBias==1
            adaptData=adaptData.removeBiasV3;
        end
        nSubs=length(subjects);
        % % %
        % % %         %%Calculate Params
        FirstTMnames=adaptData.metaData.conditionName(1);
        FirstTM=adaptData.getParamInCond(params, FirstTMnames);
        FirstSteps=[FirstSteps; nanmean(FirstTM(1:5,:))];
        
        ShortExpnames=adaptData.metaData.conditionName(find(cellfun(@(x) ~isempty(x),(regexp(lower(adaptData.metaData.conditionName), 'catch'))), 1, 'first'));
        ShortExp=adaptData.getParamInCond(params, ShortExpnames);
        ShortExposure=[ShortExposure; nanmean(ShortExp(:,:))];
        trialAfterShortExpo=adaptData.metaData.getTrialsInCondition(ShortExpnames)+1;
        ShortExposureAfterData=adaptData.getParamInTrial(params, trialAfterShortExpo);
        if isempty(ShortExposureAfterData)
            ShortExposureAfter=[ShortExposureAfter; NaN.*ones(1, length(params))];
        else
            ShortExposureAfter=[ShortExposureAfter; nanmean(ShortExposureAfterData(1:5, :))];
        end
        %Adaptation Paramerters~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        AANames=adaptData.metaData.conditionName(find(cellfun(@(x) ~isempty(x),(regexp(lower(adaptData.metaData.conditionName), 'ada'))), 1, 'first'));
        AData=adaptData.getParamInCond(params, AANames);
        
        EarlyA=[EarlyA; nanmean(AData(EarlyStrides,:))];%NORMAL WAY, conservative
        EarlyAish=[EarlyAish; nanmean(AData([6:10],:))];%NORMAL WAY, conservative
        EarlyAVar=[EarlyAVar;  nanmean(AData(EarlyStrides,:))]; %cjs
        
        lenA=[lenA; length(AData).*ones(1, length(params))];
        
        %%Linear Slope Approximations
        
        EarlySlope=[EarlySlope; (nanmean(AData(16:20,:))-nanmean(AData(1:5,:)))/4];
        MiddleSlope=[MiddleSlope; (nanmean(AData(6:10,:))-nanmean(AData(201:220,:)))];
        
        
        TMSteady=[TMSteady; nanmean(AData((end-5)-steadyNumPts+1:(end-5),:))];
        TMSteadyPosVar=[TMSteadyPosVar; nanvar(AData((end-5)-steadyNumPts+1:(end-5),:))];
        AllAdaptPosVar=[AllAdaptPosVar; nanvar(AData(6:(end-5),:))];
        DelFAdapt=[DelFAdapt; TMSteady(s, :)-EarlyA(s, :)];%NEW
        
        TMSteadyWBias=[TMSteadyWBias; nanmean(ADataWBias(end-44:end-5, :))];
        EarlyAWBias=[ EarlyAWBias; nanmean(ADataWBias(EarlyStrides, :))];
        EarlyShortExpoWBias=[ EarlyShortExpoWBias; nanmean(ShortExp(1:5, :))];
        %Post-Adaptation Paramerters~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        if strcmp(groups(g), 'InclineStroke')
            EarlyPANames=adaptData.metaData.conditionName(find(cellfun(@(x) ~isempty(x),(regexp(lower(adaptData.metaData.conditionName), 'catch')))));
            LatePANames=adaptData.metaData.conditionName(find(cellfun(@(x) ~isempty(x),(regexp(lower(adaptData.metaData.conditionName), 'TM base')))));
            %CJS --> Where I ought to code transfer if I want to look at
            %this...
            PDataEarly=adaptData.getParamInCond(params,EarlyPANames);
            PDataLate=adaptData.getParamInCond(params,LatePANames);
            DelFDeAdapt=[DelFDeAdapt; nanmean(PDataLate(end-44:end-5, :))-nanmean(PDataEarly(1:5,:))];
        else
            PANames=adaptData.metaData.conditionName(find(cellfun(@(x) ~isempty(x),(regexp(lower(adaptData.metaData.conditionName), 'ada'))), 1, 'first')+1);
            if strcmp(lower(PANames), 'catch')
                PANames=adaptData.metaData.conditionName(find(cellfun(@(x) ~isempty(x),(regexp(lower(adaptData.metaData.conditionName), 'ada'))), 2, 'first')+1);
            end
            if sum(strcmp(PANames, 'OG post'))>0
                DelFDeAdapt=[DelFDeAdapt; nan.*ones(1, length(params))];
            else
                PData=adaptData.getParamInCond(params,PANames);
                PANames=adaptData.metaData.conditionName(find(cellfun(@(x) ~isempty(x),(regexp(lower(adaptData.metaData.conditionName), 'ada'))), 2, 'first')+1);
                DelFDeAdapt=[DelFDeAdapt; nanmean(PData(end-44:end-5, :))-nanmean(PData(1:5,:))];
            end
            
            %CJS: New way to do this that gives the sign I want
            DelFDeAdapt2Base=[DelFDeAdapt2Base; nanmean(PDataWBias(EarlyStrides,:))-baseWBias];
        end
        tmafter=[tmafter; nanmean(PData(EarlyStrides, :))];%NORMAL WAY
        DelFAPA=[DelFAPA; TMSteady(s, :)-tmafter(s, :)];
        
        tmafterWBias=[tmafterWBias; nanmean(PDataWBias(EarlyStrides, :))];
        if size(PData, 1)<46
            LateP=[LateP; nan.*ones(1, length(params))];
        else
            LateP=[LateP; nanmean(PData(end-44:end-5, :))];
        end
        
        
        %If inclince decline then flat post -- NEw
        if ~isempty(find(cellfun(@(x) ~isempty(x),(regexp(lower(adaptData.metaData.conditionName), lower('flat post'))))))
            FlatWashoutData=adaptData.getParamInCond(params,'flat post');
            FlatWash=[FlatWash; nanmean(FlatWashoutData(1:transientNumPts,:))];
        else
            FlatWash=[FlatWash; NaN.*ones(1, length(params))];
        end
        
        %Baseline Adaptation Paramerters~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        SlowBasePosVar=[SlowBasePosVar; nanvar(SBaseData(6:end-4, :))];
        FastBasePosVar=[FastBasePosVar; nanvar(FBaseData(6:end-4, :))];
        
        BaseAdapDiscont=[BaseAdapDiscont; nanmean(AData(6:10,:))-Realbase];
        SS_PA_Discont=[SS_PA_Discont; nanmean(AData((end-5)-steadyNumPts+1:(end-5),:))-nanmean(PData(1:5, :))];
        
        BaseShortExposureDiscont=[BaseShortExposureDiscont; nanmean(ShortExp(1:5,:))-nanmean(MBaseData(6:end-4, :))];
        BasePADiscont=[BasePADiscont; nanmean(PData(1:5,:))-nanmean(MBaseData(6:end-4, :))];
        
        fast=find(strcmp(params, {'FyPF'})+strcmp(params, {'FyBF'})+strcmp(params, {'XFast'})+strcmp(params, {'FyPFmax'})+strcmp(params, {'FyBFmax'}));
        slow=find(strcmp(params, {'FyPS'})+strcmp(params, {'FyBS'})+strcmp(params, {'XSlow'})+strcmp(params, {'FyPSmax'})+strcmp(params, {'FyBSmax'}));
        speedBias=[];
        speedPABias=[];
        SlowMediumBaseDiscont=[SlowMediumBaseDiscont; MBase(s, :)-SBase(s, :)];
        FastMediumBaseDiscont=[FastMediumBaseDiscont; FBase(s, :)-MBase(s, :)];
        
        
        for w=1:length(fast)
            speedBias(fast(w))=FBase(s, fast(w));
            speedPABias(fast(w))=SBase(s, fast(w));
        end
        for w=1:length(slow)
            speedBias(slow(w))=SBase(s, slow(w));
            speedPABias(slow(w))=FBase(s, slow(w));
        end
        if length(speedBias)<length(params)
            speedBias=[speedBias zeros(1, length(params)-length(speedBias))];
            speedPABias=[speedPABias zeros(1, length(params)-length(speedPABias))];
        end
        
        %CJS 1/2018-- I added the abs so that the sign would indicate
        %something about the magnitude of the forces
        SpeedAdapDiscont=[SpeedAdapDiscont; abs(nanmean(ADataWBias(EarlyStrides, :)))-abs(speedBias)];
        SpeedPADiscont=[SpeedPADiscont; nanmean(PDataWBias(1:5, :))-speedPABias];
        SpeedSSDiscont=[SpeedSSDiscont; nanmean(ADataWBias((end-5)-steadyNumPts+1:(end-5),:))-speedBias];
        
        clear speedBias
        %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    end
    
    Breaking=find(strcmp(params, {'FyBS'})+strcmp(params, {'FyBF'})+strcmp(params, {'FyBSmax'})+strcmp(params, {'FyBFmax'}));
    
    if ~isempty(Breaking)
        DelFAdapt(:, Breaking)=-1.*DelFAdapt(:, Breaking);
        DelFDeAdapt(:, Breaking)=-1.*DelFDeAdapt(:, Breaking);
        DelFDeAdapt2Base(:, Breaking)=-1.*DelFDeAdapt2Base(:, Breaking);
        tmafter(:, Breaking)=-1.*tmafter(:, Breaking);%New 4/12/2018
        
    end
    
    washout2=[washout2; 100-(100*(tmafter./TMSteady))];
    plearn=[plearn; (100*(tmafter./TMSteady))];
    
    % Initialize values to calculate
    results.Height.avg(end+1,:)=nanmean(Height,1);
    results.Weight.avg(end+1,:)=nanmean(Weight,1);
    results.Age.avg(end+1,:)=nanmean(Age,1);
    results.Male.avg(end+1,:)=nanmean(Male,1);
    results.RightLeg.avg(end+1,:)=nanmean(RightLeg,1);
    
    results.DelFAdapt.avg(end+1,:)=nanmean(DelFAdapt,1);
    results.DelFAdapt.se(end+1,:)=nanstd(DelFAdapt,1)./sqrt(nSubs);
    
    results.DelFDeAdapt.avg(end+1,:)=nanmean(DelFDeAdapt,1);
    results.DelFDeAdapt.se(end+1,:)=nanstd(DelFDeAdapt,1)./sqrt(nSubs);
    
    results.DelFDeAdapt2Base.avg(end+1,:)=nanmean(DelFDeAdapt2Base,1);
    results.DelFDeAdapt2Base.se(end+1,:)=nanstd(DelFDeAdapt2Base,1)./sqrt(nSubs);
    
    results.TMSteady.avg(end+1,:)=nanmean(TMSteady,1);
    results.TMSteady.se(end+1,:)=nanstd(TMSteady,1)./sqrt(nSubs);
    
    results.TMafter.avg(end+1,:)=nanmean(tmafter,1);
    results.TMafter.se(end+1,:)=nanstd(tmafter,1)./sqrt(nSubs);
    
    results.TMSteadyWBias.avg(end+1,:)=nanmean(TMSteadyWBias,1);
    results.TMSteadyWBias.se(end+1,:)=nanstd(TMSteadyWBias,1)./sqrt(nSubs);
    
    results.TMafterWBias.avg(end+1,:)=nanmean(tmafterWBias,1);
    results.TMafterWBias.se(end+1,:)=nanstd(tmafterWBias,1)./sqrt(nSubs);
    
    results.FastBase.avg(end+1,:)=nanmean(FBase,1);
    results.FastBase.se(end+1,:)=nanstd(FBase,1)./sqrt(nSubs);
    
    results.SlowBase.avg(end+1,:)=nanmean(SBase,1);
    results.SlowBase.se(end+1,:)=nanstd(SBase,1)./sqrt(nSubs);
    
    results.MidBase.avg(end+1,:)=nanmean(MBase,1);
    results.MidBase.se(end+1,:)=nanstd(MBase,1)./sqrt(nSubs);
    
    results.BaseAdapDiscont.avg(end+1,:)=nanmean(BaseAdapDiscont,1);
    results.BaseAdapDiscont.se(end+1,:)=nanstd(BaseAdapDiscont,1)./sqrt(nSubs);
    
    results.BasePADiscont.avg(end+1,:)=nanmean(BasePADiscont,1);
    results.BasePADiscont.se(end+1,:)=nanstd(BasePADiscont,1)./sqrt(nSubs);
    
    results.SpeedAdapDiscont.avg(end+1,:)=nanmean(SpeedAdapDiscont,1);
    results.SpeedAdapDiscont.se(end+1,:)=nanstd(SpeedAdapDiscont,1)./sqrt(nSubs);
    
    results.SpeedPADiscont.avg(end+1,:)=nanmean(SpeedPADiscont,1);
    results.SpeedPADiscont.se(end+1,:)=nanstd(SpeedPADiscont,1)./sqrt(nSubs);
    
    results.EarlyA.avg(end+1,:)=nanmean(EarlyA,1);
    results.EarlyA.se(end+1,:)=nanstd(EarlyA,1)./sqrt(nSubs);
    
    results.EarlyAish.avg(end+1,:)=nanmean(EarlyAish,1);
    results.EarlyAish.se(end+1,:)=nanstd(EarlyAish,1)./sqrt(nSubs);
    
    results.EarlyAVar.avg(end+1,:)=nanmean(EarlyAVar,1);
    results.EarlyAVar.se(end+1,:)=nanstd(EarlyAVar,1)./sqrt(nSubs);
    
    results.LateP.avg(end+1,:)=nanmean(LateP,1);
    results.LateP.se(end+1,:)=nanstd(LateP,1)./sqrt(nSubs);
    
    results.Washout2.avg(end+1,:)=nanmean(washout2,1);
    results.Washout2.se(end+1,:)=nanstd(washout2)./sqrt(nSubs);
    
    results.FlatWash.avg(end+1,:)=nanmean(    FlatWash,1);
    results.FlatWash.se(end+1,:)=nanstd(FlatWash)./sqrt(nSubs);
    
    results.PLearn.avg(end+1,:)=nanmean(    plearn,1);
    results.PLearn.se(end+1,:)=nanstd(plearn)./sqrt(nSubs);
    
    results.lenA.avg(end+1,:)=nanmean(    lenA,1);
    results.lenA.se(end+1,:)=nanstd(lenA)./sqrt(nSubs);
    
    results.SpeedSSDiscont.avg(end+1,:)=nanmean(SpeedSSDiscont,1);
    results.SpeedSSDiscont.se(end+1,:)=nanstd(SpeedSSDiscont)./sqrt(nSubs);
    
    results.SlowBasePosVar.avg(end+1,:)=nanmean(SlowBasePosVar,1);
    results.SlowBasePosVar.se(end+1,:)=nanstd(SlowBasePosVar)./sqrt(nSubs);
    results.FastBasePosVar.avg(end+1,:)=nanmean(FastBasePosVar,1);
    results.FastBasePosVar.se(end+1,:)=nanstd(FastBasePosVar)./sqrt(nSubs);
    results.TMSteadyPosVar.avg(end+1,:)=nanmean(TMSteadyPosVar,1);
    results.TMSteadyPosVar.se(end+1,:)=nanstd(TMSteadyPosVar)./sqrt(nSubs);
    results.AllAdaptPosVar.avg(end+1,:)=nanmean(AllAdaptPosVar,1);
    results.AllAdaptPosVar.se(end+1,:)=nanstd(AllAdaptPosVar)./sqrt(nSubs);
    
    results.SlowMediumBaseDiscont.avg(end+1,:)=nanmean(SlowMediumBaseDiscont,1);
    results.SlowMediumBaseDiscont.se(end+1,:)=nanstd(SlowMediumBaseDiscont)./sqrt(nSubs);
    results.FastMediumBaseDiscont.avg(end+1,:)=nanmean(FastMediumBaseDiscont,1);
    results.FastMediumBaseDiscont.se(end+1,:)=nanstd(FastMediumBaseDiscont)./sqrt(nSubs);
    
    results.RatioBaseDiscont.avg(end+1,:)=nanmean(SlowMediumBaseDiscont-FastMediumBaseDiscont,1);
    results.RatioBaseDiscont.se(end+1,:)=nanstd(SlowMediumBaseDiscont-FastMediumBaseDiscont)./sqrt(nSubs);
    
    results.EarlyAWBias.avg(end+1,:)=nanmean(EarlyAWBias,1);
    results.EarlyAWBias.se(end+1,:)=nanstd(EarlyAWBias)./sqrt(nSubs);
    results.DelFAPA.avg(end+1,:)=nanmean(DelFAPA,1);
    results.DelFAPA.se(end+1,:)=nanstd(DelFAPA)./sqrt(nSubs);
    
    results.EarlySlope.avg(end+1,:)=nanmean(EarlySlope,1);
    results.EarlySlope.se(end+1,:)=nanstd(EarlySlope)./sqrt(nSubs);
    results.MiddleSlope.avg(end+1,:)=nanmean(MiddleSlope,1);
    results.MiddleSlope.se(end+1,:)=nanstd(MiddleSlope)./sqrt(nSubs);
    
    results.FirstSteps.avg(end+1,:)=nanmean(FirstSteps,1);
    results.FirstSteps.se(end+1,:)=nanstd(FirstSteps)./sqrt(nSubs);
    results.ShortExposure.avg(end+1,:)=nanmean(ShortExposure,1);
    results.ShortExposure.se(end+1,:)=nanstd(ShortExposure)./sqrt(nSubs);
    
    results.ShortExposureAfter.avg(end+1,:)=nanmean(ShortExposureAfter,1);
    results.ShortExposureAfter.se(end+1,:)=nanstd(ShortExposureAfter)./sqrt(nSubs);
    
    results.BaseShortExposureDiscont.avg(end+1,:)=nanmean(BaseShortExposureDiscont,1);
    results.BaseShortExposureDiscont.se(end+1,:)=nanstd(BaseShortExposureDiscont)./sqrt(nSubs);
    
    results.EarlyShortExpoWBias.avg(end+1,:)=nanmean(EarlyShortExpoWBias,1);
    results.EarlyShortExpoWBias.se(end+1,:)=nanstd(EarlyShortExpoWBias)./sqrt(nSubs);
    
    results.SS_PA_Discont.avg(end+1,:)=nanmean(SS_PA_Discont,1);
    results.SS_PA_Discont.se(end+1,:)=nanstd(SS_PA_Discont)./sqrt(nSubs);
    
    results.MBaseSL.avg(end+1,:)=nanmean(MBaseSL,1);
    results.MBaseSL.se(end+1,:)=nanstd(MBaseSL)./sqrt(nSubs);
    results.MBaseSL_FLAT.avg(end+1,:)=nanmean(MBaseSL_FLAT,1);
    results.MBaseSL_FLAT.se(end+1,:)=nanstd(MBaseSL_FLAT)./sqrt(nSubs);
    
    
    
    if g==1 %This seems ridiculous, but I don't know of another way to do it without making MATLAB mad. The results.(whatever).indiv structure needs to be in this format to make life easier for using SPSS
        for p=1:length(params)
            results.DelFAdapt.indiv.(params{p})=[g*ones(nSubs,1) DelFAdapt(:,p)];
            results.DelFDeAdapt.indiv.(params{p})=[g*ones(nSubs,1) DelFDeAdapt(:,p)];
            results.DelFDeAdapt2Base.indiv.(params{p})=[g*ones(nSubs,1) DelFDeAdapt2Base(:,p)];
            results.FastBase.indiv.(params{p})=[g*ones(nSubs,1) FBase(:,p)];
            results.SlowBase.indiv.(params{p})=[g*ones(nSubs,1) SBase(:,p)];
            results.MidBase.indiv.(params{p})=[g*ones(nSubs,1) MBase(:,p)];
            results.TMSteady.indiv.(params{p})=[g*ones(nSubs,1) TMSteady(:,p)];
            results.TMafter.indiv.(params{p})=[g*ones(nSubs,1) tmafter(:,p)];
            results.TMSteadyWBias.indiv.(params{p})=[g*ones(nSubs,1) TMSteadyWBias(:,p)];
            results.TMafterWBias.indiv.(params{p})=[g*ones(nSubs,1) tmafterWBias(:,p)];
            results.BaseAdapDiscont.indiv.(params{p})=[g*ones(nSubs,1) BaseAdapDiscont(:,p)];
            results.BasePADiscont.indiv.(params{p})=[g*ones(nSubs,1) BasePADiscont(:,p)];
            results.SpeedAdapDiscont.indiv.(params{p})=[g*ones(nSubs,1) SpeedAdapDiscont(:,p)];
            results.SpeedPADiscont.indiv.(params{p})=[g*ones(nSubs,1) SpeedPADiscont(:,p)];
            results.EarlyA.indiv.(params{p})=[g*ones(nSubs,1) EarlyA(:,p)];
            results.EarlyAish.indiv.(params{p})=[g*ones(nSubs,1) EarlyAish(:,p)];
            results.EarlyAVar.indiv.(params{p})=[g*ones(nSubs,1) EarlyA(:,p)];
            results.LateP.indiv.(params{p})=[g*ones(nSubs,1) LateP(:,p)];
            results.Washout2.indiv.(params{p})=[g*ones(nSubs,1) washout2(:,p)];
            results.FlatWash.indiv.(params{p})=[g*ones(nSubs,1)     FlatWash(:,p)];
            results.PLearn.indiv.(params{p})=[g*ones(nSubs,1)    plearn(:,p)];
            results.lenA.indiv.(params{p})=[g*ones(nSubs,1)    lenA(:,p)];
            results.SpeedSSDiscont.indiv.(params{p})=[g*ones(nSubs,1)    SpeedSSDiscont(:,p)];
            
            results.SlowBasePosVar.indiv.(params{p})=[g*ones(nSubs,1)    SlowBasePosVar(:,p)];
            results.FastBasePosVar.indiv.(params{p})=[g*ones(nSubs,1)    FastBasePosVar(:,p)];
            results.TMSteadyPosVar.indiv.(params{p})=[g*ones(nSubs,1)    TMSteadyPosVar(:,p)];
            results.AllAdaptPosVar.indiv.(params{p})=[g*ones(nSubs,1)    AllAdaptPosVar(:,p)];
            
            results. SlowMediumBaseDiscont.indiv.(params{p})=[g*ones(nSubs,1)     SlowMediumBaseDiscont(:,p)];
            
            results.FastMediumBaseDiscont.indiv.(params{p})=[g*ones(nSubs,1)    FastMediumBaseDiscont(:,p)];
            results.RatioBaseDiscont.indiv.(params{p})=[g*ones(nSubs,1)    SlowMediumBaseDiscont(:,p)-FastMediumBaseDiscont(:,p)];
            results.EarlyAWBias.indiv.(params{p})=[g*ones(nSubs,1)    EarlyAWBias(:,p)];
            results.DelFAPA.indiv.(params{p})=[g*ones(nSubs,1)    DelFAPA(:,p)];
            
            
            results.EarlySlope.indiv.(params{p})=[g*ones(nSubs,1)   EarlySlope(:,p)];
            results.MiddleSlope.indiv.(params{p})=[g*ones(nSubs,1)    MiddleSlope(:,p)];
            
            results.FirstSteps.indiv.(params{p})=[g*ones(nSubs,1)   FirstSteps(:,p)];
            results.ShortExposure.indiv.(params{p})=[g*ones(nSubs,1)    ShortExposure(:,p)];
            
            results.MBaseSL.indiv.(params{p})=[g*ones(nSubs,1)   MBaseSL(:,p)];
            results.MBaseSL_FLAT.indiv.(params{p})=[g*ones(nSubs,1)    MBaseSL_FLAT(:,p)];
            
            
            
            results.ShortExposureAfter.indiv.(params{p})=[g*ones(nSubs,1)    ShortExposureAfter(:,p)];
            results.BaseShortExposureDiscont .indiv.(params{p})=[g*ones(nSubs,1)    BaseShortExposureDiscont(:,p)];
            results.EarlyShortExpoWBias.indiv.(params{p})=[g*ones(nSubs,1)    EarlyShortExpoWBias(:,p)];
            results.SS_PA_Discont.indiv.(params{p})=[g*ones(nSubs,1)    SS_PA_Discont(:,p)];
            
            
            results.Height.indiv.(params{p})=[g*ones(nSubs,1)    Height];
            results.Weight.indiv.(params{p})=[g*ones(nSubs,1)    Weight];
            results.Age.indiv.(params{p})=[g*ones(nSubs,1)    Age];
            results.Male.indiv.(params{p})=[g*ones(nSubs,1)    Male];
            results.RightLeg.indiv.(params{p})=[g*ones(nSubs,1)    RightLeg];
            
        end
    else
        for p=1:length(params)
            results.DelFAdapt.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) DelFAdapt(:,p)];
            results.DelFDeAdapt.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) DelFDeAdapt(:,p)];
            results.DelFDeAdapt2Base.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) DelFDeAdapt2Base(:,p)];
            results.FastBase.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) FBase(:,p)];
            results.SlowBase.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) SBase(:,p)];
            results.MidBase.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) MBase(:,p)];
            results.TMSteady.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) TMSteady(:,p)];
            results.TMafter.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) tmafter(:,p)];
            results.TMSteadyWBias.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) TMSteadyWBias(:,p)];
            results.TMafterWBias.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) tmafterWBias(:,p)];
            results.BaseAdapDiscont.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) BaseAdapDiscont(:,p)];
            results.BasePADiscont.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) BasePADiscont(:,p)];
            results.SpeedAdapDiscont.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) SpeedAdapDiscont(:,p)];
            results.SpeedPADiscont.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) SpeedPADiscont(:,p)];
            results.EarlyA.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) EarlyA(:,p)];
            results.EarlyAVar.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) EarlyA(:,p)];
            results.EarlyAish.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) EarlyAish(:,p)];
            results.LateP.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) LateP(:,p)];
            results.Washout2.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) washout2(:,p)];
            results.FlatWash.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1)     FlatWash(:,p)];
            results.PLearn.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1)    plearn(:,p)];
            results.lenA.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1)    lenA(:,p)];
            results.SpeedSSDiscont.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1)    SpeedSSDiscont(:,p)];
            
            results.SlowBasePosVar.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1)    SlowBasePosVar(:,p)];
            results.FastBasePosVar.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1)    FastBasePosVar(:,p)];
            results.TMSteadyPosVar.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1)    TMSteadyPosVar(:,p)];
            results.AllAdaptPosVar.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1)    AllAdaptPosVar(:,p)];
            
            results.SlowMediumBaseDiscont.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1)    SlowMediumBaseDiscont(:,p)];
            results.FastMediumBaseDiscont.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1)    FastMediumBaseDiscont(:,p)];
            
            results.RatioBaseDiscont.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1)    SlowMediumBaseDiscont(:,p)-FastMediumBaseDiscont(:,p)];
            results.EarlyAWBias.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1)    EarlyAWBias(:,p)];
            results.DelFAPA.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1)    DelFAPA(:,p)];
            
            results.EarlySlope.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1)   EarlySlope(:,p)];
            results.MiddleSlope.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1)    MiddleSlope(:,p)];
            
            results.FirstSteps.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1)   FirstSteps(:,p)];
            results.ShortExposure.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1)    ShortExposure(:,p)];
            
            results.ShortExposureAfter.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1)    ShortExposureAfter(:,p)];
            results.BaseShortExposureDiscont.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1)    BaseShortExposureDiscont(:,p)];
            results.EarlyShortExpoWBias.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1)    EarlyShortExpoWBias(:,p)];
            results.SS_PA_Discont.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1)    SS_PA_Discont(:,p)];
            
            results.MBaseSL.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1)    MBaseSL(:,p)];
            results.MBaseSL_FLAT.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1)    MBaseSL_FLAT(:,p)];
            
            results.Height.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1)    Height];
            results.Weight.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1)    Weight];
            results.Age.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1)    Age];
            results.Male.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1)    Male];
            results.RightLeg.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1)    RightLeg];
            
        end
    end
end
StatFlag=1;
resultNames=fieldnames(results);
indiData=[];

%if StatFlag==1
for h=1:length(resultNames)
    for i=1:size(results.DelFAdapt.avg, 2)%size(StatReady, 2)
        if size(results.DelFAdapt.avg, 1)==2 || strcmp(params{i}, 'TMAngle')==1%Can just used a ttest, which will be PAIRED
            Group1=find(results.(resultNames{h}).indiv.(params{i})(:, 1)==1);
            Group2=find(results.(resultNames{h}).indiv.(params{i})(:, 1)==2);
        else% have to do an anova
            [results.(resultNames{h}).p(i), cat, stats]=anova1(results.(resultNames{h}).indiv.(params{i})(:, 2), results.(resultNames{h}).indiv.(params{i})(:, 1), 'off');
            results.(resultNames{h}).F(1, i)=cat{2,5};
            results.(resultNames{h}).F(2, i)=cat{2,3};
            results.(resultNames{h}).F(3, i)=cat{3,3}; clear cat
            results.(resultNames{h}).postHoc{i}=[NaN NaN];
            if results.(resultNames{h}).p(i)<=0.05 && exist('stats')==1
                [c,~,~,gnames]=multcompare(stats, 'CType', 'hsd');
                results.(resultNames{h}).postHoc{i}=c(find(c(:,6)<=0.05), 1:2);
            end
            if exist('c')==1
                results.(resultNames{h}).postHocP.(params{i})=c(:, [1, 2, 6]);
            end
        end
        %Check to see if each group is different from zero
        for g=1:ngroups
            Group=find(results.(resultNames{h}).indiv.(params{i})(:, 1)==g);
            [~, results.(resultNames{h}).DiffZero(g, i)]=ttest(results.(resultNames{h}).indiv.(params{i})(Group, 2));
        end
        clear c
    end
end

close all

%plot stuff
if nargin>4 && plotFlag

    epochs={'SlowBase','FastBase','SpeedAdapDiscont', 'SpeedSSDiscont','TMSteady', 'SS_PA_Discont'};
    if nargin>5 %I imagine there has to be a better way to do this...
        barGroups(SMatrix,results,groups,params,epochs,indivFlag)
    else
        barGroups(SMatrix,results,groups,params,epochs)
    end
    
end


