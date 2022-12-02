clear all;
clc;
%% 参数设置
N = 50;
Fs = 500;
Ts = 1/Fs;
Rs = 50;
USR = Fs/Rs;
RollOff = 0.25;
Span = 6;
Sps = USR;
SNR = 1;
%%
%%发射端
sys0 = rand(1,N);
sys = round(sys0);
sys_2pam = (sys-0.5)*2;
figure;
subplot(2,1,1);
stem(sys);
legend("原始符号序列");
subplot(2,1,2);
stem(sys_2pam);
legend("2-pam调制后的结果");
%升采样,等效于0插值
upsmp = zeros(1,N*USR);
upsmp(1:USR:end) = sys_2pam;
%脉冲成形
h1 = rcosdesign(RollOff,Span,Sps,'sqrt');
rcos_2pam =conv(h1,upsmp);
inpulse1 = rcos_2pam;
rcos_spc = abs(fftshift(fft(inpulse1)));
figure;
subplot(2,1,1);
plot(rcos_2pam);
legend("升余弦滚降脉冲成形");
subplot(2,1,2);
plot(rcos_spc);
legend("升余弦滚降脉冲成形频谱");
%%信号通过加性噪声信道
%计算信号发送功率
Sig_power = mean(sys_2pam.^2);
recv = awgn(inpulse1,SNR,Sig_power);
recv_spc = abs(fftshift(fft(recv)));
figure
subplot(2,1,1)
plot(recv);legend('信号通过AWGN信道')
subplot(2,1,2)
plot(recv_spc);legend('信号通过AWGN信道频谱')

%匹配滤波
H = h1;
%H=h1;
recv_MF =conv(H,recv);
recv_MF_spc = abs(fftshift(fft(recv_MF)));
figure
subplot(2,1,1)
plot(recv_MF)
legend('匹配滤波输出')
subplot(2,1,2)
plot(recv_MF_spc)
legend('匹配滤波输出频谱')

% %抽样判决
delay = Sps*Span;
recv_sample = recv_MF(delay:USR:end);
[index,recv_quant]= quantiz(recv_sample(1:N),[0],[-1 1]);%量化
% %2-pam解调
sys_demod = recv_quant/2 + 0.5;
figure;
subplot(3,1,1);
stem(recv_sample);
legend("抽样后的结果");
subplot(3,1,2);
stem(recv_quant);
legend("量化后的结果");
subplot(3,1,3);
stem(sys_demod);
legend("2-pam解调的结果");
[number,ratio] = biterr(sys,sys_demod);
display(ratio)
