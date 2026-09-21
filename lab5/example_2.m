%Projeto de Filtro Digital Chebyshev - Passa-baixas, passa-altas,
%passa-banda e rejeita-banda

clear all
close all
clc

format long g

% 1 - Filtro passa-baixas
Amax = 0.5;
Amin = 12;

wp = 100;
wr = 400;
Fs = 500;

Wp1 = wp;
Wr1 = wr;
Ts = 1 /(Fs);

wp = Ts * Wp1;
wr = Ts * Wr1;

%Pré-distorção das frequências
Wap = 2*Fs*tan(wp/2);
War = 2*Fs*tan(wr/2);

%Calculo da ordem do Filtro
[n,wn]=cheb1ord(Wap,War,Amax,Amin,'s');
wo = Wap;

%Determinaçao do filtro normalizado
[z,p,k]=cheb1ap(n,Amax);
b = poly(z)*k;
a = poly(p);

%Transformaçao do filtro
[bt,at]=lp2lp(b,a,wo);

%Transformaçao Bilinear
[NUM,DEN] = bilinear(bt,at,Fs);

% Determina H(z)
h = tf(NUM, DEN, -1, 'variable','z^-1')

%Gráfico de módulo e fase
freqz(NUM,DEN);

%Atraso de Grupo
figure
grpdelay(NUM,DEN)

%Polos e zeros
figure
zplane(NUM,DEN)

%Plotar Resposta em Frequencia da H(z) obtida pela Transformação Bilinear
w = 0:pi/512:pi; 
H = freqz(NUM,DEN,w); 
 
%Verificar Requisitos 
var = (pi/512);
var1 = ceil(wp/var+1); 
var2 = ceil(wr/var+1);  
%w = 0
mod = 20*log10(abs(H(1)))  
%w = wp
mod = 20*log10(abs(H(var1)))  
%w = wr
mod = 20*log10(abs(H(var2))) 

% 2 - Filtro passa-altas

Amax = 0.5;
Amin = 12;

%Frequências analógicas de passagem e rejeição em rad/s
wp = 1000;
wr = 500;

%Frequência de amostragem em Hz
Fs = 500;

%Frequências digitais
Wp1 = wp;
Wr1 = wr;
Ts = 1 /(Fs);

wp = Ts * Wp1;
wr = Ts * Wr1;

%Pré-distorção das frequências
Wap = 2*Fs*tan(wp/2);
War = 2*Fs*tan(wr/2);

%Calculo da ordem do Filtro
[n,wn]=cheb1ord(Wap,War,Amax,Amin,'s');
wo = Wap;

%Determinaçao do filtro normalizado
[z,p,k]=cheb1ap(n,Amax);
b = poly(z)*k;
a = poly(p);

%Transformaçao do filtro
[bt1,at1]=lp2hp(b,a,wo);

%Transformaçao Bilinear
[NUM,DEN] = bilinear(bt1,at1,Fs);

% Determina H(z)
h = tf(NUM, DEN, -1, 'variable','z^-1')

%Plotar Resposta em Frequencia da H(z) obtida pela Transformação Bilinear
w = 0:pi/10000:pi;
H = freqz(NUM,DEN,w);

%Plotar módulo e fase
figure
freqz(NUM,DEN)

%Plotar atraso de grupo
figure
grpdelay(NUM,DEN)

%polos e zeros
figure
zplane(NUM,DEN)

%Verificar Requisitos
var = (pi/10000);
var1 = ceil(wp/var+1);
var2 = ceil(wr/var+1);
%w = 0
mod_0 = 20*log10(abs(H(1)))
%w = wp
mod_wp = 20*log10(abs(H(var1)))
%w = wr
mod_wr = 20*log10(abs(H(var2)))

% 3 - Filtro passa-banda

%Atenuações banda de passagem (Amáx) e banda de rejeição (Amin)

Amax = 0.1;
Amin = 15;

%Frequência analógica em rad/s

wo = 2*pi*1000;
w3 = 2*pi*200;
wp = [5026.5482 7853]; %wp = [wp1 wp2] ou wp = [w1 w2]
wr = [w3 31415.9255];   %wr = [ws1 ws2] ou wr = [w3 w4]

%Frequência de amostragem em Hz
Fs = 12000;

B = 2*pi*450;

%Frequências digitais
Wo = wo;
W3 = w3;
Wp1 = wp;
Wr1 = wr;
B1 = B;
Ts = 1 /(Fs);

