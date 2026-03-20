image1=double(random('Poisson',12515,100,100));
image2=double(random('Poisson',12515,100,100));
mean(mean(image1))
mean(mean(image2))
OD_noise=log(image1./image2);
sqrt(sum(sum(OD_noise.^2))/10000)