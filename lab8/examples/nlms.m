close all
clear all
clc

pkg load statistics %para uso com MATLAB comentar essa linha

N=10000; % numero de amostras
E=10; % tamanho do ensemble

ord=11; % ordem do filtro adaptativo
vx=1; % variancia de x
vn= 0.001; % variancia do ruido de medicao

tr_R=(ord+1)*vx; %traco da matriz R

umax=1/tr_R*sqrt(pi*vn/2);  % mi maximo = 0.0033

% sistema desconhecido

b=[1 0 0 0 0 0 0 0 0 0 0 0 -1];
a=[1 1 0 0 0 0 0 0 0 0 0 0 0];
[h,w]=freqz(b,a,1024);

MSEm=zeros(size(1:N));
Wom=zeros(size(1:ord+1));

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
		Wo=Wo+X.*2*u*sign(e(j));
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
MSEf=mean(MSEm(9800:N));

emin=vn;

u=umax/2;
Mt=u*tr_R*sqrt(pi/(2*emin)) % desajuste teorico eq. (4.28) %
Mexp=(MSEf-emin)/emin % desajuste experimental %

% Mt= 0.7854  e Mexp= 1.2677

