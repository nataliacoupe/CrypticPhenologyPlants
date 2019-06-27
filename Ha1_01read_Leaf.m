% .........................................................................
% Reads NACP model output leaf allocation and calculates NPPleaf from litter-fall
% and LAI observations. Please refer to the readme ReadmeLeaf.txt
% Natalia Restrepo-Coupe
% nataliacoupe@gmail.com
% Saleska's lab - University of Arizona
% 2019 May 01 (spring) Toronto Canada
% .........................................................................
flag_unix = 0;    flag_figure_16 = 1;      flag_figure_30 = 1;
flag_read = 1;    flag_obs = 1;

%% Point where data is ....................................................
if flag_unix == 1
    FolderFluxnet  =  'C:\Users\ncoupe\Documents\Fluxnet\';
elseif flag_unix == 0
    addpath /home/ncoupe/Documents/OZ/
    addpath /home/ncoupe/Documents/Amazon/
    FolderFluxnet  =  '/media/ncoupe/Backup/Data/Fluxnet/';
    FolderNACP     =  '/media/ncoupe/Backup/Data/NACP/US-Ha1/';
    %load 'NACP.ameriflux.mat';
    load '/media/ncoupe/Backup/Data/Fluxnet/siteFN.mat';
    slash          =  '/';
end

% Color palette and time vectors...........................................
color_mtx = [253/255 174/255 97/255; 101/255 161/255 104/255; 215/255  25/255 28/255; 253/255 174/255 97/255; 101/255 161/255 104/255; 43/255 131/255 186/255;...
    0.1020 0.5882 0.2549; 0.1020 0.5882 0.2549; 0.1020 0.5882 0.2549; 0.1020 0.5882 0.2549];

ModelNameShort = {'CLM4.5','CLASS','ORCHIDEE_{TRUNK}'};
ABGBleaf = [];            NPPleaf = [];

month_avg  =  (datenum(0,1,1):1:datenum(0,12,31))';
[Ymonth,Mmonth,Dmonth] = datevec(month_avg);        month_avg(Dmonth~= 1) = [];
week_avg  =  (datenum(0,1,1):16:datenum(0,12,31))';
[Yweek,Mweek,Dweek] = datevec(week_avg);
eigth_avg  =  (datenum(0,1,1):8:datenum(0,12,31))';
[Yeigth,Meigth,Deigth] = datevec(eigth_avg);
day_avg  =  (1:1:365)';
[Yday,Mday,Dday] = datevec(day_avg);

YearINI = 1991;           YearEND = 2019;

