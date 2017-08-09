function p = removeRestFromPositionData(position_data)
%
%
%
%

% Created: SRO - 6/26/12



p = position_data;

rest = logical(position_data(:,:,5));

for i = 1:4
    tmp = p(:,:,i);
    tmp(rest) = NaN;
    p(:,:,i) = tmp;
end