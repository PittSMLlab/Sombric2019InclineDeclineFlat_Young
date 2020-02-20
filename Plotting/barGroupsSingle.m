function barGroupsSingle(Study,results,groups,params,epochs,indivFlag,colorOrder,mode, row, col, sub)
%Make a bar plot to compare groups for a given epoch and parameter
%   TO DO: make function be able to accept a group array that is different
%   thand the groups in the results matrix

if nargin<8 || isempty(mode)
    mode=1;
end

if isempty(colorOrder)==1
poster_colors;
if length(groups)==3
    colorOrder=[p_red;  p_orange;p_fade_green; p_fade_blue; p_plum; p_green; p_blue; p_fade_red; p_lime; p_yellow; [0 0 0]; p_red; p_orange; p_fade_green; p_fade_blue; p_plum];
elseif length(groups)==2
    colorOrder=[ p_orange; p_fade_green;p_fade_blue; p_plum; p_green; p_blue; p_fade_red; p_lime; p_yellow;  p_red; p_orange; p_gray; p_fade_green; p_fade_blue; p_plum];
end
end
% poster_colors;
% if length(groups)==3
%     colorOrder=[p_red;p_red;  p_fade_green;p_orange; p_fade_blue; p_plum; p_green; p_blue; p_fade_red; p_lime; p_yellow; [0 0 0]];
% elseif length(groups)==2
%     colorOrder=[p_red;  p_fade_green;p_orange; p_fade_blue; p_plum; p_green; p_blue; p_fade_red; p_lime; p_yellow; [0 0 0]];
% end
% if nargin<7 || isempty(colorOrder) || size(colorOrder,2)~=3    
%     poster_colors;
%     %colorOrder=[p_red;  p_fade_green; p_orange;p_fade_blue; p_plum; p_green; p_blue; p_fade_red; p_lime; p_yellow; p_gray; p_black;[1 1 1]];   
%     colorOrder=[p_red;  p_fade_green;p_orange; p_fade_blue; p_plum; p_green; p_blue; p_fade_red; p_lime; p_yellow; [0 0 0]];
% end
%Set grey colors to use when individual subjects are plotted 
greyOrder=[0 0 0 ;1 1 1;0.5 0.5 0.5;0.2 0.2 0.2;0.9 0.9 0.9;0.1 0.1 0.1;0.8 0.8 0.8;0.3 0.3 0.3;0.7 0.7 0.7];

legendNAMES=[];
ngroups=length(groups);         
numPlots=length(epochs)*length(params);
numE=length(epochs);
% ah=optimizedSubPlot(numPlots,length(params),numE,'lr',12,10,12);
i=1;
for p=1:length(params)
     ReallyWhereStats=find(cellfun(@(x) strcmp(x, params{1}), fieldnames(results.(epochs{1}).indiv),'uniformoutput',1));
     
   limy=[];
   for t=1:numE
       subplot(row, col, sub)
       hold on
       for b=1:ngroups
           legendNAMES=[legendNAMES  groups{b}  Study.(groups{b}).ID];
           nSubs=length(Study.(groups{b}).ID);
           
           %attempt to abbreviate group name
