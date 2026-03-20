close all

%% Input Area

maindir='E:\Data\2022-03-19\';%数据来源路径
plotnumber=1;%是否画原子数
plotradius=0;%是否画原子团半径
plotODsum=1;%是否画OD求和
plotSNRGain=0;%是否画SNR Gain
plotnoise_FR=0;%是否画Fringe removal后的noise OD
plotprecession=1;%是否画进动
first=47;%第一个文件夹序号
last=67;%最后一个文件夹序号
%设置横坐标公式为:xaxis=(first-1:last-1)*coeff+intercept;
intercept=1;%第一组数据的自变量`
coeff=1;%各组数据自变量间隔
setXlabel='Precession ms';%横坐标label


%% read data

xaxis=(0:last-first)*coeff+intercept;

%xaxis=[5:5:150,1005:5:1150];l

numberofatoms1=zeros(last-first+1,1);
noise_OD=zeros(last-first+1,1);
countperpixel=zeros(last-first+1,1);

ODsum1=zeros(last-first+1,1);
ODsum2=zeros(last-first+1,1);

numberofatoms2=zeros(last-first+1,1);
radius=zeros(last-first+1,1);
for i=first:1:last
filestr=[maindir,'\Abs-',num2str(i),'\Output.txt'];
filestr
datafile=fopen(filestr);
totaldata=textscan(datafile,'%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f ');
fclose(datafile);

numberofatoms1(i+1-first)=totaldata{1};
noise_OD(i+1-first)=totaldata{2};
countperpixel(i+1-first)=totaldata{3};
radius(i+1-first)=totaldata{4};
ODsum1(i+1-first)=totaldata{5};
noise_FR(i+1-first)=totaldata{6};
SNRGain(i+1-first)=totaldata{7};

%只拍摄了一张原子照片时注释掉
 ODsum2(i+1-first)=totaldata{12};
 numberofatoms2(i+1-first)=totaldata{8};
end

%% plot number of atoms
if plotnumber==1
  figure('Name','Number of Atoms'); 
  plot(xaxis,numberofatoms1,'.','Color',[0 98 132]./255.0,'MarkerSize',20);
  axis([min(xaxis) max(xaxis) min(numberofatoms1)*0.9 max(numberofatoms1)*1.1])
  title('Number of Atoms');
  xlabel(setXlabel);
  grid on
end
%% plot ODsum
if plotODsum==1
  figure('Name','OD Sum'); 
  plot(xaxis,ODsum1,'.','Color',[0 98 132]./255.0,'MarkerSize',20);
  hold on
  plot(xaxis,ODsum2,'.','Color',[200 98 132]./255.0,'MarkerSize',20);
  axis([min(xaxis) max(xaxis) 0 max(ODsum1)*1.1])
  title('OD Sum');
  xlabel(setXlabel);
  grid on
end
%% plot radius
if plotradius==1
  figure('Name','Radius'); 
  plot(xaxis,radius,'.','Color',[0 98 132]./255.0,'MarkerSize',20);
  axis([min(xaxis) max(xaxis) min(radius)*0.9 max(radius)*1.1])
  title('Radius');
  xlabel(setXlabel);
  grid on
end
%% plot SNRGain
if plotSNRGain==1
   figure('Name','SNRGain'); 
  plot(xaxis,SNRGain,'.','Color',[0 98 132]./255.0,'MarkerSize',20);
  axis([min(xaxis) max(xaxis) min(SNRGain)*0.9 max(SNRGain)*1.1])
  title('SNR Gain');
  xlabel(setXlabel);
  grid on 
end
%% plot noise_FR
if plotnoise_FR==1
   figure('Name','Noise_FR'); 
  plot(xaxis,noise_FR,'.','Color',[0 98 132]./255.0,'MarkerSize',20);
  axis([min(xaxis) max(xaxis) min(noise_FR)*0.9 max(noise_FR)*1.1])
  title('Noise FR');
  xlabel(setXlabel);
  grid on 
end
%% plot precession
if plotprecession==1
   relativeOD=numberofatoms2./numberofatoms1;
   %relativeOD=ODsum2./ODsum1;
   relativeOD=(numberofatoms1-numberofatoms2)./(numberofatoms1+numberofatoms2);
   figure('Name','Precession'); 
   plot(xaxis,relativeOD,'.','Color',[0 98 132]./255.0,'MarkerSize',20);
   axis([min(xaxis) max(xaxis) 0 1])
   title('Precession');
   xlabel(setXlabel);
   grid on 
    
    
end