% Read models ..................................................
if flag_read == 1
    %...........................................................
    %% Import data from ORCHIDEE
    %...........................................................
    delimiter   =  ' ';
    formatSpec  =  '%f%f%f%f%f%f%f%f%f%f%f%f%f%[^\n\r]';
    fileID     =  fopen([FolderNACP 'ORCHIDEE/TRUNK.txt'],'r');
    dataArray  =  textscan(fileID, formatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'EmptyValue' ,NaN, 'ReturnOnError', false);
    fclose(fileID);
    
    %% Allocate imported array to column variable names
    %fluxes (GPP, NPP, RESP) is gC/m2/day, and for C pools is gC /m2
    GPP  =  dataArray{:, 1};          NPP  =  dataArray{:, 2};
    GROWTH_RESP  =  dataArray{:, 3};  MAINT_RESP  =  dataArray{:, 4};
    HET_RESP  =  dataArray{:, 5};     LEAF_M  =  dataArray{:, 6};
    SAP_M_AB  =  dataArray{:, 7};     SAP_M_BE  =  dataArray{:, 8};
    HEART_M_AB  =  dataArray{:, 9};   HEART_M_BE  =  dataArray{:, 10};
    ROOT_M  =  dataArray{:, 11};      FRUIT_M  =  dataArray{:, 12};
    RESERVE_M  =  dataArray{:, 13};
    
    % Clear temporary variables
    clearvars filename delimiter formatSpec fileID dataArray ans;
    
    datelocABGBleaf_orchidee = (datenum(1900,1,1):1:datenum(1999,12,31))';
    [Y,M,D] = datevec(datelocABGBleaf_orchidee);      datelocABGBleaf_orchidee((M == 2)&(D == 29)) = [];
    ind = find((datelocABGBleaf_orchidee>=datenum(YearINI,1,1))&(datelocABGBleaf_orchidee<=datenum(YearEND+1,1,1)));          %select times I want the data
    datelocABGBleaf_orchidee = datelocABGBleaf_orchidee(ind);
    ix  =  LEAF_M(ind);
    ABGBleaf(3).mean01 = ix;
    ABGBleaf(3).date01  =  datelocABGBleaf_orchidee;
    
    % Subsample after 1991 and then get monthly values
    [ix,~,~,iy]            = AM_month(ABGBleaf(3).mean01,ABGBleaf(3).date01);
    ABGBleaf(3).date30     = iy;
    ABGBleaf(3).mean30     = ix;
    ABGBleaf(3).mean_avg30 = AM_month_avg(ABGBleaf(3).mean30,ABGBleaf(3).date30);
    
    [ix,~,~,~,~,~,iy]  = AM_week2day_rs(ABGBleaf(3).mean01,ABGBleaf(3).date01);
    ABGBleaf(3).date16     = iy;
    ABGBleaf(3).mean16     = ix;
    ABGBleaf(3).mean_avg16 = AM_week2_avg(ABGBleaf(3).mean16,ABGBleaf(3).date16);
    
    [ix,~,~,~,~,~,iy]  = AM_week2day_rs(ABGBleaf(3).mean01,ABGBleaf(3).date01);
    ABGBleaf(3).date08     = iy;
    ABGBleaf(3).mean08     = ix;
    ABGBleaf(3).mean_avg108 = AM_week2_avg(ABGBleaf(3).mean08,ABGBleaf(3).date08);
    %%
    figure('color','white');                plot(ABGBleaf(3).date01,ABGBleaf(3).mean01);
    datetick('x');  hold on; ylabel('ABGBleaf_{daily ORCHIDEE}(gC m^2 d^1)');
    plot(ABGBleaf(3).date30,ABGBleaf(3).mean30);
    plot(ABGBleaf(3).date16,ABGBleaf(3).mean16);
    plot(ABGBleaf(3).date08,ABGBleaf(3).mean08);
    legend ('monthly','16-days','8-day');
    
    %...........................................................
    %% Import data from CLM3.5
    %...........................................................
    FileName  =  [ FolderNACP 'CLM3.5' slash 'US-Ha1_I20TRCLM45CBCN.clm2.h0.1991-2013.daily.nc'];
    %     ncdisp(FileName)
    cLeaf    =  ncread(FileName,'cleaf');       % 'KgC m-2'
    LAI      =  ncread(FileName,'LAI');         % 'KgC m-2'
    dateloc_clm  =  ncread(FileName,'time');    % monthly data no leap
    dateloc_clm  =  double(dateloc_clm);        dateloc_clm  =  dateloc_clm + datenum(1850,1,1);
    [Y,M,D]  =  datevec(dateloc_clm);
    
    ind = find((dateloc_clm>=datenum(YearINI,1,1))&(dateloc_clm<=datenum(YearEND+1,1,1)));          %select times I want the data
    ABGBleaf(1).mean01 = cLeaf(ind).*1000;
    ABGBleaf(1).date01 = dateloc_clm(ind);
    ABGBlai(1).mean01  = LAI(ind);
    
    [ix,~,~,iy]  =  AM_month(ABGBleaf(1).mean01,ABGBleaf(1).date01);
    ABGBleaf(1).date30      = iy;
    ABGBleaf(1).mean30      = ix;
    ABGBleaf(1).mean_avg30  = AM_month_avg(ABGBleaf(1).mean30,ABGBleaf(1).date30);
    
    [ix,~,~,~,~,~,iy]  = AM_week2day_rs(ABGBleaf(1).mean01,ABGBleaf(1).date01);
    ABGBleaf(1).date16     = iy;
    ABGBleaf(1).mean16     = ix;
    ABGBleaf(1).mean_avg16 = AM_week2_avg(ABGBleaf(1).mean16,ABGBleaf(1).date16);
    
    [ix,~,~,~,~,~,iy]  = AM_eightday_rs(ABGBleaf(1).mean01,ABGBleaf(1).date01);
    ABGBleaf(1).date08     = iy;
    ABGBleaf(1).mean08     = ix;
    ABGBleaf(1).mean_avg08 = AM_eight_avg(ABGBleaf(1).mean08,ABGBleaf(1).date08);
    
    figure('color','white');                plot(ABGBleaf(1).date01,ABGBleaf(1).mean01);
    datetick('x');  hold on; ylabel('ABGBleaf_{daily CLM3.5}(gC m^2 d^1)');
    plot(ABGBleaf(1).date30,ABGBleaf(1).mean30);
    
    % close all
    
    %..........................................................................
    % Calculating the rate
    %..........................................................................
    for ik = 1:3
        figure('color','white');     subplot(2,1,1);
        if ik==2;   ik=3; end        % Leaf NPP for CLASS is missing
        %..................................................................
        iy = diff(ABGBleaf(ik).mean01);         iy = [iy(1);iy];
        
        subplot(2,1,1);
        plot(ABGBleaf(ik).date01,iy);           hold on;
        
        iy(iy<-0.2) = NaN;
        
        plot(ABGBleaf(ik).date01,iy,'k');       ylabel('NPP_{leaf} (gC m^-^2 d^-^1)');
        plot(ABGBleaf(ik).date01,iy.*0,':k');   datetick('x');
        
        NPPleaf(ik).mean01 = iy./1;
        NPPleaf(ik).date01 = ABGBleaf(ik).date01;
        
        iy = NPPleaf(ik).mean01;  
        dateloc = NPPleaf(ik).date01;
        [NPPleaf(ik).mean_avg01,NPPleaf(ik).std_avg01] = AM_day_avg(iy,dateloc);
        
        subplot(2,1,2);
        plot(day_avg,NPPleaf(ik).mean_avg01);  hold on;
        
        iy = smooth(NPPleaf(ik).mean_avg01);
        
        plot(day_avg,iy,'k');           plot(day_avg,iy.*0,':k');       title(ModelNameShort(ik));
        %         plot(day_avg,NPPleaf(ik).mean_avg01);
        ylabel('NPP_{leaf avg all years} (gC m^-^2 d^-^1)');
        legend('daily','daily_{5 day window}');
        datetick('x')
        
        display ([ModelNameShort(ik) find(iy==nanmax(iy))])
        
        [NPPleaf(ik).mean30,~,~,NPPleaf(ik).date30] = AM_month(NPPleaf(ik).mean01,NPPleaf(ik).date01);
        [NPPleaf(ik).mean16,~,~,~,~,~,NPPleaf(ik).date16] = AM_week2day_rs(NPPleaf(ik).mean01,NPPleaf(ik).date01);
        [NPPleaf(ik).mean08,~,~,~,~,~,NPPleaf(ik).date08] = AM_eightday_rs(NPPleaf(ik).mean01,NPPleaf(ik).date01);
        
        [NPPleaf(ik).mean_avg30,~,NPPleaf(ik).std_avg30] = AM_month_avg(NPPleaf(ik).mean30,NPPleaf(ik).date30);
        [NPPleaf(ik).mean_avg16,~,NPPleaf(ik).std_avg16] = AM_week2_avg(NPPleaf(ik).mean16,NPPleaf(ik).date16);
        [NPPleaf(ik).mean_avg08,~,NPPleaf(ik).std_avg08] = AM_eight_avg(NPPleaf(ik).mean08,NPPleaf(ik).date08);
        [NPPleaf(ik).mean_avg01,~,NPPleaf(ik).std_avg01] = AM_day_avg(NPPleaf(ik).mean01,NPPleaf(ik).date01);
        
    end
