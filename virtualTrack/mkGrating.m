% obj.size=500;
% obj.angle=45;
% obj.background_pix_val=100;
% 
% tmp=mkGrating(obj.size,obj.background_pix_val,obj.angle);

function tmp=mkGrating(sz,background_pix_val,angle,contrast)

%AR on 1/14/2014

sDef=screenDefs;
% cv=[1];
% contrast= cv(randi(length(cv)));
sf= 0.008;  %4 cycles/500 pixels

if angle==360
    contrast=0;
end

% gray=background_pix_val;
% lum_b=sDef.a*(gray^sDef.b);
% lum_max=sDef.a*(255^sDef.b);
% white_lum=lum_b+(lum_max*contrast);
% inc = (white_lum-lum_b); %kluuge effective contrast 16% if set at 14%

lum_max=sDef.a*(255^sDef.b);
lum_b=lum_max/2;
gray=floor(exp(log(lum_b/sDef.a)/sDef.b));
%inc = (lum_max-lum_b)*contrast; %lum_max=2*lum_b
inc = lum_b*contrast;

nsteps=7;
step=round(1/(nsteps*sf));

phase_v=0:step:(step*(nsteps-1));
phase=phase_v(randi(length(phase_v))); %AR on 2/20/15
%phase=0;

% round patch
% [x,z]=meshgrid(-sz/2:1:sz/2); %sz = obj.size +1;
% lum_y=lum_b+(sin(2*pi*sf*(x-phase))*inc.*Circle(sz/2+0.5)); %.*exp(-((x/150).^2)-((z/150).^2)));

% square, need to make a larger mesh to rotate and then truncate
% 08/11/2017 by PSX
m_sz = sz*2;
[x,z]=meshgrid(-m_sz:1:m_sz); %sz = obj.size +1; 
lum_y=lum_b+(sin(2*pi*sf*(x-phase))*inc);

y=exp(log(lum_y/sDef.a)/sDef.b);

tmp=imrotate(y,angle);
% truncate the size to be our target size by taking the center region
idx = int16((size(tmp,1)-sz)/2);
idy = int16((size(tmp,2)-sz)/2);
tmp = tmp(idx:idx+sz, idy:idy+sz);

tmp(tmp==0)=gray;

end
