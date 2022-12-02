clear all; 
clc; 
echo off;

%璁惧畾鏃堕棿鐐筃
N=50;

%鏍规嵁R鍜孮锛屼豢鐪烴涓祴閲忔暟鎹�
randn('state',0)
x0=-0.37727;
R=0.01;
Q=0.00001;
for i=1 :N
    w(i)=sqrt(Q)*randn;
    x(i)=x0+w(i);
    %x(i)=x(i-1);
    v(i)=sqrt(R)*randn;
    z(i)=x(i)+v(i);
end

%杩愮敤kalman婊ゆ尝杩涜鐘舵€佷及璁�
Q=0.00001
R=0.01
P(1)=1;
x_e(1)=-0.37727;
for j=2:N
    x_e_t(j)=x_e(j-1);
    P_e(j)=P(j-1)+Q;
    K(j)=P_e(j)/(P_e(j)+R);
    x_e(j)=x_e_t(j)+K(j)*(z(j)-x_e_t(j));
    P(j)=(1-K(j))*P_e(j);
end
for j=1:N
    yy(j)=-0.37727;
end

%鐢诲嚭鐘舵€佷及璁＄浉瀵逛簬N涓椂闂寸偣鐨勫搴斿浘锛屽垽鏂槸鍚︽湁鏁堟敹鏁�
num=linspace(1,N,N);
plot(num,z,'+',num,x_e,'-',num,yy,'-');




    