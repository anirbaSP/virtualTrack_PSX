function s = mapSpikeTimesToPosition(s,r)
%
%
% INPUT
%   s: spikes struct
%   r: run struct
%
%

% Created: 2/14/13


obj = r.obj_trk.obj;
pmat = r.position_data;

% Loop through spike times
for i = 1:length(s.spiketimes)
    trial = s.trials(i);
    t = pmat(:,trial,1);
    p = pmat(:,trial,2);
    tmp = diff(double(t < s.spiketimes(i)) - double(t >= s.spiketimes(i)));
    k = find(tmp == -2);
    if length(p(k) == 1)
        s.time_in_pmat(i) = t(k);
        s.position(i) = p(k);     % Absolute position on track
        s.obj_type(i) = pmat(k,trial,6);
        s.position_rel(i) = s.position(i) - pmat(k,trial,7);      % Position relative to object
        s.encounter_number(i) = pmat(k,trial,8);
    elseif isempty(p(k))
        s.time_in_pmat(i) = NaN;
        s.position(i) = NaN;     % Absolute position on track
        s.obj_type(i) = NaN;
        s.position_rel(i) = NaN;      % Position relative to object
        s.encounter_number(i) = NaN;
    else
        s_pos = mean(p(k),p(k+1));
        s.time_in_pmat(i) = mean(p(k),p(k+1));
    end
    
    
end