end

% Process the observations ................................................
if flag_obs == 1
    %......................................................................
    %% First read the litterfall
    %......................................................................
    filename   =  [FolderFluxnet 'US-Ha1/Litterfall/hf069-05-litter.txt'];
    delimiter  =  ',';
    startRow   =  2;
    formatSpec =  '%f%f%f%f%f%s%s%s%f%[^\n\r]';
    fileID     =  fopen(filename,'r');
    dataArray  =  textscan(fileID, formatSpec, 'Delimiter', delimiter,...
        'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    fclose(fileID);
    YYYY      =  dataArray{:, 3};   MM = dataArray{:, 4};   DD = dataArray{:, 5};
    date = datenum(YYYY,MM,DD);                             litterfall = dataArray{:,9};
    figure('color','white');        hold on;                plot(date,litterfall)
    
    % add January to March as zero.........................................
    b = unique(YYYY);       c = [1;2;3];
    for ik = 1:length(b)
        date = [date;datenum(b(ik),c,1)];     litterfall = [litterfall;c*0];
    end
    A = [date,litterfall];                    B = sortrows(A,1);
    date = B(:,1);                            litterfall = B(:,2);
    [id,~,c]=unique(date);
    [ii,jj] = ndgrid(c,1:size(litterfall,2));
    out = accumarray([ii(:),jj(:)], litterfall(:), [], @mean);
    
    plot(id,out);
    
    ABGBlitter_obs.date = id;                  ABGBlitter_obs.litterfall = out;
    plot(id,out,'.','color',[0.9 0.5 0.]);     ylabel('litterfall');
    datetick('x');
    
    clearvars filename delimiter startRow formatSpec fileID dataArray ans;
    
    ABGBlitter_obs.date01  =  (datenum(nanmin(YYYY),1,1):1:datenum(nanmax(YYYY),12,31))';
    ABGBlitter_obs.mean01  =  interp1(ABGBlitter_obs.date,ABGBlitter_obs.litterfall,ABGBlitter_obs.date01,'linear');
    
    figure('color','white');
    subplot(2,1,1);   plot(ABGBlitter_obs.date01,ABGBlitter_obs.mean01,'k');
    hold on;
    plot(ABGBlitter_obs.date,ABGBlitter_obs.litterfall);
    plot(ABGBlitter_obs.date,ABGBlitter_obs.litterfall,'.');
    
    datetick('x');            hold on;          ylabel('ABGB_{litterfall obs}(gC m^-^2)');
    axis([datenum(1998,1,1) datenum(2018,1,1) 0 8]);
    
    [~,ABGBlitter_obs.sum30,~,ABGBlitter_obs.date30,~,~,ABGBlitter_obs.std30]  = AM_month(ABGBlitter_obs.mean01,ABGBlitter_obs.date01);
    [~,ABGBlitter_obs.mean16,~,~,~,ABGBlitter_obs.std16,ABGBlitter_obs.date16] = AM_week2day_rs(ABGBlitter_obs.mean01,ABGBlitter_obs.date01);
    
    %......................................................................
    %% Read the LAI observations
    %......................................................................
    filename   =  [FolderFluxnet 'US-Ha1/LAI/hf069-02-LAI-site.txt'];
    delimiter  =  ',';
    startRow   =  2;
    formatSpec = '%f%f%f%f%f%s%f%f%f%f%f%f%f%[^\n\r]';
    fileID     =  fopen(filename,'r');
    dataArray  =  textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    fclose(fileID);
    site      =  dataArray{:, 6};
    date      =  datenum(dataArray{:, 4},1,dataArray{:, 5});
    totalts   =  dataArray{:, 8};
    totalts(strcmp(site,'harv')) = [];        date(strcmp(site,'harv')) = [];
    
    [id,~,c]=unique(date);
    [ii,jj] = ndgrid(c,1:size(totalts,2));
    bb = accumarray([ii(:),jj(:)], totalts(:), [], @mean);
    
    difftotalts  =  diff(bb);    difftotalts  =  [NaN;difftotalts];
    difftotalts  =  AM_rm_outlier(difftotalts,3);
    clearvars filename delimiter startRow formatSpec fileID dataArray ans;
    %%
    figure('color','white');subplot(2,1,1); plot(date,totalts);
    hold on;                plot(id,bb,'.');
    datetick('x');          hold on;        ylabel('LAI_{obs}');
    axis([datenum(1998,1,1) datenum(2018,1,1) 0 6]);
    
    subplot(2,1,2); plot(id,difftotalts);   hold on
    plot(id,difftotalts,'.');               plot(id,id.*0,':k');
    datetick('x');          hold on;        ylabel('\Delta LAI_{ obs}(d^-^1)');
    axis([datenum(1998,1,1) datenum(2018,1,1) -2 4]);
    
    ABGBlaiObs.date   =  id;
    ABGBlaiObs.lai    =  bb;
    
    ABGBlaiObs.date01 = (id(1):1:id(end))';
    ABGBlaiObs.mean01 = interp1(ABGBlaiObs.date,ABGBlaiObs.lai,ABGBlaiObs.date01);
    ABGBlaiObs.mean01((ABGBlaiObs.date01>datenum(2000,1,1))&(ABGBlaiObs.date01<datenum(2005,10,1)))= NaN;
    
    [ABGBlaiObs.mean30,~,~,ABGBlaiObs.date30,~,~,ABGBlaiObs.std30] = AM_month(ABGBlaiObs.mean01,ABGBlaiObs.date01);
    [ABGBlaiObs.mean16,~,~,~,~,ABGBlaiObs.std16,ABGBlaiObs.date16] = AM_week2day_rs(ABGBlaiObs.mean01,ABGBlaiObs.date01);
    [ABGBlaiObs.mean08,~,~,~,~,ABGBlaiObs.std08,ABGBlaiObs.date08] = AM_eightday_rs(ABGBlaiObs.mean01,ABGBlaiObs.date01);
    
    ABGBlaiObs.mean_avg30 = AM_month_avg(ABGBlaiObs.mean30,ABGBlaiObs.date30);
    ABGBlaiObs.mean_std30 = AM_month_avg(ABGBlaiObs.std30,ABGBlaiObs.date30);
    ABGBlaiObs.mean_avg16 = AM_week2_avg(ABGBlaiObs.mean16,ABGBlaiObs.date16);
    ABGBlaiObs.mean_std16 = AM_week2_avg(ABGBlaiObs.std16,ABGBlaiObs.date16);
    ABGBlaiObs.mean_avg08 = AM_eight_avg(ABGBlaiObs.mean08,ABGBlaiObs.date08);
    ABGBlaiObs.mean_std08 = AM_eight_avg(ABGBlaiObs.std08,ABGBlaiObs.date08);
    
    %......................................................................
    %% Calculate NPP leaf
    %......................................................................
    % SLA mg cm-2 >>> g/1000 10000/m2  >>> g*10/m2
    % https://escholarship.org/content/qt7ht7565c/qt7ht7565c.pdf
    % Scaling gross ecosystem production at Harvard Forest with remote sensing: a
    % comparison of estimates from a constrained quantum‐use efficiency model and eddy correlation
    % Waring, Law, Goulden et al. 1995
    % August mg cm-2  5.46 + 8.22 + 5.05 + 9.76 + 5.67 + 8.65 + 4.10 + 9.83
    % September mg cm-2 4.92 + 8.96 + 5.79 + 8.72 + 6.94 + 8.76 + 3.55 + 5.61
    ix = (5.46 + 8.22 + 5.05 + 9.76 + 5.67 + 8.65 + 4.10 + 9.83)*10/8;
    iy = (4.92 + 8.96 + 5.79 + 8.72 + 6.94 + 8.76 + 3.55 + 5.61)*10/8;  %g m-2
    
    dLAIdt = diff(ABGBlaiObs.mean01);    dLAIdt  =  [NaN;dLAIdt];
    dLAIdt = AM_rm_outlier(dLAIdt,3);
    litter = interp1(ABGBlitter_obs.date01,ABGBlitter_obs.mean01,ABGBlaiObs.date01);
    [YYYY,MM,DD] = datevec(ABGBlaiObs.date01);
    
    % Set January to March as zero change in LAI (no obsesrvations available - winter)
    dateSLA = [];           obsSLA = [];
    b = unique(YYYY);       c = [8;9];              d = [ix;iy];
    for ik = 1:length(b)
        dateSLA = [dateSLA;datenum(b(ik),c,1)];     obsSLA = [obsSLA;d];
    end
    
    SLA = interp1(dateSLA,obsSLA,ABGBlaiObs.date01);       ix = smooth(SLA,60);
    ix(isnan(SLA)) = NaN;                                   SLA = ix;
    ix = (dLAIdt.*SLA) + litter;
    ix(isnan(litter)) = NaN;
    NPPleafObs = [];                                        NPPleafObs.mean01 = ix;
    ABGBleafObs.mean01 = (SLA.*ABGBlaiObs.mean01)+litter;
    ABGBleafObs.date01 = ABGBlaiObs.date01;
    
    % Figures
    figure('color','white');
    subplot(2,1,1);   plot(ABGBlaiObs.date01,NPPleafObs.mean01,'k');
    hold on;
    plot(ABGBlaiObs.date01,NPPleafObs.mean01,'.');
    datetick('x');            hold on;          ylabel('NPP_{leaf}(gC m^-^2 d^-^1)');
    axis([datenum(1998,1,1) datenum(2018,1,1) 0 8]);
    
    
    [NPPleafObs.mean30,~,~,NPPleafObs.date30,~,~,NPPleafObs.std30] = AM_month(NPPleafObs.mean01,ABGBlaiObs.date01);
    [NPPleafObs.mean16,~,~,~,~,NPPleafObs.std16,NPPleafObs.date16] = AM_week2day_rs(NPPleafObs.mean01,ABGBlaiObs.date01);
    [NPPleafObs.mean08,~,~,~,~,NPPleafObs.std08,NPPleafObs.date08] = AM_eightday_rs(NPPleafObs.mean01,ABGBlaiObs.date01);
    
    NPPleafObs.mean_avg30  = AM_month_avg(NPPleafObs.mean30,NPPleafObs.date30);
    NPPleafObs.mean_std30  = AM_month_avg(NPPleafObs.std30,NPPleafObs.date30);
    
    NPPleafObs.mean_avg16  = AM_week2_avg(NPPleafObs.mean16,NPPleafObs.date16);
    NPPleafObs.mean_std16  = AM_week2_avg(NPPleafObs.std16,NPPleafObs.date16);
    
    NPPleafObs.mean_avg08  = AM_eight_avg(NPPleafObs.mean08,NPPleafObs.date08);
    NPPleafObs.mean_std08  = AM_eight_avg(NPPleafObs.std08,NPPleafObs.date08);
    
    [NPPleafObs.mean_avg01,NPPleafObs.mean_std01]   = AM_day_avg(NPPleafObs.mean01,ABGBlaiObs.date01);
    [ABGBleafObs.mean_avg01,ABGBleafObs.mean_std01] = AM_day_avg(ABGBleafObs.mean01,ABGBlaiObs.date01);
end
% close all;
% ......................................................................
%% Figures for 16-day seasonal cycles
% ......................................................................
if flag_figure_16 == 1
    month_avg  =  (datenum(0,1,1):1:datenum(0,12,31))';
    [Ymonth,Mmonth,Dmonth] = datevec(month_avg);        month_avg(Dmonth~= 1) = [];
    week_avg   =  (datenum(0,1,1):16:datenum(0,12,31))';
    v1 = -3;         v2 = 7;        v3 = [v1;0;3;6];
    figure('color','white');
    subplot(2,2,1);             hold on;
    x4 = zeros(12,1);             x4(4:9) = (v2);
    hl1  =  bar(month_avg,x4,1,'FaceColor',[ 0.9 0.9 0.9],'EdgeColor',[ 0.9 0.9 0.9]);
    hl2  =  bar(month_avg,-x4,1,'FaceColor',[ 0.9 0.9 0.9],'EdgeColor',[ 0.9 0.9 0.9]);
    monthNPPleafObs      =  NPPleafObs.mean_avg16;
    monthNPPleafObs_std  =  NPPleafObs.mean_std16;
    y  =  [(monthNPPleafObs-monthNPPleafObs_std),(2.*monthNPPleafObs_std)];
    h   =   area(week_avg,y);       set(gca,'Layer','top');
    set(h(2),'FaceColor',[.7 .7 .7],'EdgeColor',[.7 .7 .7]);       set(h(1),'FaceColor','none','EdgeColor','none');
    set(h,'BaseValue',0);
    hl6  =  plot(week_avg,NPPleafObs.mean_avg16,'Color',[0 0 0],'LineWidth',2);
    % CLASS was not available
    % %     ik = 2;   weekNPPleaf = NPPleaf(ik).mean_avg16;
    % %     hl3  =  plot(month_avg,weekNPPleaf,'Color',color_mtx(ik,:),'LineWidth',2);
    ik = 3; weekNPPleaf = NPPleaf(ik).mean_avg16;
    hl4  =  plot(week_avg,weekNPPleaf,'Color',color_mtx(ik,:),'LineWidth',2);
    ik = 1; weekNPPleaf = NPPleaf(ik).mean_avg16;
    hl5  =  plot(week_avg,weekNPPleaf,'Color',color_mtx(ik,:),'LineWidth',2);
    hl7  =  plot(week_avg,week_avg.*0,':k','LineWidth',1);
    %     for ik=3      %model
    %         weekNPPleaf=month_avgNPPleaf(ip).model(ik).avg;   %Kgm2m1_gm2d1.*month_avgNPPleaf(ip).model(ik).avg;
    %         hl7 = plot(month_avg,weekNPPleaf,'--','Color',color_mtx(ik,:),'LineWidth',2);
    %     end;
    xlim([month_avg(1) month_avg(end)+8]);                   ylim([v1 v2]);
    set(gca,'XTick',month_avg,'XTickLabel',[ '' '' ''],'YTick',v3,'XTickLabel',[{datestr(month_avg,4)}],'FontSize',11);
    ax1  =  gca;      set(ax1,'XColor','k','YColor',[ 0.0 0.0 0.0],'Position',[0.17 0.7 0.28 0.20]);
    ylabel ({'NPP_{leaf}';'(gC m^-^2 d^-^1)'},'FontSize',11);
    box on;
    legend([hl6,hl4,hl5],'Litter and LAI-derived biomass',...%,hl7
        [ModelNameShort{3} ' \Delta leaf biomass'],...
        [ModelNameShort{1} ' \Delta leaf biomass']);
    legend boxoff;
    %%
    v1 = -1.5;                  v2 = 1.5;        v3 = v1:((1-v1)/2):1;
    subplot(2,2,3);             hold on;
    x4 = zeros(12,1);           x4(4:9) = (v2);
    hl1  =  bar(month_avg,x4,1,'FaceColor',[ 0.9 0.9 0.9],'EdgeColor',[ 0.9 0.9 0.9]);
    hl2  =  bar(month_avg,-x4,1,'FaceColor',[ 0.9 0.9 0.9],'EdgeColor',[ 0.9 0.9 0.9]);
    monthNPPleafObs      =  NPPleafObs.mean_avg16;
    monthNPPleafObs_std  =  NPPleafObs.mean_std16;
    y  =  [(monthNPPleafObs-monthNPPleafObs_std)./nanmax(monthNPPleafObs),(2.*monthNPPleafObs_std)./nanmax(monthNPPleafObs)];
    h   =   area(week_avg,y);       set(gca,'Layer','top');
    set(h(2),'FaceColor',[.7 .7 .7],'EdgeColor',[.7 .7 .7]);       set(h(1),'FaceColor','none','EdgeColor','none');
    set(h,'BaseValue',0);
    hl6  =  plot(week_avg,monthNPPleafObs./nanmax(monthNPPleafObs),'Color',[0 0 0],'LineWidth',2);
    %     ik = 2;   monthNPPleaf = NPPleaf(ik).mean_avg16;
    %     hl3  =    plot(week_avg,monthNPPleaf./nanmax(monthNPPleaf),'Color',color_mtx(ik,:),'LineWidth',2);
    ik = 3;   weekNPPleaf = NPPleaf(ik).mean_avg16;
    hl4  =  plot(week_avg,weekNPPleaf./nanmax(weekNPPleaf),'Color',color_mtx(ik,:),'LineWidth',2);
    ik = 1;   weekNPPleaf = NPPleaf(ik).mean_avg16;
    hl5  =  plot(week_avg,weekNPPleaf./nanmax(weekNPPleaf),'Color',color_mtx(ik,:),'LineWidth',2);
    hl7  =  plot(week_avg,week_avg.*0,':k','LineWidth',1);
    xlim([week_avg(1) week_avg(end)+8]);                   ylim([v1 v2]);
    set(gca,'XTick',month_avg,'XTickLabel',[ '' '' ''],'YTick',v3,'XTickLabel',[{datestr(month_avg,4)}],'FontSize',11);
    ax1  =  gca;      set(ax1,'XColor','k','YColor',[ 0.0 0.0 0.0],'Position',[0.17 0.2 0.28 0.20]);
    ylabel ({'NPP_{leaf}/NPP_{leaf max}'},'FontSize',11);
    box on;
    legend([hl6,hl4,hl5],'Obs',ModelNameShort{3},ModelNameShort{1});
    legend boxoff;   
end

% ......................................................................
%% Figures for monthly and weekly seasonal cycles
% ......................................................................
if flag_figure_30 == 1
    month_avg  =  (datenum(0,1,1):1:datenum(0,12,31))';
    [Ymonth,Mmonth,Dmonth] = datevec(month_avg);        month_avg(Dmonth~= 1) = [];
    eight_avg   =  (datenum(0,1,1):8:datenum(0,12,31))';
    v1 = -3;         v2 = 9;        v3 = v1:((v2-v1)/4):v2;
    figure('color','white');
    subplot(2,2,1);             hold on;
    x4  = zeros(12,1);             x4(4:9) = (v2);
    hl1 = bar(month_avg,x4,1,'FaceColor',[ 0.9 0.9 0.9],'EdgeColor',[ 0.9 0.9 0.9]);
    hl2 = bar(month_avg,-x4,1,'FaceColor',[ 0.9 0.9 0.9],'EdgeColor',[ 0.9 0.9 0.9]);
    monthNPPleafObs      =  NPPleafObs.mean_avg08;
    monthNPPleafObs_std  =  NPPleafObs.mean_std08;
    y  = [(monthNPPleafObs-monthNPPleafObs_std),(2.*monthNPPleafObs_std)];
    h  = area(eight_avg,y);       set(gca,'Layer','top');
    set(h(2),'FaceColor',[.7 .7 .7],'EdgeColor',[.7 .7 .7]);       set(h(1),'FaceColor','none','EdgeColor','none');
    set(h,'BaseValue',0);
    hl6  = plot(eight_avg,NPPleafObs.mean_avg08,'Color',[0 0 0],'LineWidth',2);
    % %     ik = 2;   eightNPPleaf = NPPleaf(ik).mean_avg08;
    % %     hl3  =  plot(month_avg,eightNPPleaf,'Color',color_mtx(ik,:),'LineWidth',2);
    ik  = 3;   eightNPPleaf = NPPleaf(ik).mean_avg08;
    hl4 = plot(eight_avg,eightNPPleaf,'Color',color_mtx(ik,:),'LineWidth',2);
    ik  = 1;   eightNPPleaf = NPPleaf(ik).mean_avg08;
    hl5 = plot(eight_avg,eightNPPleaf,'Color',color_mtx(ik,:),'LineWidth',2);
    hl7 = plot(eight_avg,eight_avg.*0,':k','LineWidth',1);
    
    %     for ik=3      %model
    %         eightNPPleaf=month_avgNPPleaf(ip).model(ik).avg;   %Kgm2m1_gm2d1.*month_avgNPPleaf(ip).model(ik).avg;
    %         hl7 = plot(month_avg,eightNPPleaf,'--','Color',color_mtx(ik,:),'LineWidth',2);
    %     end;
    
    xlim([month_avg(1) month_avg(end)+8]);                   ylim([v1 v2]);
    set(gca,'XTick',month_avg,'XTickLabel',[ '' '' ''],'YTick',v3,'XTickLabel',[{datestr(month_avg,4)}],'FontSize',11);
    ax1  =  gca;      set(ax1,'XColor','k','YColor',[ 0.0 0.0 0.0],'Position',[0.17 0.7 0.28 0.20]);
    ylabel ({'NPP_{leaf weekly}';'(gC m^-^2 d^-^1)'},'FontSize',11);
    box on;
    legend([hl6,hl4,hl5],'Litter and LAI-derived biomass',...
        [ModelNameShort{3} ' \Delta leaf biomass'],...
        [ModelNameShort{1} ' \Delta leaf biomass']);
    legend boxoff;
    
    
    month_avg  =  (datenum(0,1,1):1:datenum(0,12,31))';
    [Ymonth,Mmonth,Dmonth] = datevec(month_avg);        month_avg(Dmonth~= 1) = [];
    v1 = -2;         v2 = 8;        v3 = v1:((v2-v1)/4):v2;
    figure('color','white');
    subplot(2,2,1);             hold on;
    x4  = zeros(12,1);             x4(4:9) = (v2);
    hl1 = bar(month_avg,x4,1,'FaceColor',[ 0.9 0.9 0.9],'EdgeColor',[ 0.9 0.9 0.9]);
    hl2 = bar(month_avg,-x4,1,'FaceColor',[ 0.9 0.9 0.9],'EdgeColor',[ 0.9 0.9 0.9]);
    monthNPPleafObs      =  NPPleafObs.mean_avg30;
    monthNPPleafObs_std  =  NPPleafObs.mean_std30;
    y = [(monthNPPleafObs-monthNPPleafObs_std),(2.*monthNPPleafObs_std)];
    h = area(month_avg,y);       set(gca,'Layer','top');
    set(h(2),'FaceColor',[.7 .7 .7],'EdgeColor',[.7 .7 .7]);       set(h(1),'FaceColor','none','EdgeColor','none');
    set(h,'BaseValue',0);
    hl6 = plot(month_avg,NPPleafObs.mean_avg30,'Color',[0 0 0],'LineWidth',2);
    ik  = 3;   monthNPPleaf = NPPleaf(ik).mean_avg30;
    hl4 = plot(month_avg,monthNPPleaf,'Color',color_mtx(ik,:),'LineWidth',2);
    ik  = 1;   monthNPPleaf = NPPleaf(ik).mean_avg30;
    hl5 = plot(month_avg,monthNPPleaf,'Color',color_mtx(ik,:),'LineWidth',2);
    hl7 = plot(month_avg,month_avg.*0,':k','LineWidth',1);
    
    xlim([month_avg(1) month_avg(end)+8]);                   ylim([v1 v2]);
    set(gca,'XTick',month_avg,'XTickLabel',[ '' '' ''],'YTick',v3,'XTickLabel',[{datestr(month_avg,4)}],'FontSize',11);
    ax1  =  gca;      set(ax1,'XColor','k','YColor',[ 0.0 0.0 0.0],'Position',[0.17 0.7 0.28 0.20]);
    ylabel ({'NPP_{leaf monthly}';'(gC m^-^2 d^-^1)'},'FontSize',11);
    box on;
    legend([hl6,hl4,hl5],'Litter and LAI-derived biomass',...%,hl7
        [ModelNameShort{3} ' \Delta leaf biomass'],...
        [ModelNameShort{1} ' \Delta leaf biomass']);%,...
    legend boxoff;
    
    
    day_avg  =  (1:1:365)';           [Yday,Mday,Dday] = datevec(day_avg);
    v1 = -3;         v2 = 9;        v3 = v1:((v2-v1)/4):v2;
    figure('color','white');
    subplot(2,2,1);             hold on;
    x4  = zeros(12,1);             x4(4:9) = (v2);
    hl1 = bar(month_avg,x4,1,'FaceColor',[ 0.9 0.9 0.9],'EdgeColor',[ 0.9 0.9 0.9]);
    hl2 = bar(month_avg,-x4,1,'FaceColor',[ 0.9 0.9 0.9],'EdgeColor',[ 0.9 0.9 0.9]);
    dayNPPleafObs      =  NPPleafObs.mean_avg01;
    dayNPPleafObs_std  =  NPPleafObs.mean_std01;
    y = [(dayNPPleafObs-dayNPPleafObs_std),(2.*dayNPPleafObs_std)];
    h = area(day_avg,y);       set(gca,'Layer','top');
    set(h(2),'FaceColor',[.7 .7 .7],'EdgeColor',[.7 .7 .7]);       set(h(1),'FaceColor','none','EdgeColor','none');
    set(h,'BaseValue',0);
    hl6 = plot(day_avg,NPPleafObs.mean_avg01,'Color',[0 0 0],'LineWidth',2);
    ik  = 3;   dayNPPleaf = NPPleaf(ik).mean_avg01;
    hl4 = plot(day_avg,dayNPPleaf,'Color',color_mtx(ik,:),'LineWidth',2);
    ik  = 1;   dayNPPleaf = NPPleaf(ik).mean_avg01;
    hl5 = plot(day_avg,dayNPPleaf,'Color',color_mtx(ik,:),'LineWidth',2);
    hl7 = plot(day_avg,day_avg.*0,':k','LineWidth',1);
    
    xlim([day_avg(1) day_avg(end)+8]);                   ylim([v1 v2]);
    set(gca,'XTick',month_avg,'XTickLabel',[ '' '' ''],'YTick',v3,'XTickLabel',[{datestr(month_avg,4)}],'FontSize',11);
    ax1  =  gca;      set(ax1,'XColor','k','YColor',[ 0.0 0.0 0.0],'Position',[0.17 0.7 0.28 0.20]);
    ylabel ({'NPP_{leaf dayly}';'(gC m^-^2 d^-^1)'},'FontSize',11);
    box on;
    legend([hl6,hl4,hl5],'Litter and LAI-derived biomass',...
        [ModelNameShort{3} ' \Delta leaf biomass'],...
        [ModelNameShort{1} ' \Delta leaf biomass']);%,...
    legend boxoff;
    
end

save (['Ha1_leaf.mat'],'NPPleafObs','NPPleaf','ABGBleaf','ABGBlaiObs','ABGBleafObs');
