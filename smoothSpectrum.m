function x_oct = smoothSpectrum(X,f,Noct)
    x_oct = X; % initial spectrum
    if Noct > 0 % don't bother if no smoothing
        for i = find(f>0,1,'first'):length(f)
            g = gauss_f(f,f(i),Noct);
            x_oct(i) = sum(g.*X); % calculate smoothed spectral coefficient
        end
        % remove undershoot when X is positive
        if all(X>=0)
            x_oct(x_oct<0) = 0;
        end
    end
end

function g = gauss_f(f_x,F,Noct)
    sigma = (F/Noct)/pi; % standard deviation
    g = exp(-(((f_x-F).^2)./(2.*(sigma^2)))); % Gaussian
    g = g./sum(g); % normalise magnitude
end