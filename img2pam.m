clear all;
%%
%数据准备阶段
%图像编码
benben = imread('benben.jpg');
%图像分通道
red = benben(:,:,1);
green = benben(:,:,2);
blue = benben(:,:,3);
%分别提取RGB三通道数据
r = red(:);
g = green(:);
b = blue(:);
%像素值十进制转二进制
R = de2bi(r);
G = de2bi(g);
B = de2bi(b);
[n,m] = size(R);

%多维数组转一维
R1 = reshape(R,1,m*n);
G1 = reshape(G,1,m*n);
B1 = reshape(B,1,m*n);
image = [R1,G1,B1];
[N,M] = size(image);
%%
%调制
% 参数设置
Fs = 500;
Ts = 1/Fs;
Rs = 50;
USR = Fs/Rs;
RollOff = 0.25;
Span = 6;
Sps = USR;
SNR = 10;
%%
%%发射端
sys_2pam = 2*(double(image)-0.5);
%升采样,等效于0插值
upsmp = zeros(1,M*USR);
upsmp(1:USR:end) = sys_2pam;
%脉冲成形（rcosdesign升余弦脉冲）
h1 = rcosdesign(RollOff,Span,Sps,'sqrt');
rcos_2pam =conv(h1,upsmp);
inpulse = rcos_2pam;
%%
%计算信号发送功率
Sig_power = mean(sys_2pam.^2);
%AWGN信道传输
recv = awgn(inpulse,SNR,Sig_power);
%%
%匹配滤波
H = rcosdesign(RollOff,Span,Sps,'sqrt');
%H=h1;
recv_MF =conv(H,recv);
%抽样
delay = Sps*Span;
recv_sample = recv_MF(delay:USR:end);
%量化
[index,recv_quant]= quantiz(recv_sample(1:M),[0],[-1 1]);%量化
%4-pam解调
image_demod = recv_quant/2 + 0.5;
%%
%恢复
img_recover = uint8(image_demod);
R2 = reshape(img_recover(1:m*n),n,m);
G2 = reshape(img_recover(m*n+1:2*m*n),n,m);
B2 = reshape(img_recover(2*m*n+1:3*m*n),n,m);
r2 = bi2de(R2);
g2 = bi2de(G2);
b2 = bi2de(B2);
r3 = reshape(r2,540,540);
g3 = reshape(g2,540,540);
b3 = reshape(b2,540,540);
benben2(:,:,1) = r3;
benben2(:,:,2) = g3;
benben2(:,:,3) = b3;
subplot(1,2,1)
imshow(benben)
title('原图像')
subplot(1,2,2)
imshow(benben2)
title('2-PAM调制接收图像')
%计算误码率
[number,ratio] = biterr(image,img_recover);
display(ratio)
