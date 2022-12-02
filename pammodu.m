%2-PAM调制
clear;
clear all;clc;
N=10;
T=1;
fc=20;
Fs=1000;
msg=[0 1 1 1 0 1 0 0 1 1];
msg=2*(msg-0.5);%转换为双极性码

%脉冲成形
bit_data=[];
for i=1:N
    bit_data=[bit_data,msg(i)*ones(1,T*Fs)];
end

%载波信号
bit_t=0:1/Fs:T-1/Fs;
%传输信号
trans = [];
for i=1:N
    trans=[trans,bit_data(i)*cos(2*pi*fc*bit_t)];%I路载波信号    
end

%频谱
bit_spc = abs(fftshift((fft(trans))));
%绘图
snr=1;%信躁比
%经过加性高斯白噪声信道
recv_msg = awgn(trans,snr);
recv_spc = abs(fftshift(fft(recv_msg)));
%绘图
figure();
%时间轴

title('时域信号波形')
subplot(3,1,1)
plot(t,bit_data,'r');legend('脉冲成形方波信号')%比特信息
subplot(3,1,2)
plot(t,trans,'b');legend('载波调制信号')%方波信号
title('调制信号波形')
subplot(3,1,3)
plot((0:length(trans)-1)*Fs/length(trans)-Fs/2,bit_spc,'b');legend('调制信号频谱')%调制信号

figure();
subplot(2,1,1)
plot(t,recv_msg);legend('信号通过AWGN信道')
subplot(2,1,2)
plot((0:length(recv_msg)-1)*Fs/length(recv_msg)-Fs/2,recv_spc);
legend('信号通过AWGN信道频谱')

