function [OD,noise_OD,SNRGain,x1,x2,y1,y2,countperpixel]=Optical_Density(dir,ODnumber,atomphoto,lightphoto,x11,x22,y11,y22)


    [x1,x2,y1,y2]=deal(x11,x22,y11,y22);
    image1=imread([dir,'\',num2str(ODnumber),'.tif']);
    image2=imread([dir,'\',num2str(atomphoto+1),'.tif']);
    image3=imread([dir,'\',num2str(atomphoto+lightphoto+1),'.tif']);
    image1=image1(:,:,1)-image3(:,:,1);
    image2=image2(:,:,1)-image3(:,:,1);
    countperpixel=mean(mean(image2(y11:y22,x11:x22)));
    
    image1=im2double(image1);
    image2=im2double(image2);
    OD=log(image2./image1);
    OD(isnan(OD))=0;
    OD(isinf(OD))=0;
    [M,N]=size(OD);
    
   
    
    noise_OD=sqrt(sum(sum((OD).^2)))/(M*N);
    SNRGain=1;
    
end