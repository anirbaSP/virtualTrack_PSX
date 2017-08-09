function plotDprimeOverTraining(mouse,r_ind)
%
% INPUT
%   mouse: mouse struct
%   r_ind: run struct index
%
%
%

% Created: SRO - 2/18/13




d_prime = [];

for i = 1:length(r_ind)
    r = loadvar(mouse.vtrack.session(r_ind(i)).run_file);
    
    obj = r.obj_trk.obj;
    hit = sum(obj(1).choice)/length(obj(1).choice);
    fa = sum(obj(end).choice)/length(obj(end).choice);
    
%     Compute d-prime (zHit - zFA)
    hit(hit==1) = 0.99;
    hit(hit==0) = 0.001;
    fa(fa==1) = 0.99;
    fa(fa==0) = 0.001;
    
    d_prime(end+1) = norminv(hit) - norminv(fa);
end

d_prime = d_prime(end:-1:1);
a = 1;