wo = Ts * Wo;
w3 = Ts * W3;
wp = Ts * Wp1;
wr = Ts * Wr1;

%Pré-distorção das frequências
Wao = 2*Fs*tan(wo/2);
Wa3 = 2*Fs*tan(w3/2);
Wap = 2*Fs*tan(wp/2);
War = 2*Fs*tan(wr/2);

%Calculo da ordem do Filtro
[n,wn]=cheb1ord(Wap,War,Amax,Amin,'s');

%Determinaçao do filtro normalizado
[z,p,k]=cheb1ap(n,Amax);
b = poly(z)*k;
a = poly(p);

%Transformaçao do filtro
B1 = Wap(2)-Wap(1);
Wao = sqrt(Wap(1)*Wap(2));

[bt2,at2]=lp2bp(b,a,Wao,B1);

%Transformaçao Bilinear
[NUM,DEN] = bilinear(bt2,at2,Fs);

%Plotar Resposta em Frequencia
w = 0:pi/512:pi;
H = freqz(NUM,DEN,w);

%Plotar módulo e fase
figure
freqz(NUM,DEN)

%Plotar atraso de grupo
figure
grpdelay(NUM,DEN)

%polos e zeros
figure
zplane(NUM,DEN)

%Verificar Requisitos 

var = (pi/512);
var1 = ceil(wp(1)/var+1);
var2 = ceil(wp(2)/var+1);
var3 = ceil(wr(1)/var+1);  
var4 = ceil(wr(2)/var+1);  

%w = 0
mod_0 = 20*log10(abs(H(1)))  
%w = wp1
mod_wp1 = 20*log10(abs(H(var1)))  
%w = wp2
mod_wp2 = 20*log10(abs(H(var2))) 
%w = wr1
mod_wr1 = 20*log10(abs(H(var3)))  
%w = wr2
mod_wr2 = 20*log10(abs(H(var4))) 

% 4 - Filtro rejeita-banda

%Atenuação na banda de passagem (Amax) e Banda de Rejeição (Amin)
Amax = 0.1;
Amin = 15;

%Frequência analógica em rad/s
wo = 1095.445115;
w3 = 800;
wp = [200 6000];    % [wp1 wp2] ou [w1 w2]
wr = [w3 1500];     % [ws1 ws2] ou [w3 w4]

%Frequência de amostragem em Hz
Fs = 2000;

%Largura de Banda em  rad/s
B = 5800;   %B = wp2 - wp1 ou B = w2 - w1

%Frequências digitais
Wo = wo;
W3 = w3;
Wp1 = wp;
Wr1 = wr;
B1 = B;
Ts = 1 /(Fs);

wo = Ts * Wo;
w3 = Ts * W3;
wp = Ts * Wp1;
wr = Ts * Wr1;

%Pré-distorção das frequências
Wao = 2*Fs*tan(wo/2);
Wa3 = 2*Fs*tan(w3/2);
Wap = 2*Fs*tan(wp/2);
War = 2*Fs*tan(wr/2);

%Calculo da ordem do Filtro
[n,wn]=cheb1ord(Wap,War,Amax,Amin,'s');

%Determinaçao do filtro normalizado
[z,p,k]=cheb1ap(n,Amax);
b = poly(z)*k;
a = poly(p);

%Transformaçao do filtro
B1 = Wap(2)-Wap(1);
Wao = sqrt(Wap(1)*Wap(2));

[bt3,at3]=lp2bs(b,a,Wao,B1);

%Transformaçao Bilinear
[NUM,DEN] = bilinear(bt3,at3,Fs);

%Plotar Resposta em Frequencia
w = 0:pi/2048:pi;
H = freqz(NUM,DEN,w);

%Plotar módulo e fase
figure
freqz(NUM,DEN)

%Plotar atraso de grupo
figure
grpdelay(NUM,DEN)

%polos e zeros
figure
zplane(NUM,DEN)

%Verificar Requisitos 

var = (pi/2048);
var1 = ceil(wp(1)/var+1);
var2 = ceil(wp(2)/var+1);
var3 = ceil(wr(1)/var+1);  
var4 = ceil(wr(2)/var+1);  

%w = 0
mod_0 = 20*log10(abs(H(1)))  
%w = wp1
mod_wp1 = 20*log10(abs(H(var1)))  
%w = wp2
mod_wp2 = 20*log10(abs(H(var2))) 
%w = wr1
mod_wr1 = 20*log10(abs(H(var3)))  
%w = wr2
mod_wr2 = 20*log10(abs(H(var4))) 