% .........................................................................
% Reads NACP model output wood allocation and observations
% Does require Ha1_01read_Leaf to be run ahead or call workspace
% Natalia Restrepo-Coupe
% nataliacoupe@gmail.com
% Saleska's lab - University of Arizona
% 2016 August 17 Toronto Canada
% .........................................................................
flag_unix = 0;        flag_figure = 1;      flag_read = 1;    flag_obs = 1;

%% Point where data is ....................................................
if flag_unix == 1
    FolderFluxnet  =  'C:\Users\ncoupe\Documents\Fluxnet\';
elseif flag_unix == 0
    addpath /home/ncoupe/Documents/OZ/
    addpath /home/ncoupe/Documents/Amazon/
    FolderFluxnet  =  '/media/ncoupe/Backup/Data/Fluxnet/';
    FolderNACP     =  '/media/ncoupe/Backup/Data/NACP/US-Ha1/';
    load '/media/ncoupe/Backup/Data/Fluxnet/siteFN.mat';
    slash          =  '/';
    load('Ha1_leaf.mat')
end

% Color palette and time vectors...........................................
color_mtx = [253/255 174/255 97/255; 101/255 161/255 104/255; 215/255  25/255 28/255; 253/255 174/255 97/255; 101/255 161/255 104/255; 43/255 131/255 186/255;...
    0.1020 0.5882 0.2549; 0.1020 0.5882 0.2549; 0.1020 0.5882 0.2549; 0.1020 0.5882 0.2549];

ModelNameShort = {'CLM4.5','CLASS','ORCHIDEE_{TRUNK}'};
ABGBwood = [];            NPPwood = [];

month_avg  =  (datenum(0,1,1):1:datenum(0,12,31))';
[Ymonth,Mmonth,Dmonth] = datevec(month_avg);        month_avg(Dmonth~= 1) = [];
week_avg  =  (datenum(0,1,1):16:datenum(0,12,31))';
[Yweek,Mweek,Dweek] = datevec(week_avg);
eigth_avg  =  (datenum(0,1,1):8:datenum(0,12,31))';
[Yeigth,Meigth,Deigth] = datevec(eigth_avg);
day_avg  =  (1:1:365)';
[Yday,Mday,Dday] = datevec(day_avg);

YearINI = 1991;           YearEND = 2019;

