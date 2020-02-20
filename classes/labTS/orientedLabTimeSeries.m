classdef orientedLabTimeSeries  < labTimeSeries
%
    %%
    properties(SetAccess=private)
        orientation %orientationInfo object
    end
    %properties(Dependent)
    %    labelPrefixes
    %    labelSuffixes
    %end

    
    %%
    methods
        
        %Constructor:
        function this=orientedLabTimeSeries(data,t0,Ts,labels,orientation) %Necessarily uniformly sampled
            if nargin<1
                data=[];
                t0=0;
                Ts=[];
                labels={};
                orientation=orientationInfo();
            end
                if ~orientedLabTimeSeries.checkLabelSanity(labels)
                    error('orientedLabTimeSeries:Constructor','Provided labels do not pass the sanity check. See issued warnings.')
                end
                this@labTimeSeries(data,t0,Ts,labels);
                if isa(orientation,'orientationInfo')
                    this.orientation=orientation;
                else
                    ME=MException('orientedLabTimeSeries:Constructor','Orientation parameter is not an OrientationInfo object.');
                    throw(ME)
                end
        end
        
        %-------------------
        
        %Other I/O functions:
        function [newTS,auxLabel]=getDataAsTS(this,label)
            %return data as a time series
            %
            [newTS,auxLabel]=getDataAsTS@labTimeSeries(this,label);
        end

        function [data,label]=getOrientedData(this,label)
            %Returns data as a 3D tensor, where the last dim contains the componentes x,y,z
            %[data,label]=getOrientedData(this,label)
            %INPUT:
            %this = orientedLabTS object
            %label = cell array of strings, each containing the prefix of a
            %marker present in this TS (e.g.: label={'LHIP','RHIP'}, not
            %{'LHIPx','RHIPx'}. If any of the provided labels do not exist 
            %AS A PREFIX, NaNs are returned in the corresponding matrix components.
            %OUTPUT:
            %data= matrix of dimensions TxNx3, where N is the length of label 
            %(# of requested markers), T is the number of available time
            %samples. Each slice data(:,i,:) contains 3D position of marker
            %i at all time samples.
            %label=Currently returns the same label given as input. 
            
            T=size(this.Data,1);
            if nargin<2 || isempty(label)
                label=this.getLabelPrefix; %All of them
            elseif isa(label,'char')
                label={label};
            end
                
            data=nan(T,length(label)*3);
            extendedLabels=this.addLabelSuffix(label);
            if ~orientedLabTimeSeries.checkLabelSanity(this.labels)
               error('Labels in this object do not pass the sanity check.') 
            end
            [bool,~]=this.isaLabel(extendedLabels);
            [data(:,bool),~]=this.getDataAsVector(extendedLabels(bool));
            data=permute(reshape(data,T,3,round(length(extendedLabels)/3)),[1,3,2]);
        end
        
        function newThis=getDataAsOTS(this,label)
            %get data as an oriented time series
            if nargin<2 || isempty(label)
                label=[];
            end
            [data,label]=getOrientedData(this,label);
            data=permute(data,[1,3,2]);
            newThis=orientedLabTimeSeries(data(:,:),this.Time(1),this.sampPeriod,orientedLabTimeSeries.addLabelSuffix(label),this.orientation);
        end
        
        function [diffMatrix,labels,labels2,Time]=computeDifferenceMatrix(this,t0,t1,labels,labels2)
           %Computes the difference vector between two markers, for the time interval [t0,t1] 
           %If labels is specified, only those markers are used
           %If labels2 is specified, distance to those markers only is
           %specified
           [data,label]=getOrientedData(this,this.getLabelPrefix);
           [T,N,M]=size(data); %M=3
           
           %Inefficient way: compute the difference matrix for all times
           %and markers, and then reduce it
           diffMatrix=nan(T,N,M,N);
           for i=1:N
               diffMatrix(:,:,:,i)= bsxfun(@minus,data,data(:,i,:));
           end
           diffMatrix=permute(diffMatrix,[1,2,4,3]);
           if nargin<2 || isempty(t0)
              t0=this.Time(1); 
           end
           if nargin<3 || isempty(t1)
               t1=this.Time(end);
           end
           if nargin<4 || isempty(labels)
               labels=this.getLabelPrefix;
           end
           if nargin<5 || isempty(labels2)
               labels2=this.getLabelPrefix;
           end
           %Reduce it:
           timeIdxs=find(this.Time<=t1 & this.Time>=t0);
           [~,labelIdxs]=isaLabelPrefix(this,labels);
           [~,label2Idxs]=isaLabelPrefix(this,labels2);
           diffMatrix=diffMatrix(timeIdxs,labelIdxs,label2Idxs,:);
           Time=this.Time(timeIdxs);
           
        end
        
        function [diffOTS]=computeDifferenceOTS(this,t0,t1,labels,labels2)
            %compute difference matrix for oriented time series
            if nargin<2 || isempty(t0)
              t0=this.Time(1); 
           end
           if nargin<3 || isempty(t1)
               t1=this.Time(end)+eps;
           end
           if nargin<4 || isempty(labels)
               labels=this.getLabelPrefix;
           end
           if nargin<5 || isempty(labels2)
               labels2=this.getLabelPrefix;
           end
           [diffMatrix,labels,labels2,Time]=computeDifferenceMatrix(this,t0,t1,labels,labels2);
           newLabels=cell(1,length(labels)*length(labels2));
           for i=1:length(labels2)
               newLabels((i-1)*length(labels)+1:i*length(labels))=strcat(labels,[' - ' labels2{i}]);
           end
           newLabels2=[strcat(newLabels,'x');strcat(newLabels,'y');strcat(newLabels,'z')];
           aux=reshape(diffMatrix,size(diffMatrix,1),size(diffMatrix,2)*size(diffMatrix,3),size(diffMatrix,4));
           aux=permute(aux,[1,3,2]);
           diffOTS=orientedLabTimeSeries(aux(:,:),Time(1),this.sampPeriod,newLabels2(:),this.orientation);
           
        end
        
        function [distMatrix,labels,labels2,Time]=computeDistanceMatrix(this,t0,t1,labels,labels2)
           %Computes the distance vector between two markers, for the time interval [t0,t1] 
           %If labels is specified, only those markers are used
           %If labels2 is specified, distance to those markers only is
           %specified
           if nargin<2 || isempty(t0)
              t0=[]; 
           end
           if nargin<3 || isempty(t1)
               t1=[];
           end
           if nargin<4 || isempty(labels)
               labels=[];
           end
           if nargin<5 || isempty(labels2)
               labels2=[];
           end
            [diffMatrix,labels,labels2,Time]=computeDifferenceMatrix(this,t0,t1,labels,labels2);
            distMatrix=sqrt(sum(diffMatrix.^2,4));
        end

        %-------------------
        
        function labelPref=getLabelPrefix(this)
            %return label prefixes from this.labels
            %works for any orientedTS instance, GRFData and markerdata
            %
            %example:
            %this.labels = {'RPSISx','RPSISy',RPSISz','LPSISx','LPSISy','LPSISz',...}
            %aux = cellfun(@(x) x(1:end-1),this.labels,'UniformOutput',false);
            %labelPref=aux(1:3:end);
            %labelPref = {'RPSIS','LPSIS',...}
            
            aux=cellfun(@(x) x(1:end-1),this.labels,'UniformOutput',false);%isolate correct prefixes
            labelPref=aux(1:3:end);%remove duplicate prefixes for each marker
        end
        
        function [boolFlag,labelIdx]=isaLabelPrefix(this,label)
            %checks if a label(s) is/are a valid prefix
            %
            %INPUT:
            %label, can be a string or cell array of strings containing a
            %label
            %
            %OUTPUT:
            %boolFlag, a boolean vector TRUE for matches, FALSE if not
            %labelIdx, a vector containing the indices of the TRUE labels
            
             if isa(label,'char')
                auxLabel{1}=label;
            elseif isa(label,'cell')
                auxLabel=label;
            else
                error('labTimeSeries:isaLabel','label input argument has to be a string or a cell array containing strings.')
            end
            
            N=length(auxLabel);
            boolFlag=false(N,1);
            labelIdx=zeros(N,1);
            for j=1:N
                %Alternative efficient formulation:
                boolFlag(j)=any(strcmp(auxLabel{j},this.getLabelPrefix));
                if boolFlag(j)
                    labelIdx(j)=find(strcmp(auxLabel{j},this.getLabelPrefix));
                end
            end
        end
        
        function virtualOTS=getVirtualOTS(this,ww,meanDiff,stdDiff)
            %Virtual markers are computed by taking the maximum likelihood
            %estimator given the position of all other markers and the
            %statistics of the distance between markers (naive bayes
            %approach were distance between markers is assumed normally
            %distributed)
            %INPUT:
            %this: orientedLabTimeSeries object
            %ww: weight given to actual data (in units of 1/mm^2) relative
            %to variances
            %meanDiff: LxLx3 matrix representing the mean difference vector
            %btw all combinations of L markers in the 3 dimensions
            %stdDiff: LxLx3 matrix representing the standard deviation of
            %the difference vectors in the 3 dimensions. Using for
            %weighting to find maximum likelihood position.
            
            
            if nargin<2 || isempty(ww)
                ww=0; %ww represents the weight given to actual data from the marker
            end
            ll=this.getLabelPrefix;
            if nargin<4 || isempty(meanDiff) || isempty(stdDiff)
                differences=this.computeDifferenceMatrix([],[],ll,ll);
                meanDiff=nanmean(differences,1); %Mean distance
                %Method : difference Naive Bayes
                stdDiff=nanstd(differences,[],1);
            end
            
            
            actualData=this.getOrientedData(ll);
            virtualData=nan(size(actualData));
            
            for i=1:length(ll) %For each marker
                xEstim=nan(size(differences,1),3,size(differences,2));
                w=1./stdDiff(1,i,:,:).^2;
                w(1,1,i,:)=ww;
                for j=1:length(ll)
                        xEstim(:,:,j)=bsxfun(@times,bsxfun(@plus,squeeze(actualData(:,j,:)),squeeze(meanDiff(1,i,j,:))'),squeeze(w(1,1,j,:))');
                end
                aux=any(~isnan(xEstim),2);
                
                virtualData(:,i,:)= bsxfun(@rdivide,nansum(xEstim,3),squeeze(sum(bsxfun(@times,w,aux),3)));
            end
            virtualOTS=orientedLabTimeSeries.getOTSfromOrientedData(virtualData,this.Time(1),this.sampPeriod,ll,this.orientation);

        end
        
        function [healthyOTS]=markerHealthCheck(this,refMarkerData)
           %PART 1: model free check
           %Step 1: check for velocities outside physiological range
           
           %Step 2: check for acc outside physilogical range
           
           %Step 3: check that L markers are always on the left, and R
           %markers are always on the right.
           
           
           %PART 2: model-dependent check
           if nargin<2 || isempty(refMarkerData)
               refMarkerData=this;
           end
           %Step 4: check that markers are within reasonable CI of their
           %distance distributions
           
           %Step 5: find gaps & unlabeled markers
           
           %Step 6: return a new OTS with data removed where it seems
           %wrong
           
        end
        
        function [newThis]=fillGaps(this,refMarkerData)
            if nargin<2 || isempty(refMarkerData)
               refMarkerData=this;
            end
            %Meant to be usedwith markerData only
            %PART 1: model free check
            %Use kalman filter to estimate likely position of missing
            %markers
            
            %PART 2: model dependent
            %Use prior knowledge in a Bayesian setting to fill gaps
            
            %PART 3: merge the two estimations through mle or something
           
        end

        %-------------------
        function fh=plot3(this,fh)
            %plots all 3 components of all variables in OTS instance
            %
            %INPUTS:
            %fh, figure handle. If none passed in, a new one is created
            %OUTPUTS:
            %fh, figure handle to figure that shows 3D plot of each data
            %variable (e.g. marker data or GRFdata)
            
            if nargin<2 || isempty(fh)
                fh=figure;%return handle to a figure
            else
                figure(fh);
            end
           [data,labelPref]=getOrientedData(this);
           hold on
           
           for i=1:length(labelPref)
               plot3(data(:,i,1),data(:,i,2),data(:,i,3),'.')
           end
           hold off
           axis equal
           legend(labelPref)
        end
        
        function M=animate(this)
            %MAkes sense only for markerData
            list={'TOE','HEE','HEEL','ANK','SHANK','TIB','KNE','KNEE','THI','THIGH','HIP','GT','ASI','ASIS','PSI','PSIS'};
            [b,~]=this.isaLabelPrefix(strcat('L',list));
            list=list(b);
            ll=this.getOrientedData(unique(cellfun(@(x) x(1:end-1),this.getLabelsThatMatch('^L'),'UniformOutput',false)));
            ll=this.getOrientedData(strcat('L',list));
            rr=this.getOrientedData(unique(cellfun(@(x) x(1:end-1),this.getLabelsThatMatch('^R'),'UniformOutput',false)));
            rr=this.getOrientedData(strcat('R',list));
            dd=this.getOrientedData;
            figure
            %drawnow limitrate
            u = uicontrol('Style','slider','Position',[10 50 20 340],'Min',1,'Max',size(ll,1),'Value',1);
            
            view(3)
            axis equal
            axis([min(min(dd(:,:,1))) max(max(dd(:,:,1))) min(min(dd(:,:,2))) max(max(dd(:,:,2))) min(min(dd(:,:,3))) max(max(dd(:,:,3)))])
            hold on
            L=animatedline(ll(1,:,1),ll(1,:,2),ll(1,:,3),'Marker','o','MarkerSize',10,'MarkerEdgeColor','r');
            R=animatedline(rr(1,:,1),rr(1,:,2),rr(1,:,3),'Marker','o','MarkerSize',10,'MarkerEdgeColor','b');
            %set(gca,'NextPlot','replacechildren')    
            for k = 1:size(ll,1)
                %
                %hold on
                %axes(ax)
                clearpoints(L)
                addpoints(L,ll(k,:,1),ll(k,:,2),ll(k,:,3));
                clearpoints(R)
                addpoints(R,rr(k,:,1),rr(k,:,2),rr(k,:,3));
                %hold off
                u.Value=k;
                M(k) = getframe(gcf);
            end
            hold off
        end
        %-------------------
        %Modifier functions:
        
        function newThis=resampleN(this,newN,method)
            %Same as resample function, but directly fixing the number of samples instead of TS
            
            if nargin<3
                method=[];
            end
            auxThis=this.resampleN@labTimeSeries(newN,method);
            newThis=orientedLabTimeSeries(auxThis.Data,auxThis.Time(1),auxThis.sampPeriod,auxThis.labels,this.orientation);
        end
        
        function newThis=split(this,t0,t1)
            %returns TS from t0 to t1
           auxThis=this.split@labTimeSeries(t0,t1);
           newThis=orientedLabTimeSeries(auxThis.Data,t0,auxThis.sampPeriod,auxThis.labels,this.orientation);
        end
        
        function newThis=translate(this,vector)
            %translate OTS data by input vector (vector addition)
            
            
            %Check: vector is 1x3 or Tx3
            [M,N]=size(vector);
            if N~=3 || (M~=1 && M~=length(this.Time))
                error('orientedLabTS:translate','Translation vector has to be size 3 on second dim, and singleton or of length(time) in the first.')
            end
            [data,~]=getOrientedData(this);
            vector=reshape(vector,M,1,3);
            newData=permute(bsxfun(@plus,data,vector),[1,3,2]);
            newThis=orientedLabTimeSeries(newData(:,:),this.Time(1),this.sampPeriod,this.labels,this.orientation);
            %newThis.UserData.translation=; %ToDo: store the translation
            %info in some structure so that it can be backtracked
        end
        
        function newThis=rotate(this, matrix)
            %rotate OTS data using input rotation matrix

            [data,label]=getOrientedData(this);
            M=size(matrix,1);
            matrix=reshape(matrix,M,1,3,3);
            newData=permute(sum(bsxfun(@times,data,matrix),3),[1,4,2,3]);
            newThis=orientedLabTimeSeries(newData(:,:),this.Time(1),this.sampPeriod,this.labels,this.orientation);
            %newThis.UserData.rotation=; %ToDo: store the rotation
            %info in some structure so that it can be backtracked
        end
        
        function newThis=alignRotate(this,newX,newZ)
            %newX and newZ need to be 1x3 or Nx3 where N=size(this.Data,1)
            %Check:
            N=size(this.Data,1);
            if (size(newX,1)~=1 && size(newX,1)~=N) || size(newX,2)~=3
                error('orientedLabTS:alignRotate','newX has to be 1x3 or Nx3.')
            end    
            if size(newZ,1)~=1 && size(newZ,1)~=N || size(newZ,2)~=3
                error('orientedLabTS:alignRotate','newZ has to be 1x3 or Nx3.')
            end    
            
            %In case of one being 1x3 and the other Nx3, making them both
            %Nx3
            %FIXME: Align z to newZ, and x to newX projected in a direction
            %orthogonal to newZ (or check that newX is orthogonal to newZ
            %to start with)
            if size(newX,1)~=size(newZ,1)
                if size(newX,1)==1
                    newX=repmat(newX,N,1);
                else
                    newZ=repmat(newZ,N,1);
                end
            end
            
           newX=bsxfun(@rdivide,newX,sqrt(sum(newX.^2,2)));
           newZ=bsxfun(@rdivide,newZ,sqrt(sum(newZ.^2,2)));
           %Find rotation matrix
           newY=-cross(newX,newZ); %orthogonal to the other two
           newY=bsxfun(@rdivide,newY,sqrt(sum(newY.^2,2)));
           matrix1=permute(newX,[1,3,2]);
           matrix2=permute(newY,[1,3,2]);
           matrix3=permute(newZ,[1,3,2]);
           matrix=cat(2,matrix1,matrix2);
           matrix=cat(2,matrix,matrix3);
           for i=1:size(matrix,1)
               if ~any(isnan(matrix(i,:,:)))
                matrix(i,1:3,1:3)=inv(squeeze(matrix(i,:,:)));
               else
                   matrix(i,1:3,1:3)=nan;
               end
           end
           %Rotate
           newThis=rotate(this, matrix);
        end
        
         function newThis=AddMarker(this,newData,newLabels)% CJS 3/4/2017
            % Add a new marker to the marker data.  I made this so that I
            % could add the COM data as a 'marker' so that I could rotate
            % and take the derivative, etc. 
            
            %newData needs to be Nx3 where N=size(this.Data,1)
            %newLabels needs to be 1x3 of
            %labels
            N=size(this.Data,1);
            if (size(newData,1)~=1 && size(newData,1)~=N) %|| size(newData,2)~=3
                error('orientedLabTS:alignRotate','newData has to be 1x3 or Nx3.')
             end    
%             if size(newLabels,1)~=1 && size(newLabels,1)~=N %|| size(newLabels,2)~=3
%                 error('orientedLabTS:alignRotate','newZ has to be 1x3 or Nx3.')
%             end
            if size(newLabels,1)~=1 && size(newLabels,1)~=N %|| size(newLabels,2)~=3
                error('orientedLabTS:alignRotate','newZ has to be 1x3 or Nx3.')
            end
            newThis=this;
%             % Update labels
%             %newThis.labels={this.labels{:} newLabels{:}};%
%             % Update data
%             newThis.Data(:, [1:3])= newData;

% I added this instead of the above lines on 4/25/2017 at 9:19 pm. you have
% been warned
            % Update labels
            newThis.labels={this.labels{:} newLabels{:}};%
            % Update data
            newThis.Data= [this.Data newData];
            
        end
        
        function newThis=referenceToMarker(this,marker)
            %align data relative to input marker, calls
            %orientedLabTimeSeries.translate()
            
            %Check: marker needs to be a suffix of this object.
            [data,~]=getOrientedData(this,marker);
            newThis=translate(this,squeeze(-1*data));
        end
        
        function newThis=derivate(this)
            %take derivative of OTS
            
            auxThis=this.derivate@labTimeSeries;
            newThis=orientedLabTimeSeries(auxThis.Data,auxThis.Time(1),auxThis.sampPeriod,auxThis.labels,this.orientation);
        end
        
        function newThis=lowPassFilter(this,fcut)
           newThis=lowPassFilter@labTimeSeries(this,fcut); 
           newThis=orientedLabTimeSeries(newThis.Data,newThis.Time(1),newThis.sampPeriod,newThis.labels,this.orientation);
        end
        
        function newThis=highPassFilter(this,fcut)
           newThis=highPassFilter@labTimeSeries(this,fcut); 
           newThis=orientedLabTimeSeries(newThis.Data,newThis.Time(1),newThis.sampPeriod,newThis.labels,this.orientation);
        end
        
        function newThis=appendData(this,newData,newLabels, orientation) %CJS I UPDATED 4/26/2017
            other=orientedLabTimeSeries(newData,this.Time(1),this.sampPeriod,newLabels, orientation);
            newThis=cat(this,other);
        end
        
        function newThis=cat(this, other)
            newThis=cat@labTimeSeries(this,other);
            newThis=orientedLabTimeSeries(newThis.Data,this.Time(1),this.sampPeriod,newThis.labels,this.orientation);
        end
        
    end
    methods (Static)
        function OTS=getOTSfromOrientedData(data,t0,Ts,labelPrefixes,orientation)
            labels=[strcat(labelPrefixes,'x');strcat(labelPrefixes,'y');strcat(labelPrefixes,'z')];
            data=permute(data,[1,3,2]);
            OTS=orientedLabTimeSeries(data(:,:),t0,Ts,labels(:),orientation);
        end
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
            
extendedLabels=reshape(extendedLabels, 1, length(extendedLabels));%NEW CJS 5/5/2017
        end 
        function labelSane=checkLabelSanity(labels)
            %Check to make sure that labels are in expected or workable
            %format
            %
            %checks that there are multiples of 3 labels,i.e.
            %{'RHIPx','RHIPy','RHIPz',...}
            %
            %checks that x,y,z are labeled in that order
            %
            %also checks that each group of 3 labels have the same prefix
            
            labelSane=true;
            %Check: labels is a multiple of 3
            if mod(length(labels),3)~=0
                warning('Label length is not a multiple of 3, therefore they can''t correspond to 3D oriented data.')
                labelSane=false;
                return
            end
            %Check: all labels end in 'x','y' or 'z'
            aux2=cellfun(@(x) x(end),labels,'UniformOutput',false); %Should be 'x', 'y', 'z'
            if any(~strcmp(aux2(1:3:end),'x')) || any(~strcmp(aux2(2:3:end),'y')) || any(~strcmp(aux2(3:3:end),'z'))
               warning('Labels do not end in ''x'', ''y'', or ''z'' or in that order, as expected.') 
               labelSane=false;
               return
            end
            %Check: and labels have the same prefix in groups of 3
            aux=cellfun(@(x) x(1:end-1),labels,'UniformOutput',false);
            labelsx=aux(1:3:end);
            labelsy=aux(2:3:end);
            labelsz=aux(3:3:end);
            if any(~strcmp(labelsx,labelsy)) || any(~strcmp(labelsx,labelsz))
                labelSane=false;
                return
            end
        end
    end

end

