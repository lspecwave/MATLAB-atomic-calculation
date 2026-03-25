%clear all;
%for numberbg=1:60
%% Fringe reduction
function [OD,noise_OD,SNRGain]=FringeReduction(raw_folder,ODnumber,numberofbg,atomphoto,roi_xmin,roi_ymin,roi_xmax,roi_ymax)
%% Input Area

%background_folder='E:\Data\2021-11-25\Background';
%numberofbg=30;
%raw_folder='E:\Data\2021-11-25\Abs-458';
%roi_xmin=60;
%roi_ymin=60;
%roi_xmax=140;
%roi_ymax=140;
%ODscale=0.3;

tic;

% Background image
imagebg=double(imread([raw_folder,'\',num2str(atomphoto+numberofbg+1),'.tif']));

% Atom image
imageatom=log(double(imread([raw_folder,'\',num2str(ODnumber),'.tif']))-imagebg);

[size_A,size_B]=size(imageatom);
imagelight=zeros(size_A,size_B,numberofbg);

%% Read image

% Light image
imagelight_raw=log(double(imread([raw_folder,'\',num2str(atomphoto+1),'.tif']))-imagebg);


for i=1:numberofbg
imagelight(:,:,i)=log(double(imread([raw_folder,'\',num2str(i+atomphoto),'.tif']))-imagebg);
end




% toc_t=toc;
% disp([datestr(now, 'yyyy-mm-dd HH:MM:SS '),'FringeReduction.m, ', num2str(toc_t),'s'])

%% Generate Mask
x1=roi_xmin;x2=roi_xmax;y1=roi_ymin;y2=roi_ymax;
[M,N]=size(imagelight(:,:,1));
mask=ones(M,N);      
mask(x1:x2,y1:y2)=0;
A=mask.*imageatom;
B=mask.*imagelight;
%toc_t=toc;
%disp([datestr(now, 'yyyy-mm-dd HH:MM:SS '),'FringeReduction.m, ', num2str(toc_t),'s'])

%% Calculating coefficient
%  for i=1:1:numberofbg
%         for j=1:1:numberofbg
%             Bmatrix(i,j)=sum(sum(B(:,:,i).*B(:,:,j)));
%         end
%  end
%  
% toc_t=toc;
% disp([datestr(now, 'yyyy-mm-dd HH:MM:SS '),'FringeReduction.m, ', num2str(toc_t),'s'])
%  
% for i=1:1:numberofbg
%     b(i)=sum(sum(A.*B(:,:,i)));
% end
% c=Bmatrix\b';
% for i=1:1:numberofbg
%     q(:,:,i)=c(i)*imagelight(:,:,i);
% end
% lightbackground=sum(q,3);
%% Calculating coefficient

% check if .mat file exists

try
    load([raw_folder,'Bmatrix.mat'],'Bmatrix');
catch
    
     Bmatrix=zeros(numberofbg,numberofbg);
 
for i=1:1:numberofbg
        for j=1:1:i
            Bmatrix(i,j)=sum(sum(B(:,:,i).*B(:,:,j)));
            Bmatrix(j,i)=Bmatrix(i,j);
        end
end
%save([raw_folder,'Bmatrix.mat'],'Bmatrix')

end



 
 
% toc_t=toc;
% disp([datestr(now, 'yyyy-mm-dd HH:MM:SS '),'FringeReduction.m, ', num2str(toc_t),'s'])
%  


for i=1:1:numberofbg
    b(i)=sum(sum(A.*B(:,:,i)));
end
c=Bmatrix\b';
for i=1:1:numberofbg
    q(:,:,i)=c(i)*imagelight(:,:,i);
end
lightbackground=sum(q,3);

% toc_t=toc;
% disp([datestr(now, 'yyyy-mm-dd HH:MM:SS '),'FringeReduction.m, ', num2str(toc_t),'s'])
%  

%% OD Calculate       
OD=(lightbackground)-(imageatom);
OD(isnan(OD))=0;
OD(isinf(OD))=5.4;
countperpixel=mean(mean(lightbackground(y1:y2,x1:x2)));

OD_original=(imagelight_raw)-(imageatom);
OD(isnan(OD))=0;
OD(isinf(OD))=5.4;


%h1=figure(1);
%imshow(OD,'border','tight','initialmagnification','fit');
%set(gcf,'Position',[1000 500 500 500]);
%colormap jet
%set(gca,'Clim',[-0.1 ODscale]);
%if showoriginalOD==1
%h2=figure(2);
%imshow(OD_original,'border','tight','initialmagnification','fit');
%set(gcf,'Position',[500 500 500 500]);
%colormap jet
%set(gca,'Clim',[-0.1 ODscale]);   
%end

%% Evaluation
noise_OD=sqrt(sum(sum((mask.*OD).^2))/(M*N-(y2-y1)*(x2-x1)));
noise_ODraw=sqrt(sum(sum((mask.*OD_original).^2))/(M*N-(y2-y1)*(x2-x1)));
SNRGain=noise_ODraw/noise_OD;

toc_t=toc;
%disp([datestr(now, 'yyyy-mm-dd HH:MM:SS '),'FringeReduction.m, ', num2str(toc_t),'s'])
end
%noise_OD(numberbg)=sqrt(sum(sum((mask.*OD).^2))/(M*N-(y2-y1)*(x2-x1)));
%noise_ODraw(numberbg)=sqrt(sum(sum((mask.*OD_original).^2))/(M*N-(y2-y1)*(x2-x1)));
%SNRGain(numberbg)=noise_ODraw(numberbg)/noise_OD(numberbg);
%disp(numberbg);
%end
%h3=figure(3);
%numberbg=[1:60];
%plot(numberbg,SNRGain);
