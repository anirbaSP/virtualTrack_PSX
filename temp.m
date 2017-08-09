    global temp_t
    global temp_d
    
    plot(temp_t,temp_d(:,1))
    
    
    d=temp_d(:,1);
       % Set threshold discontinuity
    discontinuity_thresh = 0.1;
    
    % Noise threshold
    noise_threshold = 3;

    % Compute distance traveled in pixels
    d = diff(d);
    d(abs(d) > discontinuity_thresh) = NaN;
    d = nansum(d);
    
    abs(d) > noise_threshold