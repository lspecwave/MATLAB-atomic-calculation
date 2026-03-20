clear all
close all

dir_NOW='E:\Data\2021-09-12\';

tof=14;
time=((0:tof)*0.2)+0.1;
pixelsize=6.5;
xposition=341;

for i=(1:1:tof)
    image1=imread([dir_NOW,'\Abs-',num2str(i),'\1.tif']);
	image2=imread([dir_NOW,'\Abs-',num2str(i),'\2.tif']);
	image3=imread([dir_NOW,'\Abs-',num2str(i),'\3.tif']);
%     image1=image1(1:300,:,1)-image3(1:300,:,1);
%     image2=image2(1:300,:,1)-image3(1:300,:,1);
    image1=image1(:,:,1)-image3(:,:,1);
    image2=image2(:,:,1)-image3(:,:,1);
    image1=im2double(image1);
    image2=im2double(image2);
    image3=log(image2./image1);
    sigma1=2;
    gausFilter=fspecial('gaussian',[2 2],sigma1);
    blur=imfilter(image3,gausFilter,'replicate');
    blur=image3;
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
    figure
    f=fit((1:M)',blur(:,xposition),'a1*exp(-((x-b1)/c1)^2)+d1','StartPoint',[2 xposition 20 0.2]);
    plot(f,(1:M)',blur(:,xposition))
    sizeVimage(i+1)=f.c1/sqrt(2);
    centerVimage(i+1)=f.b1;
    f=fit((1:N)',blur(floor(centerVimage(i+1)),:)','a1*exp(-((x-b1)/c1)^2)+d1','StartPoint',[2 f.b1 20 0.2]);
    figure
    plot(f,(1:N)',blur(floor(centerVimage(i+1)),:)')
    sizeHimage(i+1)=f.c1/sqrt(2);
    
%     [App,cxpp,cypp,sxpp,sypp,sitapp,offsetpp]=Gauss2DFit(blur,1);
    
%      f=fit((1:M)',blur(:,445),'gauss1');
%      sizeVimage(i+1)=f.c1/sqrt(2);
%      figure
%      plot(f,(1:M)',blur(:,445))
     
%     f=fit((1:N)',blur(floor(cypp),:)','gauss1');
    sizeHimage(i+1)=f.c1/sqrt(2);
    
%     centerx(i+1)=cxpp;
%     centery(i+1)=cypp;
  
%     angle(i+1)=sitapp*180/pi;
%     r(i+1)=((sxpp^2+sypp^2)/2)^(1/2)*(6.5/1000000)*1000;
end
%%
close all
figure
sizeH=sizeHimage(1:tof+1)*6.5*0.001;
sizeV=sizeVimage(1:tof+1)*6.5*0.001

timesquared=time.^2;
sizesquaredH=sizeH.^2;
plot(timesquared,sizesquaredH,'.','Color',[0 98 132]./255.0,'MarkerSize',20)
timesquared=timesquared';
hold on
[f,gof,output]=fit(timesquared(1:tof+1),sizesquaredH(1:tof+1)','poly1');
bound=confint(f);
tempH_error=(bound(2)-bound(1))/4*171*1.67e-27/(1.38e-23)*1e6;
fplot=plot(timesquared,f(timesquared),'Color',[88 178 220]./255.0,'Linewidth',2);
tempH=f.p1*171*1.67e-27/(1.38e-23)*1e6;
xlabel('{t^2(ms^2)}')
ylabel('{\sigma^2(mm^2)}')
set(gca,'Fontsize',16)
grid on
axis([0 max(timesquared)*1.1 0 max(sizesquaredH)*1.1])
legend(['H Temp ',num2str(tempH,4),'(',num2str(tempH_error,4),')',' uK'],'FontSize',15,'Location','northwest')
% legend([num2str(temp,3),'uK'])
%text(50,sizesquaredH(tof+1),[num2str(tempH,4),'uK',' ','h direction'])
%set(get(get(fplot,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
%%
figure
sizeV=sizeVimage(1:tof+1)*6.5*0.001;

timesquared=time.^2;
sizesquaredV=sizeV.^2;
plot(timesquared,sizesquaredV,'.','Color',[0 98 132]./255.0,'MarkerSize',20)
timesquared=timesquared';
hold on
[f,gof,output]=fit(timesquared(1:tof+1),sizesquaredV(1:tof+1)','poly1');
bound=confint(f);
tempV_error=(bound(2)-bound(1))/4*171*1.67e-27/(1.38e-23)*1e6;
fplot=plot(timesquared,f(timesquared),'Color',[88 178 220]./255.0,'Linewidth',2);
tempV=f.p1*171*1.67e-27/(1.38e-23)*1e6;
xlabel('{t^2(ms^2)}')
ylabel('{\sigma^2(mm^2)}')
set(gca,'Fontsize',16)
grid on
axis([0 max(timesquared)*1.1 0 max(sizesquaredV)*1.1])
legend(['V Temp ',num2str(tempV,4),'(',num2str(tempV_error,4),')',' uK'],'FontSize',15,'Location','northwest')
% legend([num2str(temp,3),'uK'])

%set(get(get(fplot,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
saveas(figure(1),[dir_NOW,'\','temperature_fit_H.fig'])
saveas(figure(2),[dir_NOW,'\','temperature_fit_V.fig'])
%%