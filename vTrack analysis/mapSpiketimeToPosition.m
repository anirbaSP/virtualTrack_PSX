function spikes_t_p = mapSpiketimeToPosition(s,p,t)
%
%
%
%

% Created: 12/3/12


a = 1;

for i = 1:length(s)
    
    tmp = diff(double(t < s(i)) - double(t >= s(i)));
    k = find(tmp == -2);
    if length(p(k) == 1)
        s_pos(i) = p(k);
    else
        s_pos(i) = mean(p(k),p(k+1));
    end
    
end

if isempty(s)
    spikes_t_p = single([1 0]);
else
    spikes_t_p = [s' s_pos'];
end