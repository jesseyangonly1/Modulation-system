clear all;
clc;
%% ��������
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
%%�����
sys0 = rand(1,N);
sys = round(sys0);
sys_2pam = (sys-0.5)*2;
figure;
subplot(2,1,1);
stem(sys);
legend("ԭʼ��������");
subplot(2,1,2);
stem(sys_2pam);
legend("2-pam���ƺ�Ľ��");
%������,��Ч��0��ֵ
upsmp = zeros(1,N*USR);
upsmp(1:USR:end) = sys_2pam;
%�������
h1 = rcosdesign(RollOff,Span,Sps,'sqrt');
rcos_2pam =conv(h1,upsmp);
inpulse1 = rcos_2pam;
rcos_spc = abs(fftshift(fft(inpulse1)));
figure;
subplot(2,1,1);
plot(rcos_2pam);
legend("�����ҹ����������");
subplot(2,1,2);
plot(rcos_spc);
legend("�����ҹ����������Ƶ��");
%%�ź�ͨ�����������ŵ�
%�����źŷ��͹���
Sig_power = mean(sys_2pam.^2);
recv = awgn(inpulse1,SNR,Sig_power);
recv_spc = abs(fftshift(fft(recv)));
figure
subplot(2,1,1)
plot(recv);legend('�ź�ͨ��AWGN�ŵ�')
subplot(2,1,2)
plot(recv_spc);legend('�ź�ͨ��AWGN�ŵ�Ƶ��')

%ƥ���˲�
H = h1;
%H=h1;
recv_MF =conv(H,recv);
recv_MF_spc = abs(fftshift(fft(recv_MF)));
figure
subplot(2,1,1)
plot(recv_MF)
legend('ƥ���˲����')
subplot(2,1,2)
plot(recv_MF_spc)
legend('ƥ���˲����Ƶ��')

% %�����о�
delay = Sps*Span;
recv_sample = recv_MF(delay:USR:end);
[index,recv_quant]= quantiz(recv_sample(1:N),[0],[-1 1]);%����
% %2-pam���
sys_demod = recv_quant/2 + 0.5;
figure;
subplot(3,1,1);
stem(recv_sample);
legend("������Ľ��");
subplot(3,1,2);
stem(recv_quant);
legend("������Ľ��");
subplot(3,1,3);
stem(sys_demod);
legend("2-pam����Ľ��");
[number,ratio] = biterr(sys,sys_demod);
display(ratio)
