clear all;
for numberbg=1:111
%% Fringe reduction

%% Input Area

background_folder='E:\Data\2021-11-25\Background';
numberofbg=numberbg;
raw_folder='E:\Data\2021-11-25\Abs-450';
roi_xmin=80;
roi_ymin=80;
roi_xmax=120;
roi_ymax=120;
ODscale=0.1;
showoriginalOD=1;

%% Read image
for i=1:numberofbg
imagelight(:,:,i)=double(imread([background_folder,'\',num2str(i),'.tif']));
end
imageatom=double(imread([raw_folder,'\1.tif']));
%imageatom=double(imread([background_folder,'\0.tif']));
imagelight_raw=double(imread([raw_folder,'\2.tif']));
imagebg=double(imread([raw_folder,'\3.tif']));
%% Generate Mask
x1=roi_xmin;x2=roi_xmax;y1=roi_ymin;y2=roi_ymax;
[M,N]=size(imagelight(:,:,1));
mask=ones(M,N);      
mask(y1:y2,x1:x2)=0;
A=mask.*imageatom;
B=mask.*imagelight;
%% Calculating coefficient
 for i=1:1:numberofbg
        for j=1:1:numberofbg
            Bmatrix(i,j)=sum(sum(B(:,:,i).*B(:,:,j)));
        end
 end
        for i=1:1:numberofbg
            b(i)=sum(sum(A.*B(:,:,i)));
        end
        c=Bmatrix\b';
        for i=1:1:numberofbg
            q(:,:,i)=c(i)*imagelight(:,:,i);
        end
lightbackground=sum(q,3);
%% OD Calculate       
OD=log((lightbackground-imagebg)./(imageatom-imagebg));
OD(isnan(OD))=0;
OD(isinf(OD))=5.4;
countperpixel=mean(mean(lightbackground(y1:y2,x1:x2)));

OD_original=log((imagelight_raw-imagebg)./(imageatom-imagebg));
OD(isnan(OD))=0;
OD(isinf(OD))=5.4;


h1=figure(1);
imshow(OD,'border','tight','initialmagnification','fit');
set(gcf,'Position',[1000 500 500 500]);
colormap jet
set(gca,'Clim',[-0.1 ODscale]);
if showoriginalOD==1
h2=figure(2);
imshow(OD_original,'border','tight','initialmagnification','fit');
set(gcf,'Position',[500 500 500 500]);
colormap jet
set(gca,'Clim',[-0.1 ODscale]);   
end

%% Evaluation
%noise_OD=sqrt(sum(sum((mask.*OD).^2))/(M*N-(y2-y1)*(x2-x1)));
%noise_ODraw=sqrt(sum(sum((mask.*OD_original).^2))/(M*N-(y2-y1)*(x2-x1)));
%SNRGain=noise_ODraw/noise_OD;
noise_OD(numberbg)=sqrt(sum(sum((mask.*OD).^2))/(M*N-(y2-y1)*(x2-x1)));
noise_ODraw(numberbg)=sqrt(sum(sum((mask.*OD_original).^2))/(M*N-(y2-y1)*(x2-x1)));
SNRGain(numberbg)=noise_ODraw(numberbg)/noise_OD(numberbg);


noise_light(numberbg)=sqrt(sum(sum(((lightbackground-imageatom).*mask).^2))/(M*N-(y2-y1)*(x2-x1)));
shotnoise_light(numberbg)=sqrt(sum(sum(imageatom.*mask))/(M*N-(y2-y1)*(x2-x1)));
noise_noFR(numberbg)=sqrt(sum(sum(((imagelight_raw-imageatom).*mask).^2))/(M*N-(y2-y1)*(x2-x1)));
disp(numberbg);
end
h3=figure(3);
numberbg=[1:111];
plot(numberbg,SNRGain);

h4=figure(4);
plot(numberbg,noise_light);
hold on
plot(numberbg,shotnoise_light);
hold on
plot(numberbg,noise_noFR);
