close all
clear all
colors=npg(10); % Ten basic colors

%% Input Area

maindir=['\\ARTEMIS-PC\Data\2026-08-21' ...
    '\'];%数据来源路径

repeat = 1;   % 探测组数,照片数的一半
photo = 2*repeat;
species = 173;
mag = 9.7;   % 磁场和10mG的比值

plotnumber = 1;   % 是否画原子数
plotradius = 0;   % 是否画原子团半径
plotODsum = 1;   % 是否画OD求和
plotprecession = 1;   % 是否画进动

if_mod = 1;   % OD是否修正
phase = 0;   % 是否为稳定相位曲线
if phase == 1
    load('\\Artemis-pc\Data\2026-06-02\Abs-\repeat_amp.mat');
end
ramsey = 1;   % 是否为Ramsey进动曲线
offset = 0;   % 是否考虑曲线上下不对称

save_data = 1;   % 是否保存

first = 893;   % 第一个文件夹序号
last = 905;   % 最后一个文件夹序号

knowT = 0;
if knowT == 1
    T = (14020+46+4*2+18.7)/1733.75;   % 是否已知周期
    T_sigma = 5/1733.75;
end

delete = 0;
delete_num = [5];   % 必须从小到大

% 设置横坐标公式为: xaxis=(first-1:last-1)*coeff+intercept;
intercept = 15;   % 第一组数据的自变量`
coeff = 1.5;   % 各组数据自变量间隔


if ramsey == 1
    setXlabel='Precession Time (ms)';%横坐标label
    %setXlabel='ROT (\mus)';%横坐标label
else
    setXlabel='No.';%横坐标label
end


%% read data
datalength=last-first+1;
xaxis = (0:last-first)*coeff+intercept;
%xaxis = [16.5 15 18 30 33 21 22.5 25.5 24 19.5 28.5 31.5 27];
%xaxis = [39 49 27 31 29 17 53 35 47 33 51 25 43 24 41 45 19 15 21 37 55];
%xaxis = zeros(1,length(temp)*2);
%xaxis(1:2:length(temp)*2-1) = temp;
%xaxis(2:2:length(temp)*2) = temp;
%xaxis = [18:3:27 21.1:0.2:23.1 17.5:0.1:18 18.2 18.4 30:3:48 29.7:0.2:30.3];
%xaxis = [21.5:0.1:22.5 25:3:40 14.5:0.2:15.9 18:0.2:18.4 32.5:0.2:33.5 43:3:46];

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
    mean_sz = zeros(1,datalength);

    for k = 1:repeat

        relaOD(k,:) = (OD(2*k-1,:)-OD(2*k,:))./(OD(2*k-1,:)+OD(2*k,:));
        if delete == 1
            for kk = length(delete_num):-1:1
                relaOD(:,delete_num(kk)) = [];
                xaxis(delete_num(kk)) = [];
            end
        end
        ylabel('S_z');

        % 进动曲线 %
        if ramsey == 1 && phase == 0
            % 进动周期未知 %
            if knowT == 0
                axis([min(xaxis) max(xaxis) -1 1]);
                % 拟合 %
                if species == 171
                    species_coeff = 1;
                elseif species == 173
                    species_coeff = 0.726076;
                end
                [xData, yData] = prepareCurveData(xaxis,relaOD(k,:));
                weight = ones(length(xData),1);

                if offset == 1
                    ft = fittype( 'a*sin(2*pi*(x/T+b))+c', 'independent', 'x', 'dependent', 'y' );
                    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
                    opts.Display = 'Off';
                    opts.Lower = [90*species_coeff/mag 0.15 0 -5];   % T a b c
                    opts.Upper = [130*species_coeff/mag 1 1 5];   % T a b c
                    opts.StartPoint = [107*species_coeff/mag 0.7 0.5 0];   % T a b c
                elseif offset == 0
                    ft = fittype( 'a*sin(2*pi*(x/T+b))', 'independent', 'x', 'dependent', 'y' );
                    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
                    opts.Display = 'Off';
                    opts.Lower = [90*species_coeff/mag 0.3 -0.5];   % T a b
                    opts.Upper = [130*species_coeff/mag 1 0.5];   % T a b
                    opts.StartPoint = [108*species_coeff/mag 0.9 0.1];   % T a b
                    c = 0;
                end
                opts.Weights = weight;

                % 对数据进行模型拟合 %
                [fitresult, gof] = fit(xData, yData, ft, opts);
                amp(k) = fitresult.a;
                T(k) = fitresult.T;
                phi_vs_2pi(k) = fitresult.b;
                interval = confint(fitresult);
                a_sigma(k) = (interval(2,2)-interval(1,2))/4;
                T_sigma(k) = (interval(2,1)-interval(1,1))/4;
                phi_vs_2pi_sigma(k) = (interval(2,3)-interval(1,3))/4;

                if offset == 1
                    c(k) = fitresult.c;
                    c_sigma(k) = (interval(2,4)-interval(1,4))/4;
                end

                l = plot(fitresult, xData, yData);

                % 已知进动周期 %
            elseif knowT == 1
                %xaxis(5) = [];
                %relaOD(5) = [];
                axis([min(xaxis-0.2*T)*(2*pi/T) max(xaxis+0.2*T)*(2*pi/T) -1 1]);

                [xData, yData] = prepareCurveData(xaxis,relaOD(k,:));
                weight = ones(length(xData),1);

                ft = fittype( 'a*sin(x+b)', 'independent', 'x', 'dependent', 'y' );
                opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
                opts.Display = 'Off';
                opts.Lower = [0.15 -pi];   % a b
                opts.Upper = [1 pi];   % a b
                opts.StartPoint = [0.7 0];   % a b
                opts.Weights = weight;
                c = 0;

                % 对数据进行模型拟合 %
                [fitresult, gof] = fit(xData*(2*pi/T), yData, ft, opts);
                amp(k) = fitresult.a;
                phi_vs_2pi(k) = fitresult.b;
                interval = confint(fitresult);
                a_sigma(k) = (interval(2,1)-interval(1,1))/4;
                phi_vs_2pi_sigma(k) = (interval(2,2)-interval(1,2))/4;

                x_tick = round(gca().XTick/(2*pi/T))*(2*pi/T);
                xticks([]);
                %xticks(x_tick);
                %xticklabels(x_tick/(2*pi/T));

                l = plot(fitresult, xData*(2*pi/T), yData);

            end

            l(1).Marker = '.';
            l(1).MarkerSize = 16;
            l(1).Color = colors(k,:);
            l(2).LineStyle = '-';
            l(2).Color = colors(k,:);
            l(2).LineWidth = 1;

            ld_str{2*k-1} = ['a',num2str(k),' = ',num2str(roundn(amp(k),-3),'%.3f'),'(',num2str(round(a_sigma(k)*1000)),')'];
            ld_str{2*k} = '';

        elseif ramsey == 0 && phase == 1
            % l = plot(xaxis,relaOD,'.--');
            % l.MarkerSize = 16;
            % l.Color = colors(k,:);
            % l.LineWidth = 1;
            mean_sz = mean_sz + (( OD(2*k-1,:)-OD(2*k,:) )/amp(k))./(sum(OD,1));
        end

    end
    xlabel(setXlabel);
    ylabel('Sz');
    grid on;
    box on;
    set(gca,'FontSize',16,'FontName','times new roman');
    %set(gca,'XScale','log');
    %set(gca,'YScale','log');

    if ramsey == 1 && phase == 0
        legend(ld_str,'Location','best');
        clear ld_str;
    elseif phase == 1 && ramsey == 0
        l = plot(xaxis,mean_sz,'.--');
        l.MarkerSize = 16;
        l.Color = colors(1,:);
        l.LineWidth = 1;
    end

    if save_data == 1
        saveas(h6,[maindir,'Abs-',num2str(last),'\precession.png']);
        saveas(h6,[maindir,'Abs-',num2str(last),'\precession.fig']);
    end

end


%% Save results

if save_data == 1
    clear main_dir_0
    if knowT == 1
        save([maindir,'Abs-',num2str(last),'\repeat_probe_Tknow.mat']);
    elseif knowT == 0
        save([maindir,'Abs-',num2str(last),'\repeat_probe.mat']);
    end
    if ramsey == 1 && phase == 0
        if knowT == 1
            save([maindir,'Abs-',num2str(last),'\repeat_amp_Tknow.mat'],'amp','T','a_sigma','T_sigma');
        elseif knowT == 0
            save([maindir,'Abs-',num2str(last),'\repeat_amp.mat'],'amp','T','a_sigma','T_sigma','c');
        end
    elseif phase == 1 && ramsey == 0
        save([maindir,'Abs-',num2str(last),'\repeat_phase.mat'],'mean_sz');
    end
    clear Timelist
end
