% obj.size=500;
% obj.angle=45;
% obj.background_pix_val=100;
% 
% tmp=mkGrating(obj.size,obj.background_pix_val,obj.angle);

function tmp=mkGrating(size,background_pix_val,angle,contrast)

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

[x,z]=meshgrid(-size/2:1:size/2); %size = obj.size +1;
lum_y=lum_b+(sin(2*pi*sf*(x-phase))*inc.*Circle(size/2+0.5)); %.*exp(-((x/150).^2)-((z/150).^2)));
y=exp(log(lum_y/sDef.a)/sDef.b);

tmp=imrotate(y,angle);
tmp(tmp==0)=gray;

end