%            adaptData=Study.(groups{b}).adaptData{1};
%            group=adaptData.metaData.ID;
%            spaces=find(group==' ');
%            abrevGroup=group(spaces+1);%
%            abrevGroups{b}=[group(1) abrevGroup];
                      
           %ind=find(strcmp(fields(Study),groups{b}));
           ind=b;
           switch mode
               case 1
                   if nargin>5 && indivFlag
                       %bar(b,results.(epochs{t}).avg(b,ReallyWhereStats),'facecolor',greyOrder(ind,:));
                       bar(b,results.(epochs{t}).avg(b,ReallyWhereStats),'facecolor',colorOrder(ind,:));
                       for s=1:nSubs
                           %                            aux=results.(epochs{t}).indiv.(params{ReallyWhereStats});
                           auxALL=results.(epochs{t}).indiv.(params{1});
                           aux=auxALL(auxALL(:,1)==b,2);
                           plot(b,aux(s),'.','Color',colorOrder(s,:))
                           
                           if b==ngroups && ngroups==2
                               aux2=auxALL(auxALL(:,1)==(b-1),2);
                               line([1 2],[aux2(s) aux(s) ], 'Color', colorOrder(s,:))
                           end
                           
                           
                       end
                   else
                       bar(b,results.(epochs{t}).avg(b,ReallyWhereStats),'facecolor',colorOrder(ind,:));
                   end
               case 2
                   %nope
           end
              %% Plot individual Subjects 4/18/19
       for s=1:length(Study.(groups{b}).ID)
           GroupIDPosition=find(results.(epochs{t}).indiv.(params{p})(:, 1)==b);
           %plot(b+((.9-.6).*rand(1) + .6),results.(epochs{t}).indiv.(params{p})(GroupIDPosition(s), 2),'Color','ko', 'MarkerFaceColor', 'k');%, 'MarkerFaceAlpha', .2
           s=scatter(b+((.35-.15).*rand(1) +.15),results.(epochs{t}).indiv.(params{p})(GroupIDPosition(s),2),20, 'k','filled'); %alpha(0.5)
           s.MarkerFaceAlpha=0.5;
       end
       end
       switch mode
           case 1
               errorbar(results.(epochs{t}).avg(:,ReallyWhereStats),results.(epochs{t}).se(:,ReallyWhereStats),'.','LineWidth',2,'Color','k')
           case 2
               errorbar(results.(epochs{t}).avg(:,ReallyWhereStats),results.(epochs{t}).se(:,ReallyWhereStats),'LineWidth',2,'Color','k')
       end
       
        
       %%
       if length(groups)==3
           set(gca,'Xtick',1:ngroups,'XTickLabel',{'D', 'F', 'I'},'fontSize',9);%Orignoal
       elseif length(groups)==2
           set(gca,'Xtick',1:ngroups,'XTickLabel',{'F', 'I'},'fontSize',9);%Orignoal
       else
       set(gca,'Xtick',1:ngroups,'XTickLabel',groups,'fontSize',9);%Orignoal
       end
       
       axis tight
       limy=[limy get(gca,'Ylim')];
       limy(find(abs(limy)==1))=[];
       %ylabel(params{p}())
       ylabel([epochs{t} ': ' params{p}()])
       offsettersP=(limy(end)*.05);
      offsetters=(limy(end-1)*.05);
       
        if ~isfield(results.(epochs{t}), 'p') ||  ~isfield(results.(epochs{t}), 'F')%~exist('results.(epochs{t}).p') %&& isempty(results.(epochs{t}).p)
            title(epochs{t})
       else
           %title([epochs{t} '  (p = ' num2str(results.(epochs{t}).p(ReallyWhereStats)) ')'])
           %title([epochs{t} '  (p = ' num2str(results.(epochs{t}).p(ReallyWhereStats), '%0.1d') ')'])
           if results.(epochs{t}).p(ReallyWhereStats)<0.001
               %title(['p = ' num2str(results.(epochs{t}).p(ReallyWhereStats), '%0.1d')]); % Scientific notation was not appreciated
               %title(['p < 0.001']); %General
               title({['p < 0.001'],...
                ['F(', num2str(results.(epochs{t}).F(2, ReallyWhereStats)), ',', num2str(results.(epochs{t}).F(3, ReallyWhereStats)), ')=', num2str(results.(epochs{t}).F(1, ReallyWhereStats),'%0.2f')]})
          
           else
            %title(['p = ' num2str(results.(epochs{t}).p(ReallyWhereStats), '%0.3f')])
            title({['p = ' num2str(results.(epochs{t}).p(ReallyWhereStats), '%0.3f')],...
                ['F(', num2str(results.(epochs{t}).F(2, ReallyWhereStats)), ',', num2str(results.(epochs{t}).F(3, ReallyWhereStats)), ')=', num2str(results.(epochs{t}).F(1, ReallyWhereStats),'%0.2f')]})
           end
       end
       i=i+1;

              %% PLOT POST HOC       
              if isfield(results.(epochs{t}), 'postHoc')  % Show the pst hoc
                  for ph=1:size(results.(epochs{t}).postHoc{ReallyWhereStats}, 1)
                      if isnan(results.(epochs{t}).postHoc{ReallyWhereStats}(ph, 1)) || isnan(results.(epochs{t}).postHoc{ReallyWhereStats}(ph, 2))
                          break
                      elseif abs(limy(end-1))>=abs(limy(end))
                          line([results.(epochs{t}).postHoc{ReallyWhereStats}(ph, 1) results.(epochs{t}).postHoc{ReallyWhereStats}(ph, 2)], [limy(end-1)+offsetters limy(end-1)+offsetters], 'Color', 'k')
                          limy(end-1)=limy(end-1)+offsetters;
                          if ph==size(results.(epochs{t}).postHoc{ReallyWhereStats}, 1)
                              ylim([limy(end-1)+2.*offsetters limy(end)])
                              %limy(end-1)=limy(end-1)+2.*offsetters;
                          else
                              limy(end-1)=limy(end-1)+offsetters;
                          end
                      elseif abs(limy(end-1))<abs(limy(end))
                          line([results.(epochs{t}).postHoc{ReallyWhereStats}(ph, 1) results.(epochs{t}).postHoc{ReallyWhereStats}(ph, 2)], [limy(end)+offsettersP limy(end)+offsettersP], 'Color', 'k')
                          if ph==size(results.(epochs{t}).postHoc{ReallyWhereStats}, 1)
                              ylim([ limy(end-1) limy(end)+2.*offsettersP])
                              %limy(end)=limy(end)+2.*offsettersP;
                          else
                              limy(end)=limy(end)+offsettersP;
                          end
                      end
                  end
              end
       
       
       % %        %% PLOT POST HOC       
