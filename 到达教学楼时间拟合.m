clear;clc;close all
format compact
%正态分布的拟合
num = 16;
filename='time.xlsx'; %读取文件地址
% x=xlsread(filename,"Sheet1",'c2:c17'); %参数依次是：文件，sheet名称，读取的范围
% y=xlsread(filename,"Sheet1","d2:d17");
x=xlsread(filename,"Sheet1",'a2:a52'); %参数依次是：文件，sheet名称，读取的范围
y=xlsread(filename,"Sheet1","b2:b52");
xx = x(:);
yy = y(:);
bar(xx,yy)
example_mean = mean(xx);%样本均值
example_std = std(xx);%标准差
% Set up fittype and options.
[fitresult, gof] = fit( xx, yy,'gauss1' );%直接调用 高斯函数模型
fitresult;
% Plot fit with data.
figure;
plot(fitresult)
hold on
plot(xx, yy,'b*');
legend('拟合曲线','原始数据', 'Location', 'NorthEast');
title(['正态分布拟合,num=',num2str(num)])
xlabel('x');
ylabel('y');
grid on
saveas(gcf,'pic.png')
% 输出拟合参数
a = fitresult.a1;
wa = fitresult.b1;
xc = fitresult.c1;

alpha = 0.05;
[mu,sigma]=normfit(xx);%求正态分布的参数值
p1=normcdf(xx,mu,sigma);%cdf检验
[H1,S1]=kstest(xx,[xx,p1],alpha);%检验是否符合置信区间为95%的正态分布
if H1 == 0
   disp("服从正态分布");
else
   disp("不服从");
end
