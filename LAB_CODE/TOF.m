clear all
close all
%% Input Area
dir_TOF='\\Artemis-pc\e\Data\2025-06-18\';%文件路径
TOF_start = 1;    % TOF起始时间
TOF_interval = 0.5;   % TOF时间间隔
hold_time = 35;
first = 345;   % 第一个文件夹的序号
last = 353;   % 第二个文件夹的序号

pixelsize = 6.5;   % um
yposition = 75;   % 水平方向为y方向
xposition = 100;   % 竖直方向为x方向，这个数值用于拟合的起始点
fringe_removal = 0;   % 是否使用消条纹

%%
tof=last-first+1;
time=((0:(tof-1))*TOF_interval)+TOF_start;
for i=(first:1:last)
    display(['Processing No.',num2str(i)]);
    %image1=imread([dir_TOF,'\Abs-',num2str(i),'\1.tif']);
    %image2=imread([dir_TOF,'\Abs-',num2str(i),'\2.tif']);
    %image3=imread([dir_TOF,'\Abs-',num2str(i),'\3.tif']);

    %imageOD=imread([dir_TOF,'Abs-',num2str(i),'\OD_raw.tif']);

    % image1=image1(:,:,1)-image3(:,:,1);
    % image2=image2(:,:,1)-image3(:,:,1);
    % image1=im2double(image1);
    % image2=im2double(image2);
    % image3=log(image2./image1);
    if fringe_removal==0
        load([dir_TOF,'Abs-',num2str(i),'\OD_raw.mat']);
    end
    if fringe_removal==1
        load([dir_TOF,'Abs-',num2str(i),'\OD_FR_2.mat']);
        OD_raw=OD_FR;
    end
    sigma1=2;
    gausFilter=fspecial('gaussian',[2 2],sigma1);
    blur=imfilter(OD_raw,gausFilter,'replicate');
    blur=OD_raw;
    blur(isnan(blur))=0;
    blur(isinf(blur))=5.54;

    % figure;
    % imagesc(image3);
    % colormap jet;
    % set(gca,'Clim',[-0.1 3.2]);
    % colorbar
    [M,N]=size(blur);

    %[App,cxpp,cypp,sxpp,sypp,sitapp,offsetpp]=Gauss2DFit(blur,1);
    %f=fit((1:M)',blur(:,floor(cxpp)),'gauss1');
    figure('Visible','on');
    f=fit((1:M)',blur(:,yposition),'a1*exp(-((x-b1)/c1)^2)+d1','StartPoint',[2 xposition 20 0]);
    plot(f,(1:M)',blur(:,yposition))
    sizeVimage(i)=f.c1/sqrt(2);
    bound=confint(f);
    sizeVimage_error(i)=(bound(2,3)-bound(1,3))/4/sqrt(2);
    centerVimage(i)=f.b1;
    f=fit((1:N)',blur(floor(centerVimage(i)),:)','a1*exp(-((x-b1)/c1)^2)+d1','StartPoint',[2 yposition 20 0]);
    figure('Visible','on');
    plot(f,(1:N)',blur(floor(centerVimage(i)),:)')
    sizeHimage(i)=f.c1/sqrt(2);
    bound=confint(f);
    sizeHimage_error(i)=(bound(2,3)-bound(1,3))/4/sqrt(2);
    sizeHimage(i)=f.c1/sqrt(2);

end

%% 水平方向温度拟合

close all
f1=figure
sizeH=sizeHimage(first:1:last)*pixelsize*0.001;
sizeV=sizeVimage(first:1:last)*pixelsize*0.001;

sizeH_err=sizeHimage_error(first:1:last)*pixelsize*0.001;
sizeV_err=sizeVimage_error(first:1:last)*pixelsize*0.001;

sizesquaredH_err=2.*sizeH.*sizeH_err;
sizesquaredV_err=2.*sizeV.*sizeV_err;

timesquared=time.^2;
sizesquaredH=sizeH.^2;
plot(timesquared,sizesquaredH,'.','Color',[0 98 132]./255.0,'MarkerSize',20)
timesquared=timesquared';
hold on;

[f,gof,output]=fit(timesquared(1:tof),sizesquaredH(1:tof)','poly1');

bound=confint(f);
tempH_error=(bound(2)-bound(1))/4*171*1.67e-27/(1.38e-23)*1e6;

fplot=plot(timesquared,f(timesquared),'Color',[88 178 220]./255.0,'Linewidth',2);
tempH=f.p1*171*1.67e-27/(1.38e-23)*1e6;
xlabel('{t^2(ms^2)}')
ylabel('{\sigma^2(mm^2)}')
set(gca,'Fontsize',18,'FontName','Arial','FontWeight','bold');
grid on;
axis([0 max(timesquared)*1.1 0 min( max(sizesquaredH)*1.1 )])
legend(['H Temp ',num2str(tempH,4),'(',num2str(tempH_error,4),')',' uK'],'FontSize',15,'Location','northwest')
% legend([num2str(temp,3),'uK'])
%text(50,sizesquaredH(tof+1),[num2str(tempH,4),'uK',' ','h direction'])
%set(get(get(fplot,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');


f2=figure
errorbar(timesquared,sizesquaredH,sizesquaredH_err,'.','CapSize',0,'LineWidth',1.6,'MarkerSize',20,'Color',[0 0.38 0.52]);
hold on
xlabel('{t^2(ms^2)}')
ylabel('{\sigma^2(mm^2)}')
set(gca,'Fontsize',16)
grid on
axis([0 max(timesquared)*1.1 0 min( max(sizesquaredH)*1.1  )])

% 排除异常点 %
xdata = timesquared(1:tof);
ydata = sizesquaredH(1:tof)';
wdata = 1./sizesquaredH_err.^2;
xdata(9) = [];
ydata(9) = [];
wdata(9) = [];

[fH,gof,output]=fit(xdata,ydata,'poly1','Weight',wdata);
%[fH,gof,output]=fit(timesquared(1:tof),sizesquaredH(1:tof)','poly1','Weight',1./sizesquaredH_err.^2);
bound=confint(f);
tempH_error=(bound(2)-bound(1))/4*171*1.67e-27/(1.38e-23)*1e6;

fplot=plot(timesquared,fH(timesquared),'Color',[88 178 220]./255.0,'Linewidth',2);
tempH=fH.p1*171*1.67e-27/(1.38e-23)*1e6;
xlabel('{t^2(ms^2)}')
ylabel('{\sigma^2(mm^2)}')
set(gca,'Fontsize',18,'FontName','Arial','FontWeight','bold');
grid on;
%axis([0 max(timesquared)*1.1 0 max(sizesquaredH)*1.1])
legend(['H Temp ',num2str(tempH,4),'(',num2str(tempH_error,4),')',' uK'],'FontSize',15,'Location','northwest');

%% 竖直方向温度拟合

f3=figure
sizeV=sizeVimage(first:1:last)*pixelsize*0.001;

timesquared=time.^2;
sizesquaredV=sizeV.^2;
plot(timesquared,sizesquaredV,'.','Color',[0 98 132]./255.0,'MarkerSize',20)
timesquared=timesquared';
hold on

opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [0 -5e-3];
opts.Upper = [4e-3 5e-3];
opts.StartPoint = [2e-3 1e-3];

[f,gof,output]=fit(timesquared(1:tof),sizesquaredV(1:tof)','poly1',opts);
bound=confint(f);
tempV_error=(bound(2)-bound(1))/4*171*1.67e-27/(1.38e-23)*1e6;

fplot=plot(timesquared,f(timesquared),'Color',[88 178 220]./255.0,'Linewidth',2);
tempV=f.p1*171*1.67e-27/(1.38e-23)*1e6;
xlabel('{t^2(ms^2)}')
ylabel('{\sigma^2(mm^2)}')
set(gca,'Fontsize',18,'FontName','Arial','FontWeight','bold');
grid on;
axis([0 max(timesquared)*1.1 0 min( max(sizesquaredV)*1.1 )])
legend(['V Temp ',num2str(tempV,4),'(',num2str(tempV_error,4),')',' uK'],'FontSize',15,'Location','northwest')

f4=figure
errorbar(timesquared,sizesquaredV,sizesquaredV_err,'.','CapSize',0,'LineWidth',1.6,'MarkerSize',20,'Color',[0 0.38 0.52]);
hold on
xlabel('{t^2(ms^2)}')
ylabel('{\sigma^2(mm^2)}')
set(gca,'Fontsize',16)
grid on
axis([0 max(timesquared)*1.1 0 min( max(sizesquaredV)*1.1 )])
[fV,gof,output]=fit(timesquared(1:tof),sizesquaredV(1:tof)','poly1','Weight',1./sizesquaredV_err.^2);
bound=confint(fV);
tempV_error=(bound(2)-bound(1))/4*171*1.67e-27/(1.38e-23)*1e6;
fplot=plot(timesquared,fV(timesquared),'Color',[88 178 220]./255.0,'Linewidth',2);
tempV=fV.p1*171*1.67e-27/(1.38e-23)*1e6;
xlabel('{t^2(ms^2)}')
ylabel('{\sigma^2(mm^2)}')
set(gca,'Fontsize',18,'FontName','Arial','FontWeight','bold');
grid on
%axis([0 max(timesquared)*1.1 0 max(sizesquaredV)*1.1])
legend(['V Temp ',num2str(tempV,4),'(',num2str(tempV_error,4),')',' uK'],'FontSize',15,'Location','northwest')

% legend([num2str(temp,3),'uK'])

%set(get(get(fplot,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
saveas(f2,[dir_TOF,'\Abs-',num2str(last),'\','temperature_fit_H.fig'])
saveas(f4,[dir_TOF,'\Abs-',num2str(last),'\','temperature_fit_V.fig'])
saveas(f2,[dir_TOF,'\Abs-',num2str(last),'\','temperature_fit_H.png'])
saveas(f4,[dir_TOF,'\Abs-',num2str(last),'\','temperature_fit_V.png'])
%%
save([dir_TOF,'\Abs-',num2str(last),'\Temp.mat'],'hold_time','tempH','tempH_error','tempV','tempV_error');