% %        if isfield(results.(epochs{t}), 'postHoc')  % Show the pst hoc
% %            for ph=1:size(results.(epochs{t}).postHoc{ReallyWhereStats}, 1)
% %                if isnan(results.(epochs{t}).postHoc{ReallyWhereStats}(ph, 1)) || isnan(results.(epochs{t}).postHoc{ReallyWhereStats}(ph, 2)) 
% %                    break
% %                elseif abs(limy(end-1))>=abs(limy(end)) 
% %                     line([results.(epochs{t}).postHoc{ReallyWhereStats}(ph, 1) results.(epochs{t}).postHoc{ReallyWhereStats}(ph, 2)], [limy(end-1)+ph.*(limy(end-1)*.05) limy(end-1)+ph.*(limy(end-1)*.05)], 'Color', 'k')
% %                     limy(end-1)=limy(end-1)+(ph+1).*(limy(end-1)*.05);
% %                elseif abs(limy(end-1))<abs(limy(end))
% %                     line([results.(epochs{t}).postHoc{ReallyWhereStats}(ph, 1) results.(epochs{t}).postHoc{ReallyWhereStats}(ph, 2)], [limy(end)+ph.*(limy(end)*.05) limy(end)+ph.*(limy(end)*.05)], 'Color', 'k')
% %                     limy(end)=limy(end)+(ph+1).*(limy(end)*.05);
% %                end
% %            end
% %        end
%        %% PLOT DIFF FROM ZERO: CJS new 7/12/2017
%        if isfield(results.(epochs{t}), 'DiffZero')  % if we have stats indicating different from zero 'DiffZero'
%            for g=1:size(results.(epochs{t}).DiffZero, 1)
%                if results.(epochs{t}).DiffZero(g, ReallyWhereStats)>0.05
%                    scatter((g+.2), results.(epochs{t}).avg(g,ReallyWhereStats), 's', 'FaceColor', 'k')
%                end         
%            end
%        end
   end
   %set(ah(p*numE-(numE-1):p*numE),'Ylim',[min(limy) max(limy)])% 6/2016
   set(gcf,'Renderer','painters');
%    if nargin>5 && indivFlag
%       legend(legendNAMES)
%    else
%        legend(groups)
%    end
end

end

