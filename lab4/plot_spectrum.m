function plot_spectrum(sig, Fs, fig_id, ttl)
    m = length(sig);
    n = pow2(nextpow2(m));
    S = fft(sig, n);
    f = (0:n-1)*(Fs/n);

    figure(fig_id);
    plot(f(1:n/2), abs(S(1:n/2)));
    xlabel('Frequencia (Hz)');
    ylabel('Magnitude');
    title(ttl);
    grid on;
end
