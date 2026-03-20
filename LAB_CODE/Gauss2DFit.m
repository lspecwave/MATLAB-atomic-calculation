function [App,cxpp,cypp,sxpp,sypp,sitapp,offsetpp,image_Fit,zfitpp]=Gauss2DFit(image,plot,varargin)
name=inputname(1);
imagetofit=image;
%Acquire Image Size
[a,b]=size(imagetofit);

%To form grid
x=1:b;
y=1:a;
[X,Y]=meshgrid(x,y);
h=0.1;

%Clear inf or nan values to zero
imagetofit(isnan(imagetofit))=0;
imagetofit(isinf(imagetofit))=0;

% 将图像取对数，进行二次多项式拟合

[Ap,cxp,cyp,sxp,syp,sitap]=polyGF2D(X,Y,imagetofit,h); %取对数进行二次多项式拟合
offsetp=0;


options = optimset('Display','off','TolFun',1e-3,'LargeScale','off'); %用fminunc拟合，将上面的拟合结果带入作为fminunc的初值
initpar=[Ap,cxp,cyp,sxp,syp,sitap,offsetp];
if isreal(initpar)
    para=fminunc(@objfun,initpar,options,X,Y,imagetofit);
    App=para(1);cxpp=para(2);cypp=para(3);sxpp=para(4);sypp=para(5);sitapp=para(6);offsetpp=para(7);
else
    [App,cxpp,cypp,sxpp,sypp,sitapp,offsetpp]=deal(0,0,0,0,0,0,0);
end

% 显示拟合结果
[App,cxpp,cypp,sxpp,sypp,180*sitapp/pi,offsetpp];
zfitpp=App*exp(-(cos(sitapp)*(X-cxpp)+sin(sitapp)*(Y-cypp)).^2/2/sxpp^2-(-sin(sitapp)*(X-cxpp)+cos(sitapp)*(Y-cypp)).^2/2/sypp^2)+offsetpp;

if nargin==2
    figure
    set(gcf,'Visible','Off');
    image_Fit=imshow(zfitpp,'Colormap',jet,'border','tight','initialmagnification','fit');
elseif nargin==1

    figure('Name',name)
    subplot(1,2,1)
    % mesh(imagetofit)
    imshow(imagetofit,'Colormap',jet)
    set(gca,'Clim',[offsetpp-abs(offsetpp) App*1.3]);
    %axis([1 b 1 a]);
    title(['Raw Data ',name])

    subplot(1,2,2)
    % mesh(zfitpp)
    imshow(zfitpp,'Colormap',jet)
    set(gca,'Clim',[offsetpp-abs(offsetpp) App*1.3]);
    % axis([1 b 1 a]);
    title(['Fit Data ',name])
    figure
    set(gcf,'Visible','Off');
    image_Fit=imshow(zfitpp,'Colormap',jet,'border','tight','initialmagnification','fit');
    set(gca,'Clim',[offsetpp-abs(offsetpp) App*1.3]);

end

