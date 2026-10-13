close all
clear all
clc

pkg load statistics %para uso com MATLAB comentar essa linha

N=2000; % numero de amostras
E=10; % tamanho do ensemble

ord=11; % ordem do filtro adaptativo
vx=1; % variancia de x
vn= 0.001; % variancia do ruido de medicao
delta=1/vx;

% Para lambda = 1

l=1;

% sistema desconhecido

b=[1 0 0 0 0 0 0 0 0 0 0 0 -1];
a=[1 1 0 0 0 0 0 0 0 0 0 0 0];

[h,w]=freqz(b,a,1024);

MSEm=zeros(size(1:N));

for i=1:E
i1=i
	X=zeros(ord+1,1);
	Wo=zeros(ord+1,1);
	pd=zeros(ord+1,1);
	Sd=delta*eye(ord+1);

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

		exp=Sd-((Sd*X*X'*Sd)/(l+X'*Sd*X));
		Sd=(1/l)*exp;
		pd=l*pd+d(j)*X;
		Wo=Sd*pd;
		y(j)=Wo'*X;
		e(j)=d(j)-y(j);
	end
	MSEm=MSEm+e.^2;

end

[h1,w]=freqz(Wo,[1],1024);
figure
plot(1:1024,abs(h),'y-',1:1024,abs(h1),'r-')
title('Resposta do Sist. Desconhecido x Resposta do filtro FIR para lambda=1');

MSEm=MSEm/E;
MSEmdB=10*log10(MSEm);
figure
subplot(2,1,1)
semilogy(MSEm);
title('MSE para lambda=1');
subplot(2,1,2)
plot(MSEmdB)
title('MSE em dB para lambda=1');
MSEf=mean(MSEm);

% CALCULO DO ERRO EM EXCESSO TEORICO

Eexc=vn*(1+((ord+1)/(N+1)))

% Eexc = 0.001

% CALCULO DO ERRO EM EXCESSO PRATICO

emin=var(n);
Eexcp=(MSEf-emin)

% Eexcp = 0.0017

% CALCULO DO DESAJUSTE TEORICO

emin=vn;
M= Eexc/emin

% M = 1.006

% CALCULO DO DESAJUSTE EXPERIMENTAL

emin=var(n);
Mexp=(MSEf-emin)/emin

% Mexp = 1.7578