% .........................................................................
%% Read models
% .........................................................................
if flag_read == 1
    %......................................................................
    %% Read CLASS
    %......................................................................
    formatSpec  =  '%f%[^\n\r]';
    delimiter  =  ' ';
    
    % Open the text file
    fileID    =  fopen([FolderNACP 'CLASS/US-Ha1_9106_dailyTVmas_m_N.dat'],'r');
    dataArray =  textscan(fileID, formatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true,  'ReturnOnError', false);
    fclose(fileID);
    datelocABGBbiomass_class = (datenum(1990,1,1):1:datenum(2005,12,31))';
    [~,M,D]  =  datevec(datelocABGBbiomass_class);        datelocABGBbiomass_class((M == 2)&(D == 29)) = [];
    % subsample after 1991 and then get monthly values
    ind = find((datelocABGBbiomass_class>=datenum(YearINI,1,1))&(datelocABGBbiomass_class<=datenum(YearEND+1,1,1)));
    ix = dataArray{:, 1}.*1000;
    ABGBbiomass(2).mean01 = ix(ind);    	% kgC/m2 to gC/m2
    ABGBbiomass(2).date01 = datelocABGBbiomass_class(ind);
    
    [ABGBbiomass(2).mean30,~,~,ABGBbiomass(2).date30] = AM_month(ABGBbiomass(2).mean01,ABGBbiomass(2).date01);
    [Y,M,D] = datevec(ABGBbiomass(2).date30);
    ABGBbiomass(2).mean_avg30 = AM_month_avg(ABGBbiomass(2).mean30,ABGBbiomass(2).date30);
    
    [ABGBbiomass(2).mean16,~,~,~,~,~,ABGBbiomass(2).date16] = AM_week2day_rs(ABGBbiomass(2).mean01,ABGBbiomass(2).date01);
    ABGBbiomass(2).mean_avg16 = AM_week2_avg(ABGBbiomass(2).mean16,ABGBbiomass(2).date16);
    
    [ABGBbiomass(2).mean_avg01,ABGBbiomass(2).std_avg01] = AM_day_avg(ABGBbiomass(2).mean01,ABGBbiomass(2).date01);
    
    fileID  =  fopen([FolderNACP 'CLASS/US-Ha1_9106_monthlyTVmas_m_N.dat'],'r');
    dataArray  =  textscan(fileID, formatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true,  'ReturnOnError', false);
    fclose(fileID);
    datelocABGBtest_class = (datenum(1992,1,1):1:datenum(2004,12,31))';
    [~,~,D]  = datevec(datelocABGBtest_class);  datelocABGBtest_class(D~=1) = [];
    [Y,M,D]  = datevec(datelocABGBtest_class);
    ABGBtest = dataArray{:, 1}.*1000;       	% kgC/m2 to gC/m2
    
    figure('color','white');            plot(ABGBbiomass(2).date01,ABGBbiomass(2).mean01);
    datetick('x');          hold on;  	ylabel('ABGB_{daily CLASS}(gC m^2 d^1)');
    plot(ABGBbiomass(2).date30,ABGBbiomass(2).mean30);
    plot(datelocABGBtest_class,ABGBtest./eomday(Y,M),'k');
    %......................................................................
    %% Import data from ORCHIDEE
    %......................................................................
    delimiter  =  ' ';
    formatSpec  =  '%f%f%f%f%f%f%f%f%f%f%f%f%f%[^\n\r]';
    fileID  =  fopen([FolderNACP 'ORCHIDEE/TRUNK.txt'],'r');
    dataArray  =  textscan(fileID, formatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'EmptyValue' ,NaN, 'ReturnOnError', false);
    fclose(fileID);
    
    % "Allocate" imported array to column variable names
    % fluxes (GPP, NPP, RESP) is gC/m2/day, and for C pools is gC /m2
    GPP  =  dataArray{:, 1};          NPP  =  dataArray{:, 2};
    GROWTH_RESP = dataArray{:, 3};    MAINT_RESP = dataArray{:, 4};
    HET_RESP   = dataArray{:, 5};     LEAF_M     = dataArray{:, 6};
    SAP_M_AB   = dataArray{:, 7};     SAP_M_BE   = dataArray{:, 8};
    HEART_M_AB = dataArray{:, 9};     HEART_M_BE = dataArray{:, 10};
    ROOT_M     = dataArray{:, 11};    FRUIT_M    = dataArray{:, 12};
    RESERVE_M  = dataArray{:, 13};
    
    % Clear temporary variables
    clearvars filename delimiter formatSpec fileID dataArray ans;
    
    datelocABGBwood_orchidee = (datenum(1900,1,1):1:datenum(1999,12,31))';
    [Y,M,D] = datevec(datelocABGBwood_orchidee);      datelocABGBwood_orchidee((M == 2)&(D == 29)) = [];
    % Subsample after 1991 and then get monthly values
    ind = find((datelocABGBwood_orchidee>=datenum(YearINI,1,1))&(datelocABGBwood_orchidee<=datenum(YearEND+1,1,1)));
    ix  =  HEART_M_AB+SAP_M_AB;
    ABGBwood(3).mean01 = ix(ind);
    ABGBwood(3).date01 = datelocABGBwood_orchidee(ind);
    
    ix  =  HEART_M_AB+SAP_M_AB+LEAF_M+FRUIT_M+RESERVE_M;
    ABGBbiomass(3).mean01 = ix(ind);
    ABGBbiomass(3).date01 = datelocABGBwood_orchidee(ind);
    
    [ix,~,~,iy]            = AM_month(ABGBwood(3).mean01,ABGBwood(3).date01);
    ABGBwood(3).date30     = iy;
    ABGBwood(3).mean30     = ix;
    ABGBwood(3).mean_avg30 = AM_month_avg(ABGBwood(3).mean30,ABGBwood(3).date30);
    [ix,~,~,iy]            = AM_month(ABGBbiomass(3).mean01,ABGBbiomass(3).date01);
    ABGBbiomass(3).date30     = iy;
    ABGBbiomass(3).mean30     = ix;
    ABGBbiomass(3).mean_avg30 = AM_month_avg(ABGBbiomass(3).mean30,ABGBbiomass(3).date30);
    
    [ix,~,~,~,~,~,iy]  = AM_week2day_rs(ABGBwood(3).mean01,ABGBwood(3).date01);
    ABGBwood(3).date16     = iy;
    ABGBwood(3).mean16     = ix;
    ABGBwood(3).mean_avg16 = AM_week2_avg(ABGBwood(3).mean16,ABGBwood(3).date16);
    [ix,~,~,~,~,~,iy]  = AM_week2day_rs(ABGBbiomass(3).mean01,ABGBbiomass(3).date01);
    ABGBbiomass(3).date16     = iy;
    ABGBbiomass(3).mean16     = ix;
    ABGBbiomass(3).mean_avg16 = AM_week2_avg(ABGBbiomass(3).mean16,ABGBbiomass(3).date16);
    
    [ix,~,~,~,~,~,iy]  = AM_week2day_rs(ABGBwood(3).mean01,ABGBwood(3).date01);
    ABGBwood(3).date08     = iy;
    ABGBwood(3).mean08     = ix;
    ABGBwood(3).mean_avg108 = AM_week2_avg(ABGBwood(3).mean08,ABGBwood(3).date08);
    [ix,~,~,~,~,~,iy]  = AM_week2day_rs(ABGBbiomass(3).mean01,ABGBbiomass(3).date01);
    ABGBbiomass(3).date08      = iy;
    ABGBbiomass(3).mean08      = ix;
    ABGBbiomass(3).mean_avg108 = AM_week2_avg(ABGBbiomass(3).mean08,ABGBbiomass(3).date08);
    
    figure('color','white');                plot(ABGBwood(3).date01,ABGBwood(3).mean01);
    datetick('x');  hold on; ylabel('ABGB_{daily ORCHIDEE}(gC m^2 d^1)');
    plot(ABGBwood(3).date30,ABGBwood(3).mean30);
    
    %......................................................................
    %% Import data from CLM3.5
    %......................................................................
    FileName  =  [ FolderNACP 'CLM3.5' slash 'US-Ha1_I20TRCLM45CBCN.clm2.h0.1991-2013.daily.nc'];
    %     finfo = ncinfo(FileName);       finfo.Variables.Name
    cWood  =  ncread(FileName,'cWood');             % 'KgC m-2'
    cAbove =  ncread(FileName,'cAbove');            % 'KgC m-2'
    dateloc_clm  =  ncread(FileName,'time');        % monthly data no leap
    dateloc_clm  =  double(dateloc_clm);            dateloc_clm  =  dateloc_clm + datenum(1850,1,1);
    [Y,M,D]  =  datevec(dateloc_clm);
    
    % Subsample after 1991 and then get monthly values
    ind = find((dateloc_clm>=datenum(YearINI,1,1))&(dateloc_clm<=datenum(YearEND+1,1,1)));
    ABGBwood(1).mean01 = cWood(ind).*1000;
    ABGBwood(1).date01 = dateloc_clm(ind);
    ABGBbiomass(1).mean01 = cAbove(ind).*1000;
    ABGBbiomass(1).date01 = dateloc_clm(ind);
    
    [ix,~,~,iy]  =  AM_month(ABGBwood(1).mean01,ABGBwood(1).date01);
    ABGBwood(1).date30  =  iy;
    ABGBwood(1).mean30  =  ix;
    ABGBwood(1).mean_avg30  =  AM_month_avg(ABGBwood(1).mean30,ABGBwood(1).date30);
    [ix,~,~,iy]  =  AM_month(ABGBbiomass(1).mean01,ABGBbiomass(1).date01);
    ABGBbiomass(1).date30  =  iy;
    ABGBbiomass(1).mean30  =  ix;
    ABGBbiomass(1).mean_avg30  =  AM_month_avg(ABGBbiomass(1).mean30,ABGBbiomass(1).date30);
    
    [ix,~,~,~,~,~,iy]  = AM_week2day_rs(ABGBwood(1).mean01,ABGBwood(1).date01);
    ABGBwood(1).date16     = iy;
    ABGBwood(1).mean16     = ix;
    ABGBwood(1).mean_avg16 = AM_week2_avg(ABGBwood(1).mean16,ABGBwood(1).date16);
    [ix,~,~,~,~,~,iy]  = AM_week2day_rs(ABGBbiomass(1).mean01,ABGBbiomass(1).date01);
    ABGBbiomass(1).date16     = iy;
    ABGBbiomass(1).mean16     = ix;
    ABGBbiomass(1).mean_avg16 = AM_week2_avg(ABGBbiomass(1).mean16,ABGBbiomass(1).date16);
    
    %    ind  =  1:length(ABGBwood(1).date01);
    figure('color','white');                plot(ABGBwood(1).date01,ABGBwood(1).mean01);
    datetick('x');  hold on; ylabel('ABGB_{daily CLM3.5}(gC m^2 d^1)');
    plot(ABGBwood(1).date30,ABGBwood(1).mean30);
    %......................................................................
    % Calculating the rate
    %......................................................................
    figure('color','white');
    for ik = 1:3
        if ik~=2
            iy = diff(ABGBwood(ik).mean01);        iy  = [iy(1);iy];
            iy = AM_rm_outlier(iy,3);
            iy = smooth(iy,7);
            [NPPwood(ik).mean30,~,~,NPPwood(ik).date30]= AM_month(iy,ABGBwood(ik).date01);
            [NPPwood(ik).mean_avg30,NPPwood(ik).std_avg30] = AM_month_avg(NPPwood(ik).mean30,NPPwood(ik).date30);
            
            %..................................................................
            [NPPwood(ik).mean16,~,~,~,~,~,NPPwood(ik).date16]    = AM_week2day_rs(iy,ABGBwood(ik).date01);
            [NPPwood(ik).mean_avg16,NPPwood(ik).std_avg16] = AM_week2_avg(NPPwood(ik).mean16,NPPwood(ik).date16);
            
            %..................................................................
            NPPwood(ik).mean01 = iy./1;
            
            iy = AM_rm_outlier(NPPwood(ik).mean01,3);        NPPwood(ik).date01 = ABGBwood(ik).date01;
            [NPPwood(ik).mean_avg01] = AM_day_avg(iy,NPPwood(ik).date01);
            NPPwood(ik).date_avg01   = (1:365)';
            
            subplot(2,2,ik);    plot(day_avg,NPPwood(ik).mean_avg01);  hold on;
            iy = smooth(NPPwood(ik).mean_avg01);
            plot(day_avg,iy); title(ModelNameShort(ik)); plot(month_avg,NPPwood(ik).mean_avg30);
            ylabel('NPPwood');  legend('daily','daily_{5 day window}','month');
            display ([ModelNameShort(ik) find(iy==nanmax(iy))])
            iy = smooth(NPPwood(ik).mean_avg01);
            display ([ModelNameShort(ik) find(iy==nanmax(iy))])
        end
        %% ....................................................................
        iy = diff(ABGBbiomass(ik).mean01);        iy  = [iy(1);iy];
        iy = AM_rm_outlier(iy,3);
        iy = smooth(iy,7);
        [NPPbiomass(ik).mean30,~,~,NPPbiomass(ik).date30]= AM_month(iy,ABGBbiomass(ik).date01);
        [NPPbiomass(ik).mean_avg30,NPPbiomass(ik).std_avg30] = AM_month_avg(NPPbiomass(ik).mean30,NPPbiomass(ik).date30);
        
        %..................................................................
        [NPPbiomass(ik).mean16,~,~,~,~,~,NPPbiomass(ik).date16]    = AM_week2day_rs(iy,ABGBbiomass(ik).date01);
        [NPPbiomass(ik).mean_avg16,NPPbiomass(ik).std_avg16] = AM_week2_avg(NPPbiomass(ik).mean16,NPPbiomass(ik).date16);
        
        %..................................................................
        NPPbiomass(ik).mean01 = iy./1;
        
        iy = AM_rm_outlier(NPPbiomass(ik).mean01,3);        NPPbiomass(ik).date01 = ABGBbiomass(ik).date01;
        [NPPbiomass(ik).mean_avg01] = AM_day_avg(iy,NPPbiomass(ik).date01);
        NPPbiomass(ik).date_avg01   = (1:365)';
        
        subplot(2,2,ik);    plot(day_avg,NPPbiomass(ik).mean_avg01);  hold on;
        iy = smooth(NPPbiomass(ik).mean_avg01);
        plot(day_avg,iy); title(ModelNameShort(ik)); plot(month_avg,NPPbiomass(ik).mean_avg30);
        ylabel('NPPbiomass');  legend('daily','daily_{5 day window}','month');
        display ([ModelNameShort(ik) find(iy==nanmax(iy))])
        iy = smooth(NPPbiomass(ik).mean_avg01);
        display ([ModelNameShort(ik) find(iy==nanmax(iy))])
    end
