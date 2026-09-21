%Filtro Passa Altas
clear all
close all
clc

Fs = 500; %Frequência de Amostragem
Wp = 400; %Frequência limite da Banda de Passagem (analógica)
Wr = 100; %Frequência limite da Banda de rejeição (analógica)

% Atenuações
Amax= 0.5;
Amin= 40;

%Calculo de E
E = sqrt(10^(0.1*Amax)-1);

% Digitalização das Frequências Analógicas
Ts = 1 / (Fs);
wp = Ts * Wp;
wr = Ts * Wr;

% Pré-distorção das Frequências
Wap = 2*Fs*tan(wp/2);
War = 2*Fs*tan(wr/2);

% Cálculo da Ordem e da frequência de 3 dB
[n,wc_n] = cheb1ord(Wap,War,Amax,Amin,'s');
wo = wc_n; %Determinaçao do filtro normalizado

% Determina numerador e denominador da H(s) do filtro analógico
[z,p,k]=cheb1ap(n,Amax);
b = poly(z)*k;
a = poly(p);

%Transformaçao do filtro
[bt,at]=lp2hp(b,a,wo);

%Transformaçao Bilinear
[NUM,DEN] = bilinear(bt,at,Fs);

% Determina H(z)
h = tf(NUM, DEN, -1, 'variable','z^-1')

%Plotar Resposta em Frequencia da H(z) obtida pela Transformação Bilinear
w = 0:pi/100000:pi;
H = freqz(NUM,DEN,w);
% figure
% plot(w,20*log10(abs(H)))
% grid on
% xlabel('Frequência (rad/s)')
% ylabel('Módulo')
% title('{\bf Resposta em Frequência do Filtro Passa Altas}')

%Plotar módulo e fase
freqz(NUM,DEN)

%Plotar atraso de grupo
figure
grpdelay(NUM,DEN)

%polos e zeros
figure
zplane(NUM,DEN)

%Verificar Requisitos
var = (pi/100000);
var1 = ceil(wp/var+1);
var2 = ceil(wr/var+1);
%w = 0
mod_0 = 20*log10(abs(H(1)))
%w = wp
mod_wp = 20*log10(abs(H(var1)))
%w = wr
mod_wr = 20*log10(abs(H(var2)))