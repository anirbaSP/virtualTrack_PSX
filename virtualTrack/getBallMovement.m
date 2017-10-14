function d = getBallMovement(run)
% This function is to get the displacement of the running ball sending
% from the Raspberry Pi through udp

% Written by PSX 09/2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% this is an example support 2 optical mouse sensors
mouse1.dx = [];
mouse1.dy = [];
mouse2.dx = [];
mouse2.dy = [];

% get udp line and read udp data
while get(run.u_ball, 'BytesAvailable') > 0
    tmp = fread(run.u_ball);
    if length(tmp) == 4
        switch tmp(2)
            case 1
        mouse1.dx = [mouse1.dx twosComplementDecoderInt8(tmp(3))];
        mouse1.dy = [mouse1.dy twosComplementDecoderInt8(tmp(4))];
            case 2
        mouse2.dx = [mouse2.dx twosComplementDecoderInt8(tmp(3))];
        mouse2.dy = [mouse2.dy twosComplementDecoderInt8(tmp(4))];
        end
    else
        display('incomplete udp packet')
    end
end

% decode udp data for movement detected on each mouse, current support 2
% mice, can add when necessay
%[mouse1, mouse2] = decodeMessage(data);

% comput the ball position
d = computeDisplacement(mouse1, mouse2);
end

function x = twosComplementDecoderInt8(x)
% This is written to decode the int8 type number after receive the binary
% data, e.g. a int8 number packed in python send to matlab. Why this is
% necessay? If you use matlab int8 command to decode, you will find all
% negative value become 127. Unlike most of other computer languages like C
% and phython, when Matlab define int8, int8(2^7) = 127 instead of -128. 
% Similary, it maps machine negative value all to 127. Due to this
% difference in int8 definition, I have to decode the binary by ourself.

% xk = x;
% x = uint8(x); % use unsigned int8
% display([num2str(x) ' is ' num2str(bitget(x,8:-1:1, 'uint8'))])
% display([xk ' is ' sscanf(xk, '%x')]); % num2str(hex2dec(xk))]); %dec2bin(xk, 8) - '0')])

if bitand(x, 128) == 128 % first check the sign, because 128 = [1 0 0 0 0 0 0 0]
    % any negative value x (first digit is 1) will make (bitand(x,128) =
    % 128, but positive x will not give 128.
    %bitget(x, 8:-1:1)
    x = bitand(x, 127); % 127 = [0 1 1 1 1 1 1 1] it only change the first digits to 0
    %bitget(x, 8:-1:1)
    x = bitxor(x, 127)+1; % the definition of 2 complements
    %bitget(x, 8:-1:1)
    x = -int8(x); % put back negative sign   
else 
    %display('pos num')
    %bitget(x, 8:-1:1)
    x = int8(x);
end
end

function d = computeDisplacement(mouse1, mouse2)
% For current application for 1-dimenstion movement, only mouse1.dx data is
% useful. Feel free to add cases for other applications.
d = - mouse1.dy; % note that it can be reversed due to the way to position
% if ~isempty(d)
%     d
% end
% mouse around the ball
end


% function [mouse1, mouse2] = decodeMessage(data)
% mouse1.dx = [];
% mouse1.dy = [];
% mouse2.dx = [];
% mouse2.dy = [];
% 
% % incase there are incomplete package due to the udp send/receive timing,
% % make sure the data contain complete packet first
% idx = strfind(data, 'M');
% if isempty(idx)
%     return
% end
% % if idx(end)+3 > length(data)-idx(1)+1
% %     idx(end) = [];
% % end
% 
% for i = 1:length(idx)
%     if idx(i)+3 > length(data)-idx(1)+1
%         return
%     else
%         tmp = sscanf(data(idx(i):idx(i)+3), '%s%i%i%i');
%         if length(tmp) < 4
%             display(['incomplete packet data is ' data(idx(i):idx(i)+3) ' convert to ' num2str(tmp')])
%             return
%         else
%         thisChannel = tmp(2);
%         dx = twosComplementDecoderInt8(tmp(3));
%         dy = twosComplementDecoderInt8(tmp(4));
%         end
%     end
%     
% %     thisChannel = uint16(data(idx(i)+1));
% %     dx = twosComplementDecoderInt8(data(idx(i)+2));
% %     dy = twosComplementDecoderInt8(data(idx(i)+3));
% %     if dy == 255 && i < length(idx)
% %         display(['this packet is ' data(idx(i):idx(i)+7)])
% %     end
% 
%     switch thisChannel
%         case 1
%             mouse1.dx = [mouse1.dx dx];
%             mouse1.dy = [mouse1.dy dy];            
%         case 2
%             mouse2.dx = [mouse2.dx dx];
%             mouse2.dy = [mouse2.dy dy];
%     end
% end
% end