end

if flag_obs == 1
    filename   =  [FolderFluxnet 'US-Ha1/DBH/AGB.Ha1.2016.txt'];
    delimiter  =  ',';
    startRow   =  2;
    formatSpec =  '%f%f%[^\n\r]';
    fileID     =  fopen(filename,'r');
    dataArray  =  textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    fclose(fileID);
    days1     =  dataArray{:, 1};
    totalts   =  dataArray{:, 2}.*10^2; %Mg/ha to gC/m2... 10^6g/10^4 = 10^2
    difftotalts  =  diff(totalts);    difftotalts  =  [NaN;difftotalts];
    difftotalts  =  AM_rm_outlier(difftotalts,3);
    clearvars filename delimiter startRow formatSpec fileID dataArray ans;
    
    figure('color','white');        subplot(2,1,1); plot(days1,totalts);
    datetick('x');  hold on; ylabel('ABGB_{obs}(gC m^2 d^1)');
    subplot(2,1,2); plot(days1,difftotalts);
    datetick('x');  hold on; ylabel('NPP_{biomass obs}(gC m^2 d^1)');
    
    ABGBobs.date01  =  days1 + datenum(2016,1,1);         NPPobs.date01  =  ABGBobs.date01;
    ABGBobs.mean01  =  totalts;
    NPPobs.mean01   =  difftotalts;
    
    [NPPobs.mean30,~,~,NPPobs.date30,~,~,NPPobs.std30]    = AM_month(NPPobs.mean01,NPPobs.date01);
    [ABGBobs.mean30,~,~,ABGBobs.date30,~,~,ABGBobs.std30] = AM_month(ABGBobs.mean01,ABGBobs.date01);
    [NPPobs.mean16,~,~,~,~,NPPobs.std16,NPPobs.date16]    = AM_week2day_rs(NPPobs.mean01,NPPobs.date01);
    [ABGBobs.mean16,~,~,~,~,ABGBobs.std16,ABGBobs.date16] = AM_week2day_rs(ABGBobs.mean01,ABGBobs.date01);
    
    [NPPobs.mean_avg01,NPPobs.mean_std01]  = AM_day_avg(NPPobs.mean01,ABGBobs.date01);
    [ABGBobs.mean_avg01,ABGBobs.mean_std01]  = AM_day_avg(ABGBobs.mean01,ABGBobs.date01);
    
    NPPobs.mean_avg30  = AM_month_avg(NPPobs.mean30,NPPobs.date30);
    NPPobs.mean_std30  = AM_month_avg(NPPobs.std30,NPPobs.date30);
    ABGBobs.mean_avg30 = AM_month_avg(ABGBobs.mean30,ABGBobs.date30);
    ABGBobs.mean_std30 = AM_month_avg(ABGBobs.std30,ABGBobs.date30);
    
    NPPobs.mean_avg16  = AM_week2_avg(NPPobs.mean16,NPPobs.date16);
    NPPobs.mean_std16  = AM_week2_avg(NPPobs.std16,NPPobs.date16);
    ABGBobs.mean_avg16 = AM_week2_avg(ABGBobs.mean16,ABGBobs.date16);
    ABGBobs.mean_std16 = AM_week2_avg(ABGBobs.std16,ABGBobs.date16);
    
    iy = diff(ABGBobs.mean30);        iy = [iy;iy(1)];
    dateloc = ABGBobs.date30;
    [Ymonth, Mmonth,] = datevec(dateloc);
    month_days = (eomday(Ymonth, Mmonth));
    ABGBtest  =  iy./month_days;
    
    iy = AM_rm_outlier(NPPobs.mean01,3);        dateloc = NPPobs.date01;
    [NPPobs.mean_avg01,~,~,~,~,NPPobs.mean_avgN01] = AM_day_avg(iy,dateloc);
    iy = smooth(NPPobs.mean_avg01);
    display ([find(iy==nanmax(iy))])
    
    %% % % ..........lets us try the wood ........................................
    close all;
    figure('color','white');
    subplot(2,1,1);     plot(ABGBlaiObs.date01,ABGBleafObs.mean01,'LineWidth',2);   hold on;
    plot(ABGBobs.date01,ABGBobs.mean01,'LineWidth',2);
    datetick('x');  ylabel('Biomass (gC m^-^2)'); legend('leaf','aboveground');      legend boxoff;
    
    subplot(2,1,2);     plot(ABGBlaiObs.date01,NPPleafObs.mean01,'LineWidth',2);    hold on;
    plot(NPPobs.date01,NPPobs.mean01,'LineWidth',2);
    datetick('x');      ylabel('NPP (gC m^-^2)'); legend('leaf','aboveground');      legend boxoff;
    %%
    % ind = find(ABGBlaiObs.date01>datenum(2013,1,1));
    % [x,~,~,~,~,z,y] = AM_week2day_rs(NPPleafObs.mean01(ind),ABGBlaiObs.date01(ind));
    % x_mean_avg16  = AM_week2_avg(x,y);
    
    figure('color','white');
    subplot(2,1,1);      plot(day_avg,ABGBobs.mean_avg01 - ABGBleafObs.mean_avg01,'LineWidth',2);    hold on;
    plot(day_avg,ABGBobs.mean_avg01,'LineWidth',2);
    % plot(week_avg,x_mean_avg16,'LineWidth',2);    hold on;
    datetick('x');      ylabel('Biomass_{daily}(gC m^-^2)'); legend('aboveground-leaf','aboveground');      legend boxoff;
    
    subplot(2,1,2);     plot(week_avg,NPPleafObs.mean_avg16,'LineWidth',2);    hold on;
    plot(week_avg,NPPobs.mean_avg16,'LineWidth',2);
    % plot(week_avg,x_mean_avg16,'LineWidth',2);    hold on;
    datetick('x');      ylabel('NPP_{16-days}(gC m^-^2)'); legend('leaf','aboveground');      legend boxoff;
    
    %%
    figure('color','white');
    subplot(2,1,1);     plot(week_avg,NPPleafObs.mean_avg16,'LineWidth',2);    hold on;
    plot(week_avg,NPPobs.mean_avg16,'LineWidth',2);
    datetick('x');      ylabel('NPP(gC m^-^2)');
    legend('leaf','aboveground','wood');      legend boxoff;
    
