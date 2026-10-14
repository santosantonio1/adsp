close all
clear all
clc

pkg load signal

global VIS = 'off';
global VX  = 1.74^2/3;   % variance of x = 1.74*U(-1,1)
global VN  = 0.001;      % measurement noise variance

if ~exist('plots', 'dir'), mkdir('plots'); end

sysA = struct('b', [1 zeros(1,11) -1], 'a', [1 -1]);   % h = [1 1 ... 1]
sysB = struct('b', [1 zeros(1,11) -1], 'a', [1  1]);   % h = [1 -1 1 ... -1]

% ---------------------------------------------------------------- helpers

function save_fig(tag)
    saveas(gcf, ['plots/' tag '.jpg']);
end

% Runs E realizations of one algorithm and returns the averaged MSE curve and
% final coefficients. p is the step size u, or lambda for 'rls'.
function [mse, w] = adapt(alg, p, ord, sys, N, E, delta)
    global VX VN
    if nargin < 7, delta = 1/VX; end   % initial S = delta*I
    L   = ord + 1;
    mse = zeros(1, N);
    w   = zeros(L, 1);
    for k = 1:E
        % Fixed seed, so every configuration sees the same signals.
        rand('state', k); randn('state', k);
        x  = 1.74 * (2*rand(1,N) - 1);
        d  = filter(sys.b, sys.a, x) + sqrt(VN) * randn(1,N);
        xp = [zeros(1,ord) x];
        W  = zeros(L, 1);
        e  = zeros(1, N);
        switch alg
            case 'lms'
                for j = 1:N
                    X = xp(j+ord:-1:j)';
                    e(j) = d(j) - W'*X;
                    W = W + 2*p*e(j)*X;
                end
            case 'sign'   % sign-error LMS
                for j = 1:N
                    X = xp(j+ord:-1:j)';
                    e(j) = d(j) - W'*X;
                    W = W + 2*p*sign(e(j))*X;
                end
            case 'nlms'
                for j = 1:N
                    X = xp(j+ord:-1:j)';
                    e(j) = d(j) - W'*X;
                    W = W + p/(eps + X'*X)*e(j)*X;
                end
            case 'rls'
                S  = delta * eye(L);
                pd = zeros(L, 1);
                for j = 1:N
                    X = xp(j+ord:-1:j)';
                    % Error before the update, as in the LMS variants.
                    e(j) = d(j) - W'*X;
                    S  = (S - (S*X*X'*S) / (p + X'*S*X)) / p;
                    pd = p*pd + d(j)*X;
                    W  = S*pd;
                end
        end
        mse = mse + e.^2;
        w   = w + W;
    end
    mse = mse / E;
    w   = w / E;
end

% mf:   final MSE (mean of the last 10%)
% tc:   first sample after which the next 50 stay within 3 dB of mf
% ce:   coefficient error in dB
% emin: lowest possible MSE (noise plus the taps beyond the filter length)
function [mf, tc, ce, emin] = metrics(mse, w, sys)
    global VX VN
    N  = numel(mse);
    mf = mean(mse(round(0.9*N):N));
    tc = find(movmean(mse, [0 49]) <= 2*mf, 1);
    if isempty(tc) || ~isfinite(mf), tc = NaN; end
    h  = impz(sys.b, sys.a, 12);
    L  = max(numel(w), 12);
    dw = [w; zeros(L-numel(w),1)] - [h; zeros(L-12,1)];
    ce = 10*log10(sum(dw.^2) / sum(h.^2));
    emin = VN + VX*sum(h(numel(w)+1:end).^2);
end

% Runs each [param ord] row of cfg, prints a table and saves the MSE curves and
% frequency responses. Mt gives the theoretical misadjustment.
function sweep(fig_id, tag, alg, cfg, labels, sys, N, E, Mt)
    global VIS VN
    figure(fig_id, 'visible', VIS);
    [H, wf] = freqz(sys.b, sys.a, 512);
    subplot(1,2,2); plot(wf/pi, abs(H), 'k--', 'linewidth', 2); hold on;
    printf('\n--- %s ---\n%-14s %10s %9s %10s %8s %8s %8s\n', tag, 'config', ...
           'MSE (dB)', 'tc', 'coef (dB)', 'Mexp', 'Mt', 'emin dB');
    for i = 1:rows(cfg)
        [mse, w] = adapt(alg, cfg(i,1), cfg(i,2), sys, N, E);
        [mf, tc, ce, emin] = metrics(mse, w, sys);
        printf('%-14s %10.2f %9d %10.2f %8.3g %8.3g %8.2f\n', labels{i}, ...
               10*log10(mf), tc, ce, (mf - emin)/emin, Mt(cfg(i,1), cfg(i,2), emin), ...
               10*log10(emin));
        subplot(1,2,1); semilogx(10*log10(movmean(mse, 25))); hold on;
        subplot(1,2,2); plot(wf/pi, abs(freqz(w, 1, 512)));
    end
    % Fixed limits so a diverging run doesn't stretch the axes.
    subplot(1,2,1); grid on; xlim([1 N]); ylim([-40 20]);
    xlabel('sample'); ylabel('MSE (dB)'); legend(labels(:)', 'location', 'southwest');
    subplot(1,2,2); grid on; xlim([0 1]); ylim([0 1.2*max(abs(H))]);
    xlabel('\omega/\pi'); ylabel('|H|'); legend(['system' labels(:)'], 'location', 'north');
    set(gcf, 'paperposition', [0 0 11 4]);
    save_fig(tag);
end

no_mt = @(p, ord, emin) NaN;

% ================================================================= LMS

N = 3000; E = 20;
umax = @(ord) 1 / ((ord+1)*VX);
Mt   = @(u, ord, emin) u*(ord+1)*VX / (1 - u*(ord+1)*VX);

k = [1 2 5 10 20];
sweep(1, 'lms_u', 'lms', [umax(11)./k' 11*ones(5,1)], ...
      {'umax', 'umax/2', 'umax/5', 'umax/10', 'umax/20'}, sysA, N, E, Mt);

o = [3 7 11 15 23]';
sweep(2, 'lms_ord', 'lms', [arrayfun(umax, o)/2 o], ...
      arrayfun(@(n) sprintf('ord=%d', n), o, 'uniformoutput', false), sysA, N, E, Mt);

% ================================================================= sign-error LMS (nlms.m)

N = 10000; E = 10;
umax = @(ord) sqrt(pi*VN/2) / ((ord+1)*VX);
Mt   = @(u, ord, emin) u*(ord+1)*VX*sqrt(pi/(2*emin));

sweep(3, 'sign_u', 'sign', [umax(11)./k' 11*ones(5,1)], ...
      {'umax', 'umax/2', 'umax/5', 'umax/10', 'umax/20'}, sysB, N, E, Mt);
sweep(4, 'sign_ord', 'sign', [arrayfun(umax, o)/2 o], ...
      arrayfun(@(n) sprintf('ord=%d', n), o, 'uniformoutput', false), sysB, N, E, Mt);

% ================================================================= NLMS

N = 3000; E = 20;
Mt = @(u, ord, emin) u / (2 - u);   % approximation for white input

sweep(5, 'nlms_u', 'nlms', [2./k' 11*ones(5,1)], ...
      {'umax=2', 'umax/2', 'umax/5', 'umax/10', 'umax/20'}, sysB, N, E, Mt);
sweep(6, 'nlms_ord', 'nlms', [ones(5,1) o], ...
      arrayfun(@(n) sprintf('ord=%d', n), o, 'uniformoutput', false), sysB, N, E, Mt);

% ================================================================= RLS

N = 2000; E = 10;
Mt = @(l, ord, emin) (ord+1)*(1-l) / (1+l);

sweep(7, 'rls_lambda', 'rls', [0.5 11; 0.8 11; 0.97 11; 1 11], ...
      {'lambda=0.5', 'lambda=0.8', 'lambda=0.97', 'lambda=1'}, sysB, N, E, Mt);
sweep(8, 'rls_ord', 'rls', [ones(5,1) o], ...
      arrayfun(@(n) sprintf('ord=%d', n), o, 'uniformoutput', false), sysB, N, E, Mt);

% Effect of the initialization: delta = 1/vx (rls.m) against a large delta.
figure(10, 'visible', VIS);
for delta = [1/VX 100]
    [mse, w] = adapt('rls', 1, 11, sysB, 400, E, delta);
    [mf, tc] = metrics(mse, w, sysB);
    printf('RLS delta=%6.2f  tc=%d\n', delta, tc);
    semilogx(10*log10(movmean(mse, 5))); hold on;
end
grid on; xlim([1 400]); xlabel('sample'); ylabel('MSE (dB)');
legend('delta = 1/vx (rls.m)', 'delta = 100');
set(gcf, 'paperposition', [0 0 6 4]);
save_fig('rls_delta');

% ================================================================= comparison

% All algorithms on the same system, ord = 11, default parameters.
N = 10000; E = 10;
sweep(9, 'compare', 'lms', [1/(12*VX)/2 11], {'LMS umax/2'}, sysB, N, E, no_mt);
figure(9, 'visible', VIS);
algs = {'sign', sqrt(pi*VN/2)/(12*VX)/2, 'sign-error umax/2'; ...
        'nlms', 1,                       'NLMS u=1'; ...
        'rls',  1,                       'RLS lambda=1'};
for i = 1:rows(algs)
    [mse, w] = adapt(algs{i,1}, algs{i,2}, 11, sysB, N, E);
    [mf, tc, ce] = metrics(mse, w, sysB);
    printf('%-18s %10.2f %9d %10.2f\n', algs{i,3}, 10*log10(mf), tc, ce);
    subplot(1,2,1); semilogx(10*log10(movmean(mse, 25)));
    subplot(1,2,2); plot((0:511)/512, abs(freqz(w, 1, 512)));
end
subplot(1,2,1); legend(['LMS umax/2' algs(:,3)'], 'location', 'southwest');
subplot(1,2,2); legend(['system' 'LMS umax/2' algs(:,3)'], 'location', 'north');
save_fig('compare');
