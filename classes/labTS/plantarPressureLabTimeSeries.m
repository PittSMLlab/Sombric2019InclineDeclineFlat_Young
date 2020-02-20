classdef plantarPressureLabTimeSeries  < labTimeSeries
%
    %%
    properties(SetAccess=private)
        %% cjs -- sensor specs
        sensorSpecs
        %orientation %orientationInfo object
    end
    properties(Dependent)
        dataL
        dataR
        copL
        copR
        FzL
        FzR
    end

    
    %%
    methods
        
        %Constructor: cjs
        function this=plantarPressureLabTimeSeries(data,t0,Ts,labels,sensorSpecs) %Necessarily uniformly sampled
            if nargin<1
                data=[];
                t0=0;
                Ts=[];
                labels={};
                sensorSpecs=[];
            end
%                 if ~orientedLabTimeSeries.checkLabelSanity(labels)
%                     error('orientedLabTimeSeries:Constructor','Provided labels do not pass the sanity check. See issued warnings.')
%                 end
                this@labTimeSeries(data,t0,Ts,labels);
%                 if isa(orientation,'orientationInfo')
%                     this.orientation=orientation;
%                 else
%                     ME=MException('orientedLabTimeSeries:Constructor','Orientation parameter is not an OrientationInfo object.');
%                     throw(ME)
%                 end
            this.sensorSpecs=sensorSpecs;
        end
        
        % Dependent methods
        function dataL=get.dataL(this)
            ll=this.getLabelsThatMatch('^L');
            dataL=this.getDataAsVector(ll);
            dataL=reshape(dataL,length(this.Time),60,21);
        end
        function dataR=get.dataR(this)
            ll=this.getLabelsThatMatch('^R');
            dataR=this.getDataAsVector(ll);
            dataR=reshape(dataR,length(this.Time),  60,21);
        end
        
        function FzL=get.FzL(this)
            dataL=this.dataL;
            FzL=nansum(nansum(dataL, 2), 3);
        end
        function FzR=get.FzR(this)
            dataR=this.dataR;
            FzR=nansum(nansum(dataR, 2), 3);
        end
        
        %-------------------
        
        %Other I/O functions:

        %-------------------
    


        %-------------------cjs --> need to make own plotting functions
        function animate(this)
            dL=this.dataL;
            dR=this.dataR;
            figure('Units','Normalized','OuterPosition',[0 0 1 1])
            %drawnow limitrate
            for i=1:20:size(dL,1) %Plotting @100Hz
            subplot(1,2,1)
            imagesc(squeeze(dL(i,:,:)))
            axis equal
            caxis([0 256])
            title(['t=' num2str(this.Time(i)) 's'])
            colorbar
            subplot(1,2,2)
            imagesc(squeeze(dR(i,:,:)))
            axis equal
            caxis([0 256])
            drawnow
            end
        end
        %-------------------
        %Modifier functions:
        
        function newThis=resampleN(this,newN,method)
            %Same as resample function, but directly fixing the number of samples instead of TS
            
            if nargin<3
                method=[];
            end
            auxThis=this.resampleN@labTimeSeries(newN,method);
            newThis=plantarPressureLabTimeSeries(auxThis.Data,auxThis.Time(1),auxThis.sampPeriod,auxThis.labels,this.sensorSpecs);
        end
        
        function newThis=split(this,t0,t1)
            %returns TS from t0 to t1
           auxThis=this.split@labTimeSeries(t0,t1);
           newThis=plantarPressureLabTimeSeries(auxThis.Data,t0,auxThis.sampPeriod,auxThis.labels,this.sensorSpecs);
        end
        
        function newThis=derivate(this)
            %take derivative of OTS
            
            auxThis=this.derivate@labTimeSeries;
            newThis=plantarPressureLabTimeSeries(auxThis.Data,auxThis.Time(1),auxThis.sampPeriod,auxThis.labels,this.sensorSpecs);
        end
        
        function newThis=lowPassFilter(this,fcut)
           newThis=lowPassFilter@labTimeSeries(this,fcut); 
           newThis=plantarPressureLabTimeSeries(newThis.Data,newThis.Time(1),newThis.sampPeriod,newThis.labels,this.sensorSpecs);
        end
        
        function newThis=highPassFilter(this,fcut)
           newThis=highPassFilter@labTimeSeries(this,fcut); 
           newThis=plantarPressureLabTimeSeries(newThis.Data,newThis.Time(1),newthis.sampPeriod,newThis.labels,this.sensorSpecs);
        end
        
    end
    methods (Static)
        function OTS=getOTSfromOrientedData(data,t0,Ts,labelPrefixes,sensorSpecs)
            labels=[strcat(labelPrefixes,'x');strcat(labelPrefixes,'y');strcat(labelPrefixes,'z')];
            data=permute(data,[1,3,2]);
            OTS=plantarPressureLabTimeSeries(data(:,:),t0,Ts,labels(:),sensorSpecs);
        end
        %cjs, DON'T THINK I NEED THIS FOLLOWING FUNCTION??
        function extendedLabels=addLabelSuffix(labels)
            %Add component suffix to each label
            %
            %example:
            %labels = {'RHIP','LHIP',...}
            %extendedLabels = addLabelSuffix(labels);
            %extendedLabels = {'RHIPx','RHIPy','RHIPz','LHIPx','LHIPy','LHIPz',...}
            
            if ischar(labels)
                labels={labels};
            end
            extendedLabels=cell(length(labels)*3,1);
            extendedLabels(1:3:end)=strcat(labels,'x');
            extendedLabels(2:3:end)=strcat(labels,'y');
            extendedLabels(3:3:end)=strcat(labels,'z');
        end 
    end

end

