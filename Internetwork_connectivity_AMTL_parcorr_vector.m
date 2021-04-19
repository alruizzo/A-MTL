clear variables; close all; clc;
%% Script options

% Settings
cType = 0; % Local smoothed analysis: cType = 1; local unsmoothed: cType = 0

if cType
    dirData = 'Global';
else
    dirData = 'Global_uns';
end

% Index of networks of interest
    %intNets  = [15, 16, 2, 11, 3, 9, 10, 5, 1, 12, 8, 18]; % smoothed data
    intNets  = [8, 12, 19, 10, 14, 15, 7, 9, 20, 5, 1, 6]; % unsmoothed data
    
%% Load the data set (time courses) of subjects

for i=1:101  % loop for subjects
    if(i<11)
        subjCON{i}=load ([dirData, filesep, 'dr_stage1_subject0000',num2str(i-1),'.txt']);
        disp (['Included: ' 'dr_stage1_subject0000',num2str(i-1),'.txt'])
    elseif (i>=11 && i<101)
        subjCON{i}=load ([dirData, filesep, 'dr_stage1_subject000',num2str(i-1),'.txt']);
        disp (['Included: ' 'dr_stage1_subject000',num2str(i-1),'.txt'])
    else (i>11 && i>101 && i<=101);
        subjCON{i}=load ([dirData, filesep, 'dr_stage1_subject00',num2str(i-1),'.txt']);
        disp (['Included: ' 'dr_stage1_subject00',num2str(i-1),'.txt'])
    end
end

%% Extraction of IC of interest
dataSelect = zeros(numel(intNets));
SelectSubData = zeros(250,12); % rows (time course) and columns (ICs)
for idx=1:numel(subjCON)
    currSubjData = subjCON{1,idx};
    SelectSubData = currSubjData(:,intNets(1,:));
    subjCON{1,idx} = SelectSubData;
end

%% Loading TC of AM/coreMTL (last columns [21 and 22] in SubData)
%Put first the one you want to correlate the global/local patterns with
%the last will be the control variable in the parcorr

%AM [22]
AMPath = '/mnt/DATA/MTL/Original/ORIGINAL/calc_M_DPARSF/Results_AM_TC/ROISignals_FunImgRCWS/';

contentDirAM = dir([AMPath, '*ROISignals_*.txt']);

for idxNameAM = 1:numel(contentDirAM)
    currNameAM = contentDirAM(idxNameAM).name;
    currDataAM = load([AMPath, currNameAM]);
    subjCON{idxNameAM} = [subjCON{idxNameAM}, currDataAM];
    clear currDataAM
end

%CMTL [21]
TCPath = '/mnt/DATA/MTL/Original/ORIGINAL/calc_M_DPARSF/Results_cMTL_TC/ROISignals_FunImgRCWS_0mm/';

contentDir = dir([TCPath, '*ROISignals_*.txt']);

for idxName = 1:numel(contentDir)
    currName = contentDir(idxName).name;
    currData = load([TCPath, currName]);
    subjCON{idxName} = [subjCON{idxName}, currData];
    clear currData
end

%% Compute the correlation among ICs for CON subject by subject
for i=1:numel(subjCON) % subjects
    [RCON{i}, RCONpval{i}] = partialcorr(subjCON{i}(:,13),subjCON{i}(:,1:12),subjCON{i}(:,14)); % partial correlation controlling for the last TC path above
    %[RCON{i}, RCONpval{i}] = corr(subjCON{i}(:,13),subjCON{i}(:,1:12)); % only correlation
end

% R to Z transform with Fisher for all ICs
intNets  = [8, 12, 19, 10, 14, 15, 7, 9, 20, 5, 1, 6]; %unsmoothed data
%intNets  = [15, 16, 2, 11, 3, 9, 10, 5, 1, 12, 8, 18]; %smoothed data

for i=1:numel(subjCON)
    for j=1:numel(intNets)
        fisherZCON{i}(j) = 0.5*(log((1+RCON{i}(j))/(1-RCON{i}(j)))); % Fisher Z transformation
    end
