
function Code4EveryPulse(i)
%% 以下分别是四个端口收到Pulse所执行的代码
global imagenumber;

global totalswitch;

global dataprocess;

if i == 1 % Ctr0 的功能，目前设定Ctr0是用作移动照片到目标文件夹的
    
    imagenumber=1;
    dataprocess=1;%这个变量是用来告诉相机软件可以开始进行数据处理了了
elseif i == 2 % Ctr1 的功能,用来告诉相机开始工作
    totalswitch=1;
    %disp("Ctr1端口触发了");
elseif i == 3 % Ctr2 的功能
    %disp("Ctr2端口触发了");

elseif i == 4 % Ctr3 的功能
    %disp("Ctr3端口触发了");
end
end
