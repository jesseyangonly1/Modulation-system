clc;
clear all;
%%
SNR = 1;  
NT=50;
N=2*zero*NT;
fs=25e6;
rf=0.1;
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
%��������תΪ˫������
IMAGE = 2*(double(image)-0.5);
%%
fc=5e6;
%����������ż��λ�ֿ��������ֱ���ص������ز���
I = [];
Q = [];
for i = 1:M
    if mod(i,2)~=0
        I((i+1)/2) = IMAGE(i);
    else
        Q(i/2) = IMAGE(i);
    end
end
%%
%�ϲ�����0��ֵ��
zero=5;         %�ϲ�����
for  i=1:zero*M/2     
    if rem(i,zero)==1
        Izero(i)=I(fix((i-1)/zero)+1);
        Qzero(i)=Q(fix((i-1)/zero)+1);
    else
        Izero(i)=0;
        Qzero(i)=0;
    end
end
%�������
psf=rcosfir(rf,NT,zero,fs,'sqrt');
Ipulse=conv(Izero,psf);
Qpulse=conv(Qzero,psf);

%%
%modulation����
for i=1:zero*M/2+N   
    t(i)=(i-1)/(fs);  
    Imod(i)=Ipulse(i)*sqrt(2)*cos(2*pi*fc*t(i));
    Qmod(i)=Qpulse(i)*(-sqrt(2)*sin(2*pi*fc*t(i)));
end
sum=Imod+Qmod;
%%
%�����źŷ��͹���
Sig_power = mean(IMAGE.^2);
%AWGN�ŵ�����
recv = awgn(sum,SNR,Sig_power);
%%
%QPSK  receiver
%���
for i=1:zero*M/2+N
    Idem(i)=recv(i)*sqrt(2)*cos(2*pi*fc*t(i));
    Qdem(i)=recv(i)*(-sqrt(2)*sin(2*pi*fc*t(i)));
end
%%
%ƥ���˲�
mtf=rcosfir(rf,NT,zero,fs,'sqrt');
Imat=conv(Idem,mtf);
Qmat=conv(Qdem,mtf);

for  i=1:zero*M/2
    Isel(i)=Imat(i+N);
    Qsel(i)=Qmat(i+N);
end
%%
%����
for i=1:M/2
    Isamp(i)=Isel((i-1)*zero+1);
    Qsamp(i)=Qsel((i-1)*zero+1);
end
%�о�
threshold=0;
for  i=1:M/2
    if Isamp(i)>=threshold
        Iout(i)=1;
    else
        Iout(i)=-1;
    end
    if Qsamp(i)>=threshold
        Qout(i)=1;
    else
        Qout(i)=-1;
    end
end
%%
%�����任
for i = 1:M
    if mod(i,2)~=0
        output(i) = Iout((i+1)/2);
    else
        output(i) = Qout(i/2);
    end
end  
%%
%ͼƬ�ָ�
img_recover = uint8(output);
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
title('QPSK���ƽ���ͼ��')
%����������
[number,ratio] = biterr(image,img_recover);
display(ratio)
  