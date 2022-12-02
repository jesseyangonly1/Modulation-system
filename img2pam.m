clear all;
%%
%����׼���׶�
%ͼ�����
benben = imread('benben.jpg');
%ͼ���ͨ��
red = benben(:,:,1);
green = benben(:,:,2);
blue = benben(:,:,3);
%�ֱ���ȡRGB��ͨ������
r = red(:);
g = green(:);
b = blue(:);
%����ֵʮ����ת������
R = de2bi(r);
G = de2bi(g);
B = de2bi(b);
[n,m] = size(R);

%��ά����תһά
R1 = reshape(R,1,m*n);
G1 = reshape(G,1,m*n);
B1 = reshape(B,1,m*n);
image = [R1,G1,B1];
[N,M] = size(image);
%%
%����
% ��������
Fs = 500;
Ts = 1/Fs;
Rs = 50;
USR = Fs/Rs;
RollOff = 0.25;
Span = 6;
Sps = USR;
SNR = 10;
%%
%%�����
sys_2pam = 2*(double(image)-0.5);
%������,��Ч��0��ֵ
upsmp = zeros(1,M*USR);
upsmp(1:USR:end) = sys_2pam;
%������Σ�rcosdesign���������壩
h1 = rcosdesign(RollOff,Span,Sps,'sqrt');
rcos_2pam =conv(h1,upsmp);
inpulse = rcos_2pam;
%%
%�����źŷ��͹���
Sig_power = mean(sys_2pam.^2);
%AWGN�ŵ�����
recv = awgn(inpulse,SNR,Sig_power);
%%
%ƥ���˲�
H = rcosdesign(RollOff,Span,Sps,'sqrt');
%H=h1;
recv_MF =conv(H,recv);
%����
delay = Sps*Span;
recv_sample = recv_MF(delay:USR:end);
%����
[index,recv_quant]= quantiz(recv_sample(1:M),[0],[-1 1]);%����
%4-pam���
image_demod = recv_quant/2 + 0.5;
%%
%�ָ�
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
title('ԭͼ��')
subplot(1,2,2)
imshow(benben2)
title('2-PAM���ƽ���ͼ��')
%����������
[number,ratio] = biterr(image,img_recover);
display(ratio)
