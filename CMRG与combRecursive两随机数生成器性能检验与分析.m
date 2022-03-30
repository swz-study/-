clear;clc;close all
randomNumber = 3000; %100000
%函数参数
a1 = 1403580;a2 = 810728;a3 = 2.^32-209;
b1 = 527612;b2 = 1370589;b3 = 2.^32-22853;
z(1,1) = round(rand*1000000);z(1,2) = round(rand*1000000);z1(1,3) = round(rand*1000000);
z(2,1) = round(rand*1000000);z(2,2) = round(rand*1000000);z(2,3) = round(rand*1000000);

n = 1;
switch n
    case 1
        timeBegin = clock;
        for i=4:randomNumber+3
            z(1,i)=mod(a1*z(1,i-2)-a2*z(1,i-3),a3);
            z(2,i)=mod(b1*z(2,i-1)-b2*z(2,i-3),b3);
            y(i)=mod(z(1,i)-z(2,i),a3);%i-3
            U(i-3)=y(i)/a3;
        end
        timeEnd=clock;
        spendTime=etime(timeEnd,timeBegin)
    case 2
        timeBegin=clock;
        rng('shuffle','combRecursive');
        U = rand(1,randomNumber);
        timeend=clock;
        t_rng=etime(timeend,timeBegin)
end
%画图
plot(U,'.')
figure
histogram(U,10)
figure


%*************************相关性检验***************************************
n = randomNumber/3;
for i=1:n
    X(i)=U((i-1)*3+1);
    Y(i)=U((i-1)*3+2);
    Z(i)=U((i-1)*3+3);
end

k=ceil(n.^(1/3));
Hist=zeros(k,k,k);
for i=1:n
%     x1(i)
%     x2(i)
    j1=ceil(X(i)*k);
    j2=ceil(Y(i)*k);
    j3=ceil(Z(i)*k);
    Hist(j1,j2,j3)=Hist(j1,j2,j3)+1;
end
%n=n/3;
for i=1:10
    for j=1:10
        for m=1:10
            h(i,j,m)=((Hist(i,j,m)-n/(k^3)).^2);
        end
    end
end

kf_s=sum(sum(sum(h))).*(k^3)/n;
kf = chi2inv(0.95,k^3-1);

if kf_s<kf
    chi2_str1 = '相关性检验通过'
else
    chi2_str1 = '相关性检验不通过'
end

%*********************************均匀性检验*******************************
k=10; %k个等长区间
n=randomNumber;
n1=hist(U,10);%统计计算在每个子区间上的随机数的个数
kf_s = (sum((n1-n/10).^2))*(k/n);  % 第五步
kf = chi2inv(0.95,k-1);%    卡方分布逆累积分布函数
if kf_s<kf
    chi2_str1 ='卡方检验通过'
else%拒绝H0,即不通过
    chi2_str1 ='卡方检验不通过'
end

%********************************序列检验**********************************
for i=1:1:length(U)/2
   x1(i)=U((i-1)*2+1);
   x2(i)=U((i-1)*2+2);
end

k=100;
Hist=zeros(k);
for i=1:length(x1)
    j1=ceil(x1(i)*k);
    j2=ceil(x2(i)*k);
    Hist(j1,j2)=Hist(j1,j2)+1;
end
bar3(Hist)
n=randomNumber;
for i=1:k
    for j=1:k
        h(i,j)=((Hist(i,j)-(n/2)/(k^2)).^2);
    end
end
kf_s = sum(sum(h)).*(k^2)/(n/2);
kf = chi2inv(0.95,k^2-1);

if kf_s<kf
    chi2_str1 = '序列检验通过'
else
    chi2_str1 = '序列检验不通过'
end

%*********************************游程检验*********************************
a_ij=[4529.4	9044.9	13568	18091	22615	27892
9044.9	18097	27139	36187	45234	55789
13568	27139	40721	54281	67852	83685
18091	36187	54281	72414	90470	111580
22615	45234	67852	90470	113262	139476
27892	55789	83685	111580	139476	172860];

b_i=[1/6,5/24,11/120,19/720,29/5040,1/840];
w=[1,2,3,4,5,6];
n=randomNumber;
x=U;
flag=0;
r_ij=zeros(1,6);
temp=1;
for i=1:length(x)-1
    if x(i+1)>x(i)
        temp=temp+1;
    else
        if temp<6
            r_ij(temp) = r_ij(temp) + 1;
        else
            r_ij(6) = r_ij(6) + 1;
        end
        temp=1;
    end
end
sum(r_ij.*w);

for i=1:6
    for j=1:6
        s(i,j)=a_ij(i,j)*(r_ij(i)-n*b_i(i))*(r_ij(j)-n*b_i(j));
    end
end

kf=sum(sum(s))/n;

chi2_p=chi2cdf(6,kf);  

if chi2_p<0.95
    chi2_str1='游程检验通过'
else
    chi2_str1='游程检验不通过'
end

