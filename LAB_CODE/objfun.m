function S=objfun(p,X,Y,Z)
%% 高斯分布有转动时的误差函数
%A=p(1)
%cx=p(2)
%cy=p(3)
%sx=p(4)
%sy=p(5)
%sita=p(6)
%offset=p(7)
S=sum(sum((p(1)*exp(-0.5/p(4)^2*(cos(p(6))*(X-p(2))+sin(p(6))*(Y-p(3))).^2-0.5/p(5)^2*(-sin(p(6))*(X-p(2))+cos(p(6))*(Y-p(3))).^2)+p(7)-Z).^2));