end

FullFisherZCON = [];
for idx =1:size(fisherZCON,2) 
    FullFisherZCON = cat (3, FullFisherZCON, fisherZCON{1,idx});
end

%% Significance

 valid        = zeros(numel(intNets));
 %covariables  = xlsread('cov_std_C.xlsx');

 % One-sample t-test (ttest)
for x=1:length(FullFisherZCON(:,1,1))
    for y=1:length(FullFisherZCON(1,:,1))
        [h(x,y),pval(x,y),ci,stats]=ttest(FullFisherZCON(x,y,:));
        ciAll(x,y,1)        =ci(:,:,1);
        ciAll(x,y,2)        =ci(:,:,2);
            
        statsAll.tstat(x,y) = stats.tstat;
        statsAll.df(x,y)    = stats.df;
        statsAll.sd(x,y)    = stats.sd;
            
        %[corrAM(x,y,:), corrAMPval(x,y,:)] = corr(squeeze(FullFisherZCON(x,y,:)) , covariables );
        if (x<=y) % "x<y" if it's not a vector (but a matrix) to ignore autocorrelations (x=1 && y=1);
            valid(y,x) = valid(y,x) +1;
        end
    end
end

Zavg = mean(FullFisherZCON,3);
    
% Multiple comparison correction with FDR
q           = mafdr(pval(valid==1),'BHFDR','true');
indvalid    = find(valid==1); % only in the lower diagonal
pval2       = pval(indvalid);
R           = zeros(size(Zavg));
R(indvalid(pval2 < 0.05 & q < 0.05)) = 1; % extracting the significant
[MarkI,MarkJ] = ind2sub(size(R),find(R==1)); % For drawing the starts (*) in each cell
Rfdr = R;
    
%% To display results
varName = '1stt';
figure ('Color',[1,1,1],'Position', [10 10 900 450]);
%Zavg(Rfdr == 0) = 0;
imagesc(Zavg);
c = colorbar('southoutside', 'Ticks',[-1,-0.50,0,0.50,1]);%title(['c-MTL''s TC correlation with ' num2str(length (intNets)) ' local iFC'...
    %' (pval < 0.05 and q < 0.05)']);...
    caxis([-1, 1]);
c.Label.String = 'Average Z-value';
c.Label.FontWeight = 'bold';
text(MarkJ,MarkI,{'*'},'fontsize',8); % For drawing the starts (*) in each cell
colormap('redbluecmap');
set(gca,'Xtick',1:numel(intNets))
set(gca,'Ytick',1:numel(Zavg),'TickLength',[0 0])

%Xticklabels for local-iFC patterns
% xticklabels({'Anterior AM-1','Anterior EC-AM','Anterior PRC','Anterior HC-1',...
%              'Anterior AM-2','Anterior HC-2','Anterior HC-3','Central HC-1',...
%              'Central HC-2','Central HC-3','Posterior PHC-1','Posterior PHC-2'})

%Xticklabels for smoothed global-iFC patterns
% xticklabels({'Frontoinsular IC15','Orbitofrontal IC16','ACC IC11','Brain Stem IC3',...
%              'Thalamus + BG IC2','Left ventral IC9','Ventral frontal / parietal IC12','Dorsal frontal parietal IC5',...
%              'Parietal right IC1','Parietal left IC10','Ventral parietal IC8','Dorsal parietal IC18'})

%Xticklabels for unsmoothed global-iFC patterns
xticklabels({'IC8','IC12','IC19','IC10',...
             'IC14','IC15','IC7','IC9',...
             'IC20','IC5','IC1','IC6'})

xtickangle(45)
yticklabels({'AM [core MTL]'})
%xlabel('Mean Z values for each Network','FontSize',10,'FontWeight','bold','Color','b')

saveas(gcf,['INC_Zvals_' num2str(length (intNets)) '_Nets_for_' varName '_' date '.bmp']);

save AM_parcorrcMTL_unsmoothed_global_ICs