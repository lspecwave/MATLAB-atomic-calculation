initial=1;
for i=450:489
    source=['E:\Data\2021-11-29\Abs-',num2str(i),'\2.tif'];
    destination='E:\Data\2021-11-29\Background\';
    copyfile(source,'E:\Data');
    movefile(['E:\Data','\2.tif'],[destination,num2str(initial),'.tif']);
    initial=initial+1;
end