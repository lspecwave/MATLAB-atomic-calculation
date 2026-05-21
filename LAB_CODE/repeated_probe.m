close all
clear all
colors=npg(10); % Ten basic colors

%% Input Area

maindir=['\\ARTEMIS-PC\Data\2026-05-20' ...
    '\'];%数据来源路径

repeat = 3;   % 探测组数,照片数的一半
photo = 2*repeat;
species = 173;

plotnumber = 1;   % 是否画原子数
plotradius = 0;   % 是否画原子团半径
plotODsum = 1;   % 是否画OD求和
plotprecession = 1;   % 是否画进动

if_mod = 1;   % OD是否修正
rabi = 0;   % 是否为Rabi曲线
ramsey = 1;   % 是否为Ramsey曲线
dual_species = 1;   % 是否有两种同位素
normalized_detection = 0;
%normalized_detection = 21;   % 是否归一化探测，OD_2/OD_1
%normalized_detection = 12;   % 是否归一化探测，OD_1/OD_2
differential_detection = 1;   % 是否差分探测
save_data = 1;   % 是否保存

first = 425;   % 第一个文件夹序号
last = 437;   % 最后一个文件夹序号

% 设置横坐标公式为: xaxis=(first-1:last-1)*coeff+intercept;
intercept = 0;   % 第一组数据的自变量`
coeff = 10;   % 各组数据自变量间隔


if rabi == 1
    setXlabel='ROT Pulse us';%横坐标label
elseif ramsey == 1
    setXlabel='Precession Time ms';%横坐标label
else
    setXlabel='No.';%横坐标label
end


%% read data
datalength=last-first+1;
xaxis = (0:last-first)*coeff+intercept;
xaxis = [30 165 90 0 75 150 105 180 60 135 15 45 120];

% Preallocation
OD = zeros(photo,datalength);
atom = zeros(photo,datalength);
count = zeros(photo,datalength);

Timelist=datetime(zeros(datalength,6));

tic
parfor i=1:datalength % parallel computing
    filestr=[maindir,'Abs-',num2str(i+first-1),'\Output.txt'];
    filestr;
    datafile=fopen(filestr);
    data_out=textscan(datafile,'%f');
    totaldata=data_out{1};
    fclose(datafile);

    filestr_time=[maindir,'Abs-',num2str(i+first-1),'\time.txt'];
    time_hd=fopen(filestr_time);
    data_time=textscan(time_hd,'%s %s');
    Timelist(i)=datetime([cell2mat(data_time{1,1}),' ',cell2mat(data_time{1,2})],'InputFormat','yyyy-MM-dd HH:mm:ss'); %转成时间序列
    fclose(time_hd);

    for k = 1:photo
        atom(k,i) = totaldata(7*k+1);
        if if_mod == 1
            OD(k,i) = totaldata(7*k+2);
        elseif if_mod == 0
            OD(k,i) = totaldata(7*k+5);
        end
        count(k,i) = totaldata(7*k+3);
    end

end
toc


%% plot number of atoms
if plotnumber==1

    h1=figure('Name','Number of Atoms');
    hold on;
    for k = 1:photo
        plot(xaxis,atom(k,:),'.','Color',colors(2+k,:),'MarkerSize',20);
        ld_str{k} = ['atom ',num2str(k)];
    end
    legend(ld_str);
    clear ld_str;
    axis([min(xaxis) max(xaxis) 0 max(max(atom))*1.1]);
    title('Number of Atoms','FontName','times new roman','FontWeight','bold');
    xlabel(setXlabel);
    grid on;
    box on;
    set(gca,'FontSize',16,'FontName','times new roman');

    if save_data == 1
        saveas(h1,[maindir,'Abs-',num2str(last),'\N_Atoms.png']);
    end

end


%% plot ODsum
if plotODsum==1

    h2=figure('Name','OD Sum');
    hold on;
    for k = 1:photo
        plot(xaxis,OD(k,:),'.','Color',colors(k,:),'MarkerSize',20);
        ld_str{k} = ['OD ',num2str(k)];
    end
    legend(ld_str);
    clear ld_str;
    axis([min(xaxis) max(xaxis) 0 max(max(OD))*1.1]);
    title('OD','FontName','times new roman','FontWeight','bold');
    xlabel(setXlabel);
    grid on;
    set(gca,'FontSize',16,'FontName','times new roman');

    %set(gca,'XScale','log');
    %set(gca,'YScale','log');


    h2_0=figure('Name','OD Sum 1+2');
    hold on;
    OD_total = zeros(repeat,datalength);
    for k = 1:repeat
        OD_total(k,:) = OD(2*k-1,:)+OD(2*k);
        plot(xaxis,OD_total(k,:),'.','Color',colors(2*k-1,:),'MarkerSize',20);
        ld_str{k} = ['OD total ',num2str(2*k-1),num2str(2*k)];
    end
    legend(ld_str);
    clear ld_str;
    axis([min(xaxis) max(xaxis) 0 max(max(OD_total))*1.1])
    title('OD Total','FontName','times new roman','FontWeight','bold');
    xlabel(setXlabel);
    grid on;
    box on;

    set(gca,'XScale','linear');
    %set(gca,'YScale','log');

    set(gca,'FontSize',16,'FontName','times new roman');

    if save_data == 1
        saveas(h2,[maindir,'Abs-',num2str(last),'\OD.png']);
        saveas(h2,[maindir,'Abs-',num2str(last),'\OD.fig']);
        saveas(h2_0,[maindir,'Abs-',num2str(last),'\ODtotal.png']);
    end

    %% Plot time
    figure
    h3_0=plot(Timelist,OD(1,:),'.','Color',colors(1,:),'MarkerSize',20);
    grid off
    set(gca,'FontSize',16)
    saveas(h3_0,[maindir,'Abs-',num2str(last),'\time.png'])

end


%% plot precession
if plotprecession==1

    h6=figure('Name','Precession');
    hold on;
    relaOD = zeros(repeat,datalength);

    for k = 1:repeat

        % 归一化探测 %
        if normalized_detection && differential_detection == 0

            if normalized_detection == 21   % OD2/OD1
                relaOD(k,:) = OD(2*k,:)./OD(2*k-1,:);
                ylabel('OD_2/OD_1');
            elseif normalized_detection == 12   % OD1/OD2
                relaOD(k,:) = OD(2*k-1,:)./OD(2*k,:);
                ylabel('OD_1/OD_2');
            end
            axis([min(xaxis) max(xaxis) 0 1]);
            plot(xaxis,relaOD(k,:),'.','Color',colors(k,:),'MarkerSize',16);

        % 差分探测 %
        elseif differential_detection == 1 && normalized_detection == 0

            relaOD(k,:) = (OD(2*k-1,:)-OD(2*k,:))./(OD(2*k-1,:)+OD(2*k,:));
            ylabel('S_z');
            axis([min(xaxis) max(xaxis) -1 1]);

            % 拟和 %
            if species == 171
                species_coeff = 1;
            elseif species == 173
                species_coeff = 0.726076;
            end
            [xData, yData] = prepareCurveData(xaxis,relaOD(k,:));
            weight = ones(length(xData),1);
            ft = fittype( 'a*sin(2*pi*x/T+b)+c', 'independent', 'x', 'dependent', 'y' );
            opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
            opts.Display = 'Off';
            opts.Lower = [80*species_coeff 0.01 -2*pi -5];   % T a b c
            opts.Upper = [140*species_coeff 1 2*pi 5];   % T a b c
            opts.StartPoint = [108*species_coeff 0.6 0 0];   % T a b c
            opts.Weights = weight;

            % 对数据进行模型拟合 %
            [fitresult, gof] = fit(xData, yData, ft, opts);
            amp(k) = fitresult.a;
            T(k) = fitresult.T;
            c(k) = fitresult.c;
            interval = confint(fitresult);
            a_sigma(k) = (interval(2,2)-interval(1,2))/4;
            T_sigma(k) = (interval(2,1)-interval(1,1))/4;
            c_sigma(k) = (interval(2,4)-interval(1,4))/4;

            l = plot(fitresult, xData, yData);
            l(1).Marker = '.';
            l(1).MarkerSize = 16;
            l(1).Color = colors(k,:);
            l(2).LineStyle = '-';
            l(2).Color = colors(k,:);
            l(2).LineWidth = 1;

        end

        ld_str{2*k-1} = ['a',num2str(k),' = ',num2str(roundn(amp(k),-3),'%.3f'),'(',num2str(round(a_sigma(k)*1000)),')'];
        ld_str{2*k} = '';

    end
    xlabel(setXlabel);
    ylabel('Sz');
    grid on;
    box on;
    set(gca,'FontSize',16,'FontName','times new roman');
    %set(gca,'XScale','log');
    %set(gca,'YScale','log');


    legend(ld_str,'Location','best');
    clear ld_str;

    if save_data == 1
        saveas(h6,[maindir,'Abs-',num2str(last),'\precession.png']);
        saveas(h6,[maindir,'Abs-',num2str(last),'\precession.fig']);
    end

end


%% Save results

if save_data == 1
    clear main_dir_0
    save([maindir,'Abs-',num2str(last),'\repeat_probe.mat']);
    save([maindir,'Abs-',num2str(last),'\repeat_amp.mat'],'amp','T');
    clear Timelist
end
