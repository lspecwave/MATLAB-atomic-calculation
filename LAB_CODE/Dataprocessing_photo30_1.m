
tic
test=1;
if test==1  
    dir='C:\Users\EDM\Documents\MATLAB\0';
    dir=['E:\data\2021_03_03\Multi_Runs_44\',num2str(241)];
    scale=2;
    Fit2D=0;
    imagevisible=1;
    photo30=1;
    precession=1;
    sumarea_1=[41 54 45 58];%[y1 y2 x1 x2]
    sumarea_2=[22 40 22 40];%[y1 y2 x1 x2]
end
    
imageposition=[0,100,128,128];

%show image or not
if imagevisible==0
    visibletag='off';
else
    visibletag='on';
end
%Read Image
    image1=imread([dir,'\1.tif']);
    image2=imread([dir,'\2.tif']);
    image3=imread([dir,'\3.tif']);
    image4=imread([dir,'\4.tif']);
    image5=imread([dir,'\5.tif']);
    image6=imread([dir,'\6.tif']);
    image7=imread([dir,'\7.tif']);
    image8=imread([dir,'\8.tif']);
    image9=imread([dir,'\9.tif']);
    image10=imread([dir,'\10.tif']);
    image11=imread([dir,'\11.tif']);
    maxpixelvalue_1=max(max(image1));
    maxpixelvalue_2=max(max(image2));
%Save Image for browsing in Labview
    %Image1 Normalization
    h1=figure(1);
    set(h1, 'visible','off');
    imshow(image1,'border','tight','initialmagnification','fit');
    set (h1,'Position',imageposition);
    set(gca,'Clim',[-0.1 maxpixelvalue_2]);
    %imageposition=imageposition+[128 0 0 0];
    saveas(h1,[dir,'\figure1.bmp'],'bmp');
    %Image2 Detection1
    h2=figure(2);
    set(h2, 'visible','off');
    imshow(image2,'border','tight','initialmagnification','fit');
    set (h2,'Position',imageposition);
    set(gca,'Clim',[-0.1 maxpixelvalue_2]);
    %imageposition=imageposition+[128 0 0 0];
    saveas(h2,[dir,'\figure2.bmp'],'bmp');
    %Image3 Detection2
    h3=figure(3);
    set(h3, 'visible','off');
    imshow(image3,'border','tight','initialmagnification','fit');
    set (h3,'Position',imageposition);
    set(gca,'Clim',[-0.1 maxpixelvalue_2]);
    %imageposition=imageposition+[128 0 0 0];
    saveas(h3,[dir,'\figure3.bmp'],'bmp');
    %Image4 Detection3
    h4=figure(4);
    set(h4, 'visible','off');
    imshow(image4,'border','tight','initialmagnification','fit');
    set (h4,'Position',imageposition);
    set(gca,'Clim',[-0.1 maxpixelvalue_2]);
    %imageposition=imageposition+[128 0 0 0];
    saveas(h4,[dir,'\figure4.bmp'],'bmp');
    %Image5 Detection4
    h5=figure(5);
    set(h5, 'visible','off');
    imshow(image5,'border','tight','initialmagnification','fit');
    set (h5,'Position',imageposition);
    set(gca,'Clim',[-0.1 maxpixelvalue_2]);
    %imageposition=imageposition+[128 0 0 0];
    saveas(h5,[dir,'\figure5.bmp'],'bmp');
    %Image6 Detection5
    h6=figure(6);
    set(h6, 'Visible',visibletag);
    imshow(image6,'border','tight','initialmagnification','fit');
    set (h6,'Position',imageposition);
    set(gca,'Clim',[-0.1 maxpixelvalue_2]);
    %imageposition=imageposition+[128 0 0 0];
    saveas(h6,[dir,'\figure6.bmp'],'bmp');
    %Image7 Detection6
    h7=figure(7);
    set(h7, 'Visible',visibletag);
    imshow(image7,'border','tight','initialmagnification','fit');
    set (h7,'Position',imageposition);
    set(gca,'Clim',[-0.1 maxpixelvalue_2]);
    %imageposition=imageposition+[128 0 0 0];
    saveas(h7,[dir,'\figure7.bmp'],'bmp');
    %Image8 Detection7
    h8=figure(8);
    set(h8, 'Visible',visibletag);
    imshow(image8,'border','tight','initialmagnification','fit');
    set (h8,'Position',imageposition);
    set(gca,'Clim',[-0.1 maxpixelvalue_2]);
    %imageposition=imageposition+[128 0 0 0];
    saveas(h8,[dir,'\figure8.bmp'],'bmp');
    %Image9 Detection8
    h9=figure(9);
    set(h9, 'Visible',visibletag);
    imshow(image9,'border','tight','initialmagnification','fit');
    set (h9,'Position',imageposition);
    set(gca,'Clim',[-0.1 maxpixelvalue_2]);
    %imageposition=imageposition+[128 0 0 0];
    saveas(h9,[dir,'\figure9.bmp'],'bmp');
    %Image10 Light
    h10=figure(10);
    set(h10, 'Visible',visibletag);
    imshow(image10,'border','tight','initialmagnification','fit');
    set (h10,'Position',imageposition);
    set(gca,'Clim',[-0.1 maxpixelvalue_2]);
    %imageposition=imageposition+[128 0 0 0];
    saveas(h10,[dir,'\figure10.bmp'],'bmp');
    %Image11 Bg
    h11=figure(11);
    set(h11, 'Visible',visibletag);
    imshow(image11,'border','tight','initialmagnification','fit');
    set (h11,'Position',imageposition);
    set(gca,'Clim',[-0.1 maxpixelvalue_2]);
    %imageposition=imageposition+[128 0 0 0];
    saveas(h11,[dir,'\figure11.bmp'],'bmp');
%Data Processing
%Normalization
        [OD_normal,noise_OD_normal,SNRGain_normal,x111,x222,y111,y222,count_normal]=Optical_Density(dir,1,photo30,precession,0,0,sumarea_1(3),sumarea_1(4),sumarea_1(1),sumarea_1(2));
        %Image12 OD Normalization
        h12=figure(12);
        set(h12, 'Visible',visibletag);
        imshow(OD_normal,'border','tight','initialmagnification','fit');
        colormap jet;
        set(gca,'Clim',[-0.1 scale]);
        saveas(h12,[dir,'\OD_normal.fig'])
        set(h12,'Position',imageposition);
        %imageposition=imageposition+[128 0 0 0];
        saveas(h12,[dir,'\figure12.bmp'],'bmp');
        %Detection1
        [OD_detection_1,noise_OD_detection_1,SNRGain_detection_1,x111,x222,y111,y222,count_detection_1]=Optical_Density(dir,2,photo30,precession,0,0,x111,x222,y111,y222);
        %Detection2
        [OD_detection_2,noise_OD_detection_2,SNRGain_detection_2,x111,x222,y111,y222,count_detection_2]=Optical_Density(dir,3,photo30,precession,0,0,x111,x222,y111,y222);
        %Detection3
        [OD_detection_3,noise_OD_detection_3,SNRGain_detection_3,x111,x222,y111,y222,count_detection_3]=Optical_Density(dir,4,photo30,precession,0,0,x111,x222,y111,y222);
        %Detection4
        [OD_detection_4,noise_OD_detection_4,SNRGain_detection_4,x111,x222,y111,y222,count_detection_4]=Optical_Density(dir,5,photo30,precession,0,0,x111,x222,y111,y222);
        %Detection5
        [OD_detection_5,noise_OD_detection_5,SNRGain_detection_5,x111,x222,y111,y222,count_detection_5]=Optical_Density(dir,6,photo30,precession,0,0,x111,x222,y111,y222);
        %Detection6
        [OD_detection_6,noise_OD_detection_6,SNRGain_detection_6,x111,x222,y111,y222,count_detection_6]=Optical_Density(dir,7,photo30,precession,0,0,x111,x222,y111,y222);
        %Detection7
        [OD_detection_7,noise_OD_detection_7,SNRGain_detection_7,x111,x222,y111,y222,count_detection_7]=Optical_Density(dir,8,photo30,precession,0,0,x111,x222,y111,y222);
        %Detection8
        [OD_detection_8,noise_OD_detection_8,SNRGain_detection_8,x111,x222,y111,y222,count_detection_8]=Optical_Density(dir,9,photo30,precession,0,0,x111,x222,y111,y222);
        count_bg=1;

    if Fit2D==1
        [App,cxpp,cypp,sxpp,sypp,sitapp,offsetpp,image_Fit]=Gauss2DFit(OD_normal,1);
        set(gcf,'Position',imageposition);
        set(gca,'Clim',[-0.1 scale]);
        saveas(image_Fit,[dir,'\OD_2D_fit.bmp'],'bmp');
        r=((sxpp^2+sypp^2)/2)^(1/2)*(5.3/1000000)*1000;
        %NumberofAtoms=App*2*pi*(sxpp*sypp)*(5.3/1000000).^2/(76)*10.^(15);
        NumberofAtoms=App*2*pi*(sxpp*sypp)*(6.5/1000000).^2/(76)*10.^(15);
        OD_max=App;
    else
        r=0;
        NumberofAtoms=0;
        OD_max=max(max(OD_detection_1));
    end
    OD_max_normal=max(max(OD_normal));
    %Image13 OD Detection1
    h13=figure(13);
    set(h13, 'Visible',visibletag);
    imshow(OD_detection_1,'border','tight','initialmagnification','fit');
    colormap jet;
    set(gca,'Clim',[-0.1 scale]);
    saveas(h13,[dir,'\OD_detect_1.fig']);
    set(h13,'Position',imageposition);
    %imageposition=imageposition+[128 0 0 0];
    saveas(h13,[dir,'\figure13.bmp'],'bmp');    
    
    %Image14 OD Detection2
    h14=figure(14);
    set(h14, 'Visible',visibletag);
    imshow(OD_detection_2,'border','tight','initialmagnification','fit');
    colormap jet;
    set(gca,'Clim',[-0.1 scale]);
    saveas(h14,[dir,'\OD_detect_2.fig']);
    set(h14,'Position',imageposition);
    %imageposition=imageposition+[128 0 0 0];
    saveas(h14,[dir,'\figure14.bmp'],'bmp');
    %Image15 OD Detection3
    h15=figure(15);
    set(h15, 'Visible',visibletag);
    imshow(OD_detection_3,'border','tight','initialmagnification','fit');
    colormap jet;
    set(gca,'Clim',[-0.1 scale]);
    saveas(h15,[dir,'\OD_detect_3.fig']);
    set(h15,'Position',imageposition);
    %imageposition=imageposition+[128 0 0 0];
    saveas(h15,[dir,'\figure15.bmp'],'bmp');
    %Image16 OD Detection4
    h16=figure(16);
    set(h16, 'Visible',visibletag);
    imshow(OD_detection_4,'border','tight','initialmagnification','fit');
    colormap jet;
    set(gca,'Clim',[-0.1 scale]);
    saveas(h16,[dir,'\OD_detect_4.fig']);
    set(h16,'Position',imageposition);
    %imageposition=imageposition+[128 0 0 0];
    saveas(h16,[dir,'\figure16.bmp'],'bmp');
    %Image17 OD Detection5
    h17=figure(17);
    set(h17, 'Visible',visibletag);
    imshow(OD_detection_5,'border','tight','initialmagnification','fit');
    colormap jet;
    set(gca,'Clim',[-0.1 scale]);
    saveas(h17,[dir,'\OD_detect_5.fig']);
    set(h17,'Position',imageposition);
    %imageposition=imageposition+[128 0 0 0];
    saveas(h17,[dir,'\figure17.bmp'],'bmp');
    %Image18 OD Detection6
    h18=figure(18);
    set(h18, 'Visible',visibletag);
    imshow(OD_detection_6,'border','tight','initialmagnification','fit');
    colormap jet;
    set(gca,'Clim',[-0.1 scale]);
    saveas(h18,[dir,'\OD_detect_6.fig']);
    set(h18,'Position',imageposition);
    %imageposition=imageposition+[128 0 0 0];
    saveas(h18,[dir,'\figure18.bmp'],'bmp');
    %Image19 OD Detection7
    h19=figure(19);
    set(h19, 'Visible',visibletag);
    imshow(OD_detection_7,'border','tight','initialmagnification','fit');
    colormap jet;
    set(gca,'Clim',[-0.1 scale]);
    saveas(h19,[dir,'\OD_detect_7.fig']);
    set(h19,'Position',imageposition);
    %imageposition=imageposition+[128 0 0 0];
    saveas(h19,[dir,'\figure19.bmp'],'bmp');
    %Image20 OD Detection8
    h20=figure(20);
    set(h20, 'Visible',visibletag);
    imshow(OD_detection_8,'border','tight','initialmagnification','fit');
    colormap jet;
    set(gca,'Clim',[-0.1 scale]);
    saveas(h20,[dir,'\OD_detect_8.fig']);
    set(h20,'Position',imageposition);
    %imageposition=imageposition+[128 0 0 0];
    saveas(h20,[dir,'\figure20.bmp'],'bmp');
    
% Sum Value
    %Sum value
    sumvalue_normal=sum(sum(OD_normal(sumarea_1(1):sumarea_1(2),sumarea_1(3):sumarea_1(4))));
    sumvalue_1=sum(sum(OD_detection_1(sumarea_1(1):sumarea_1(2),sumarea_1(3):sumarea_1(4))));
    sumvalue_2=sum(sum(OD_detection_2(sumarea_1(1):sumarea_1(2),sumarea_1(3):sumarea_1(4))));
    sumvalue_3=sum(sum(OD_detection_3(sumarea_1(1):sumarea_1(2),sumarea_1(3):sumarea_1(4))));
    sumvalue_4=sum(sum(OD_detection_4(sumarea_1(1):sumarea_1(2),sumarea_1(3):sumarea_1(4))));
    sumvalue_5=sum(sum(OD_detection_5(sumarea_1(1):sumarea_1(2),sumarea_1(3):sumarea_1(4))));
    sumvalue_6=sum(sum(OD_detection_6(sumarea_1(1):sumarea_1(2),sumarea_1(3):sumarea_1(4))));
    sumvalue_7=sum(sum(OD_detection_7(sumarea_1(1):sumarea_1(2),sumarea_1(3):sumarea_1(4))));
    sumvalue_8=sum(sum(OD_detection_8(sumarea_1(1):sumarea_1(2),sumarea_1(3):sumarea_1(4))));
    
        %ROI OD_detection_1
        h21=figure(21);
        set(h21, 'Visible',visibletag);
        imshow(OD_detection_1,'border','tight','initialmagnification','fit');
        rectangle('Position',[sumarea_1(3) sumarea_1(1) sumarea_1(4)-sumarea_1(3) sumarea_1(2)-sumarea_1(1)],'EdgeColor','r','LineWidth',1)
        colormap jet;
        set(gca,'Clim',[-0.1 scale]);
        set(h21,'Position',imageposition);
        %imageposition=imageposition+[128 0 0 0];
        saveas(h21,[dir,'\figure21.bmp'],'bmp');
    
        
    phase=sumvalue_1/sumvalue_normal;
    phasediff=(sumvalue_1-sumvalue_2)/(sumvalue_1+sumvalue_2);
    
    %SNR
    area=(sumarea_1(4)-sumarea_1(3)+1)*(sumarea_1(2)-sumarea_1(1)+1);
    SNR_normal=sumvalue_normal/sqrt(area)/noise_OD_normal;
    SNR_detection=sumvalue_2/sqrt(area)/noise_OD_detection_2;
    
    %ROI OD_detection_2
    h22=figure(22);
    set(h22, 'Visible',visibletag);
    imshow(OD_detection_2,'border','tight','initialmagnification','fit');
    rectangle('Position',[sumarea_1(3) sumarea_1(1) sumarea_1(4)-sumarea_1(3) sumarea_1(2)-sumarea_1(1)],'EdgeColor','r','LineWidth',1)
    colormap jet;
    set(gca,'Clim',[-0.1 scale]);
    set(h22,'Position',imageposition);
    %imageposition=imageposition+[128 0 0 0];
    saveas(h22,[dir,'\figure22.bmp'],'bmp');
    dataprocessingtime=toc;
%     %save([dir,'\result.mat'],'dir','count_normal','count_detection_1','count_detection_2',...
%         'sumarea','sumvalue_normal','sumvalue_1','sumvalue_2','phase','phasediff',...
%         'noise_OD_normal','SNRGain_normal','noise_OD_detection_1','SNRGain_detection_1',...
%         'noise_OD_detection_2','SNRGain_detection_2','OD_normal','OD_detection_1','OD_detection_2',...
%         'OD_max','')
    save ([dir,'\result.mat'])
    
    outputlist=[dataprocessingtime,r*1000,NumberofAtoms,OD_max, OD_max_normal,SNR_normal,SNR_detection,...
        sumvalue_normal,sumvalue_1,sumvalue_2,phase,phasediff,noise_OD_normal,SNRGain_normal,...
        noise_OD_detection_1,SNRGain_detection_1,noise_OD_detection_2,SNRGain_detection_2,...
        count_normal,count_detection_1,count_detection_2,count_detection_3,count_detection_4,...
        count_detection_5,count_detection_6,count_detection_7,count_detection_8,noise_OD_detection_3,...
        noise_OD_detection_4,noise_OD_detection_5,noise_OD_detection_6,noise_OD_detection_7,noise_OD_detection_8,...
        sumvalue_3,sumvalue_4,sumvalue_5,sumvalue_6,sumvalue_7,sumvalue_8];    
close all
toc