end

% ........................................................................
%% Figures
% ........................................................................
if flag_figure == 1
    v1 = -2;         v2 = 6;        v3 = v1:((v2-v1)/2):v2;
    figure('color','white');
    subplot(2,2,1);             hold on;
    x4 = zeros(12,1);             x4(4:9) = (v2);
    hl1  =  bar(month_avg,x4,1,'FaceColor',[ 0.9 0.9 0.9],'EdgeColor',[ 0.9 0.9 0.9]);
    hl2  =  bar(month_avg,-x4,1,'FaceColor',[ 0.9 0.9 0.9],'EdgeColor',[ 0.9 0.9 0.9]);
    monthNPPbiomass      =  NPPobs.mean_avg30;
    monthNPPbiomass_std  =  NPPobs.mean_std30;
    y  =  [(monthNPPbiomass-monthNPPbiomass_std),(2.*monthNPPbiomass_std)];
    h   =   area(month_avg,y);       set(gca,'Layer','top');
    set(h(2),'FaceColor',[.7 .7 .7],'EdgeColor',[.7 .7 .7]);       set(h(1),'FaceColor','none','EdgeColor','none');
    set(h,'BaseValue',0);
    hl6  =  plot(month_avg,NPPobs.mean_avg30,'Color',[0 0 0],'LineWidth',2);
    ik = 2; monthNPPbiomass = NPPbiomass(ik).mean_avg30;
    hl3  =  plot(month_avg,monthNPPbiomass,'Color',color_mtx(ik,:),'LineWidth',2);
    ik = 3; monthNPPbiomass = NPPbiomass(ik).mean_avg30;
    hl4  =  plot(month_avg,monthNPPbiomass,'Color',color_mtx(ik,:),'LineWidth',2);
    ik = 1; monthNPPbiomass = NPPbiomass(ik).mean_avg30;
    hl5  =  plot(month_avg,monthNPPbiomass,'Color',color_mtx(ik,:),'LineWidth',2);
    hl7  =  plot(month_avg,month_avg.*0,':k','LineWidth',1);
    
    %     for ik=3      %model
    %         weekNPPbiomass=month_avgNPPbiomass(ip).model(ik).avg;   %Kgm2m1_gm2d1.*month_avgNPPbiomass(ip).model(ik).avg;
    %         hl7 = plot(month_avg,weekNPPbiomass,'--','Color',color_mtx(ik,:),'LineWidth',2);
    %     end
    
    xlim([month_avg(1) month_avg(end)+8]);                   ylim([v1 v2]);
    set(gca,'XTick',month_avg,'XTickLabel',[ '' '' ''],'YTick',v3,'XTickLabel',[{datestr(month_avg,4)}],'FontSize',11);
    ax1  =  gca;      set(ax1,'XColor','k','YColor',[ 0.0 0.0 0.0],'Position',[0.17 0.7 0.28 0.20]);
    ylabel ({'NPP_{biomass}';'(gC m^-^2 d^-^1)'});%,'FontSize',11);
    legend([hl6,hl3,hl4,hl5],' DBH-derived biomass',...%,hl7
        [ModelNameShort{2} ' total vegetation biomass'],...
        [ModelNameShort{3} 'ABG heart+sapwood+leaves+fruits'],...
        [ModelNameShort{1} 'ABG biomass']);
    box on;
    legend boxoff;
    
    % ....................................................................
    v1 = -1;         v2 = 1.1;        v3 = v1:((1-v1)/2):1;
    subplot(2,2,3);             hold on;
    x4 = zeros(12,1);             x4(4:9) = (v2);
    hl1  =  bar(month_avg,x4,1,'FaceColor',[ 0.9 0.9 0.9],'EdgeColor',[ 0.9 0.9 0.9]);
    hl2  =  bar(month_avg,-x4,1,'FaceColor',[ 0.9 0.9 0.9],'EdgeColor',[ 0.9 0.9 0.9]);
    monthNPPbiomass      =  NPPobs.mean_avg30;
    monthNPPbiomass_std  =  NPPobs.mean_std30;
    y  =  [(monthNPPbiomass-monthNPPbiomass_std)./nanmax(monthNPPbiomass),(2.*monthNPPbiomass_std)./nanmax(monthNPPbiomass)];
    h   =   area(month_avg,y);       set(gca,'Layer','top');
    set(h(2),'FaceColor',[.7 .7 .7],'EdgeColor',[.7 .7 .7]);       set(h(1),'FaceColor','none','EdgeColor','none');
    set(h,'BaseValue',0);
    hl6  =  plot(month_avg,monthNPPbiomass./nanmax(monthNPPbiomass),'Color',[0 0 0],'LineWidth',2);
    ik = 2; monthNPPbiomass = NPPbiomass(ik).mean_avg30;
    hl3  =  plot(month_avg,monthNPPbiomass./nanmax(monthNPPbiomass),'Color',color_mtx(ik,:),'LineWidth',2);
    ik = 3; monthNPPbiomass = NPPbiomass(ik).mean_avg30;
    hl4  =  plot(month_avg,monthNPPbiomass./nanmax(monthNPPbiomass),'Color',color_mtx(ik,:),'LineWidth',2);
    ik = 1; monthNPPbiomass = NPPbiomass(ik).mean_avg30;
    hl5  =  plot(month_avg,monthNPPbiomass./nanmax(monthNPPbiomass),'Color',color_mtx(ik,:),'LineWidth',2);
    hl7  =  plot(month_avg,month_avg.*0,':k','LineWidth',1);
    
    xlim([month_avg(1) month_avg(end)+8]);                   ylim([v1 v2]);
    set(gca,'XTick',month_avg,'XTickLabel',[ '' '' ''],'YTick',v3,'XTickLabel',[{datestr(month_avg,4)}],'FontSize',11);
    ax1  =  gca;      set(ax1,'XColor','k','YColor',[ 0.0 0.0 0.0],'Position',[0.17 0.2 0.28 0.20]);
    ylabel ({'NPP_{biomass}/NPP_{biomass max}'},'FontSize',11);
    legend([hl6,hl3,hl4,hl5],'Obs',ModelNameShort{2},ModelNameShort{3},ModelNameShort{1});
    box on;
    
    % ....................................................................
    %% Biomass
    % ....................................................................
    v1 = -3;         v2 = 7;        v3 = [v1;0;3;6];
    figure('color','white');
    subplot(2,2,1);             hold on;
    x4 = zeros(23,1);           x4(7:17) = (v2); %april to sep
    hl1  =  bar(week_avg,x4,1,'FaceColor',[ 0.9 0.9 0.9],'EdgeColor',[ 0.9 0.9 0.9]);
    hl2  =  bar(week_avg,-x4,1,'FaceColor',[ 0.9 0.9 0.9],'EdgeColor',[ 0.9 0.9 0.9]);
    weekNPPbiomass     = NPPobs.mean_avg16;
    weekNPPbiomass_std = NPPobs.mean_std16;
    y  = [(weekNPPbiomass-weekNPPbiomass_std),(2.*weekNPPbiomass_std)];
    h  = area(week_avg,y);       set(gca,'Layer','top');
    set(h(2),'FaceColor',[.7 .7 .7],'EdgeColor',[.7 .7 .7]);       set(h(1),'FaceColor','none','EdgeColor','none');
    set(h,'BaseValue',0);
    hl6  =  plot(week_avg,NPPobs.mean_avg16,'Color',[0 0 0],'LineWidth',2);
    ik = 2; weekNPPbiomass = NPPbiomass(ik).mean_avg16;
    hl3  =  plot(week_avg,weekNPPbiomass,'Color',color_mtx(ik,:),'LineWidth',2);
    ik = 3; weekNPPbiomass = NPPbiomass(ik).mean_avg16;
    hl4  =  plot(week_avg,weekNPPbiomass,'Color',color_mtx(ik,:),'LineWidth',2);
    ik = 1; weekNPPbiomass = NPPbiomass(ik).mean_avg16;
    hl5  =  plot(week_avg,weekNPPbiomass,'Color',color_mtx(ik,:),'LineWidth',2);
    hl7  =  plot(week_avg,week_avg.*0,':k','LineWidth',2);
    
    xlim([month_avg(1) month_avg(end)+8]);                   ylim([v1 v2]);
    set(gca,'XTick',month_avg,'XTickLabel',[ '' '' ''],'YTick',v3,'XTickLabel',...
        datestr(month_avg,4),'FontSize',11,'Position',[0.17 0.7 0.28 0.20]);
    ax1  =  gca;      set(ax1,'XColor','k','YColor',[ 0.0 0.0 0.0],'Position',[0.17 0.7 0.28 0.20]);
    ylabel ({'NPP_{biomass}';'(gC m^-^2 d^-^1)'},'FontSize',11);
    legend([hl6,hl3,hl4,hl5],'\Delta DBH-derived biomass',...%,hl7
        [ModelNameShort{2} ' \Delta total vegetation biomass'],...
        [ModelNameShort{3} '\Delta leaf+fruit+ABG heart+sapwood'],...
        [ModelNameShort{1} ' \Delta ABG biomass']);%,...
    %         'ORCHIDEE_{noDVGM}');
    box on;
    legend boxoff;
    set(ax1,'XColor','k','YColor',[ 0.0 0.0 0.0],'Position',[0.17 0.7 0.28 0.20]);
    
    % ....................................................................
    %% We understand the observed NPPabove ground biomass represent changes in
    % wood rather than wood+leaf, thus as allometric equations do not take into
    % acount seasonal changes in biomass
    % ....................................................................
    v1 = -3;         v2 = 7;        v3 = [v1;0;3;6];
    figure('color','white');
    subplot(2,2,1);             hold on;
    x4 = zeros(23,1);           x4(7:17) = (v2); %april to sep
    hl1  =  bar(week_avg,x4,1,'FaceColor',[ 0.9 0.9 0.9],'EdgeColor',[ 0.9 0.9 0.9]);
    hl2  =  bar(week_avg,-x4,1,'FaceColor',[ 0.9 0.9 0.9],'EdgeColor',[ 0.9 0.9 0.9]);
    weekNPPwood     = NPPobs.mean_avg16;
    weekNPPwood_std = NPPobs.mean_std16;
    y  = [(weekNPPwood-weekNPPwood_std),(2.*weekNPPwood_std)];
    h  = area(week_avg,y);       set(gca,'Layer','top');
    set(h(2),'FaceColor',[.7 .7 .7],'EdgeColor',[.7 .7 .7]);       set(h(1),'FaceColor','none','EdgeColor','none');
    set(h,'BaseValue',0);
    hl6  =  plot(week_avg,NPPobs.mean_avg16,'Color',[0 0 0],'LineWidth',2);
    %     ik = 2;   weekNPPwood = NPPwood(ik).mean_avg16;
    %     hl3  =  plot(week_avg,weekNPPwood,'Color',color_mtx(ik,:),'LineWidth',2);
    ik = 3; weekNPPwood = NPPwood(ik).mean_avg16;
    hl4  =  plot(week_avg,weekNPPwood,'Color',color_mtx(ik,:),'LineWidth',2);
    ik = 1; weekNPPwood = NPPwood(ik).mean_avg16;
    hl5  =  plot(week_avg,weekNPPwood,'Color',color_mtx(ik,:),'LineWidth',2);
    hl7  =  plot(week_avg,week_avg.*0,':k','LineWidth',2);
    
    xlim([month_avg(1) month_avg(end)+8]);                   ylim([v1 v2]);
    set(gca,'XTick',month_avg,'XTickLabel',[ '' '' ''],'YTick',v3,'XTickLabel',...
        datestr(month_avg,4),'FontSize',11,'Position',[0.17 0.7 0.28 0.20]);
    ax1  =  gca;      set(ax1,'XColor','k','YColor',[ 0.0 0.0 0.0],'Position',[0.17 0.7 0.28 0.20]);
    ylabel ({'NPP_{wood}';'(gC m^-^2 d^-^1)'},'FontSize',11);
    legend([hl6,hl3,hl4,hl5],'\Delta DBH-derived biomass',...%,hl7
        [ModelNameShort{2} ' \Delta total vegetation biomass'],...
        [ModelNameShort{3} ' \Delta aboveground heart+sapwood'],...
        [ModelNameShort{1} ' \Delta wood biomass']);
    box on;
    legend boxoff;
    set(ax1,'XColor','k','YColor',[ 0.0 0.0 0.0],'Position',[0.17 0.7 0.28 0.20]);
    
    % ....................................................................
    %% Monthly figures
    % ....................................................................
    v1 = -2;         v2 = 6;        v3 = v1:((v2-v1)/2):v2;
    figure('color','white');
    subplot(2,2,1);             hold on;
    x4 = zeros(12,1);           x4(4:9) = (v2);
    hl1 = bar(month_avg,x4,1,'FaceColor',[ 0.9 0.9 0.9],'EdgeColor',[ 0.9 0.9 0.9]);
    hl2 = bar(month_avg,-x4,1,'FaceColor',[ 0.9 0.9 0.9],'EdgeColor',[ 0.9 0.9 0.9]);
    dayNPPwood     = NPPobs.mean_avg01;
    dayNPPwood_std = NPPobs.mean_std01;
    y = [(dayNPPwood-dayNPPwood_std),(2.*dayNPPwood_std)];
    h = area(day_avg,y);       set(gca,'Layer','top');
    set(h(2),'FaceColor',[.7 .7 .7],'EdgeColor',[.7 .7 .7]);       set(h(1),'FaceColor','none','EdgeColor','none');
    set(h,'BaseValue',0);
    hl6  =  plot(NPPobs.mean_avg01,'Color',[0 0 0],'LineWidth',2);
    ik = 2; dayNPPwood = NPPwood(ik).mean_avg01;
    hl3  =  plot(dayNPPwood,'Color',color_mtx(ik,:),'LineWidth',2);
    ik = 3; dayNPPwood = NPPwood(ik).mean_avg01;
    hl4  =  plot(dayNPPwood,'Color',color_mtx(ik,:),'LineWidth',2);
    ik = 1; dayNPPwood = NPPwood(ik).mean_avg01;
    hl5  =  plot(dayNPPwood,'Color',color_mtx(ik,:),'LineWidth',2);
    
    xlim([week_avg(1) week_avg(end)+8]);                   ylim([v1 v2]);
    set(gca,'XTick',month_avg,'XTickLabel',[ '' '' ''],'YTick',v3,'XTickLabel',[{datestr(month_avg,4)}],'FontSize',11);
    ax1  =  gca;      set(ax1,'XColor','k','YColor',[ 0.0 0.0 0.0],'Position',[0.17 0.7 0.28 0.20]);
    ylabel ({'NPP_{wood}';'(gC m^-^2 d^-^1)'},'FontSize',11);
    legend([hl6,hl3,hl4,hl5],'DBH-derived biomass',...%,hl7
        [ModelNameShort{2} ' total vegetation biomass'],...
        [ModelNameShort{3} ' aboveground heart+sapwood'],...
        [ModelNameShort{1} ' wood biomass']);
    box on;
    legend boxoff;
    
    % ....................................................................
    v1 = 1000;         v2 = 20000;        v3 = v1:((v2-v1)/2):v2;
    figure('color','white');
    subplot(2,2,1);             hold on;
    x4 = zeros(12,1);             x4(4:9) = (v2);
    hl1  =  bar(month_avg,x4,1,'FaceColor',[ 0.9 0.9 0.9],'EdgeColor',[ 0.9 0.9 0.9]);
    hl2  =  bar(month_avg,-x4,1,'FaceColor',[ 0.9 0.9 0.9],'EdgeColor',[ 0.9 0.9 0.9]);
    monthNPPwood     = ABGBobs.mean_avg30;
    monthNPPwood_std = ABGBobs.mean_std30;
    y  = [(monthNPPwood-monthNPPwood_std),(2.*monthNPPwood_std)];
    h  = area(month_avg,y);       set(gca,'Layer','top');
    set(h(2),'FaceColor',[.7 .7 .7],'EdgeColor',[.7 .7 .7]);       set(h(1),'FaceColor','none','EdgeColor','none');
    set(h,'BaseValue',0);
    hl6 =  plot(month_avg,ABGBobs.mean_avg30,'Color',[0 0 0],'LineWidth',2);
    %     ik  = 2;   weekABGB = ABGBwood(ik).mean_avg30;
    %     hl3 =  plot(month_avg,weekABGB,'Color',color_mtx(ik,:),'LineWidth',2);
    ik  = 3;   monthABGB = ABGBwood(ik).mean_avg30;
    hl4 = plot(month_avg,monthABGB,'Color',color_mtx(ik,:),'LineWidth',2);
    ik  = 1;   monthABGB = ABGBwood(ik).mean_avg30;
    hl5 = plot(month_avg,monthABGB,'Color',color_mtx(ik,:),'LineWidth',2);
    xlim([month_avg(1) month_avg(end)+30]);                   ylim([v1 v2]);
    set(gca,'XTick',month_avg,'XTickLabel',[ '' '' ''],'YTick',v3,'XTickLabel',[{datestr(month_avg,4)}],'FontSize',11);
    ax1  =  gca;      set(ax1,'XColor','k','YColor',[ 0.0 0.0 0.0],'Position',[0.17 0.7 0.28 0.20]);
    ylabel ({'ABGB_{wood}';'(gC m^-^2)'},'FontSize',11);
    legend([hl3,hl4,hl5],ModelNameShort{2},ModelNameShort{3},ModelNameShort{1});
    box on;
    legend boxoff;
end
