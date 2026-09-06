function [h, M] = design_fir(type, specs, Fs)
    % Projeta um filtro FIR por janela de Hanning a partir das
    % frequencias de passagem/rejeicao em specs (Hz). A ordem M segue a
    % regra M = ceil(8*pi/dw), dw = largura de transicao normalizada,
    % consistente com a largura do lobulo principal da janela de Hanning.
    switch type
        case 'low'
            wp = 2*pi*specs.fp/Fs;
            ws = 2*pi*specs.fs/Fs;
            dw = ws - wp;
            wc = (wp + ws)/2;
            M  = ceil(8*pi/abs(dw));
            h  = fir1(M, wc/pi, 'low', hanning(M+1));

        case 'high'
            wp = 2*pi*specs.fp/Fs;
            ws = 2*pi*specs.fs/Fs;
            dw = wp - ws;
            wc = (wp + ws)/2;
            M  = ceil(8*pi/abs(dw));
            M  = M + mod(M, 2); % passa-altas exige ordem par (Tipo I)
            h  = fir1(M, wc/pi, 'high', hanning(M+1));

        case 'bandpass'
            fp1 = specs.fp1; fp2 = specs.fp2; fs1 = specs.fs1;
            fs2 = fp1*fp2/fs1; % simetria geometrica (mesma razao fs/fp nas 2 bordas)

            wp1 = 2*pi*fp1/Fs; wp2 = 2*pi*fp2/Fs;
            ws1 = 2*pi*fs1/Fs; ws2 = 2*pi*fs2/Fs;

            wc1 = (wp1+ws1)/2; wc2 = (wp2+ws2)/2;
            dw1 = wp1-ws1;     dw2 = ws2-wp2;

            M = max(ceil(8*pi/dw1), ceil(8*pi/dw2));
            h = fir1(M, [wc1/pi wc2/pi], hanning(M+1));

        case 'stop'
            % rejeita-banda: aqui fs1/fs2 (banda rejeitada) e fp1/fp2
            % (bordas da passagem, fora da banda rejeitada) sao todas
            % dadas explicitamente em specs -- nao ha simetria a derivar.
            fp1 = specs.fp1; fp2 = specs.fp2;
            fs1 = specs.fs1; fs2 = specs.fs2;

            wp1 = 2*pi*fp1/Fs; wp2 = 2*pi*fp2/Fs;
            ws1 = 2*pi*fs1/Fs; ws2 = 2*pi*fs2/Fs;

            wc1 = (wp1+ws1)/2; wc2 = (wp2+ws2)/2;
            dw1 = ws1-wp1;     dw2 = wp2-ws2;

            M = max(ceil(8*pi/dw1), ceil(8*pi/dw2));
            M = M + mod(M, 2); % rejeita-banda exige ordem par (Tipo I)
            h = fir1(M, [wc1/pi wc2/pi], 'stop', hanning(M+1));

        otherwise
            error('design_fir: tipo de filtro desconhecido: %s', type);
    end
end
