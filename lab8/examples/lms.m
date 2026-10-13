close all
clear all
clc

pkg load statistics %para uso com MATLAB comentar essa linha

N=3000; % numero de amostras
E=20; % tamanho do ensemble

ord=7; % ordem do filtro adaptativo
vx=1; % variancia de x
vn= 0.001; % variancia do ruido de medicao

tr_R=(ord+1)*vx; %traco da matriz R

umax=1/tr_R;  % mi maximo

% sistema desconhecido

b=[1 0 0 0 0 0 0 0 0 0 0 0 -1];
a=[1 -1 0 0 0 0 0 0 0 0 0 0 0];
[h,w]=freqz(b,a,1024);

MSEm=zeros(size(1:N));
Wom=zeros(size(1:ord+1));

% 4b)

u=umax/2;

for i=1:E
i1=i
	X=zeros(size(1:ord+1));
	Wo=zeros(size(1:ord+1));

	x=1.74*unifrnd(-1,1,1,N);

	n=normrnd(0,sqrt(vn),1,N);

	ys=filter(b,a,x); % Sinal na saida do sistema desconhecido
	d=ys+n; % Sinal desejado

	for j=1:N
		if(j<ord+1)
			for i=1:j
				X(i)=x(j+1-i);
			end
		else
			for i=1:ord+1
				X(i)=x(j+1-i);
			end
		end
		y(j)=X*Wo';
		e(j)=d(j)-y(j);
		Wo=Wo+X.*2*u*e(j);
	end
	MSEm=MSEm+e.^2;
	Wom=Wom+Wo;
end

[h1,w]=freqz(Wo,[1],1024);
figure
plot(1:1024,abs(h),'y-',1:1024,abs(h1(1:1024)),'r-')
title('Resposta do Sist. Desconhecido x Resposta do filtro FIR para mimax/2');

MSEm=MSEm/E;
MSEmdB=10*log10(MSEm);
figure
subplot(2,1,1)
semilogy(MSEm);
title('MSE para mimax/2');
subplot(2,1,2)
plot(MSEmdB)
title('MSE em dB para mimax/2');
MSEf=mean(MSEm(2800:N));

emin=4.001; % Erro minimo calculado considerando a situacao de
	    % submodelamento (coef. do filt. adapt. < coef. sist. desc.)

u=umax/2;
Mt=u*tr_R/(1-u*tr_R) % desajuste teorico eq. (3.47) %
Mexp=(MSEf-emin)/emin % desajuste experimental %

% Mt= 1.0  e Mexp= 1.2214

