function d = getBallMovement(run)
% This function is to get the displacement of the running ball sending
% from the Raspberry Pi through udp

% Written by PSX 09/2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get udp line and read udp data
data = [];
udpStart = tic;
while get(run.u_ball, 'BytesAvailable') > 3
    tmp = fscanf(run.u_ball);
    data = [data tmp];
end

% decode udp data for movement detected on each mouse, current support 2
% mice, can add when necessay
[mouse1, mouse2] = decodeMessage(data);

% comput the ball position
d = computeDisplacement(mouse1, mouse2);
end

function [mouse1, mouse2] = decodeMessage(data)
mouse1.dx = [];
mouse1.dy = [];
mouse2.dx = [];
mouse2.dy = [];

% incase there are incomplete package due to the udp send/receive timing,
% make sure the data contain complete packet first
idx = strfind(data, 'M');
if isempty(idx)
    return
end
if idx(end)+3 > length(data)
    idx(end) = [];
end

for i = 1:length(idx)
    thisChannel = uint16(data(idx(i)+1));
    dx = twosComplementDecoderInt8(data(idx(i)+2));
    dy = twosComplementDecoderInt8(data(idx(i)+3));

    switch thisChannel
        case 1
            mouse1.dx = [mouse1.dx dx];
            mouse1.dy = [mouse1.dy dy];            
        case 2
            mouse2.dx = [mouse2.dx dx];
            mouse2.dy = [mouse2.dy dy];
    end
end
end

function x = twosComplementDecoderInt8(x)
% This is written to decode the int8 type number after receive the binary
% data, e.g. a int8 number packed in python send to matlab. Why this is
% necessay? If you use matlab int8 command to decode, you will find all
% negative value become 127. Unlike most of other computer languages like C
% and phython, when Matlab define int8, int8(2^7) = 127 instead of -128. 
% Similary, it maps machine negative value all to 127. Due to this
% difference in int8 definition, I have to decode the binary by ourself.
x = uint8(x); % use unsigned int8
if bitand(x, 128) == 128 % first check the sign, because 128 = [1 0 0 0 0 0 0 0]
    % any negative value x (first digit is 1) will make (bitand(x,128) =
    % 128, but positive x will not give 128.
    x = bitand(x, 127); % 127 = [0 1 1 1 1 1 1 1] it only change the first digits to 0
    x = bitxor(x, 127)+1; % the definition of 2 complements
    x = -int8(x); % put back negative sign
end
end

function d = computeDisplacement(mouse1, mouse2)
% For current application for 1-dimenstion movement, only mouse1.dx data is
% useful. Feel free to add cases for other applications.
d = mouse1.dy;
end


% decode udp data and get the ball position

% private UDPInput DecodeMessage(byte[] data)
%     {
%         if (data.Length == 4)
%         {
%             byte[] dchannel = new byte[2];
%             Array.Copy(data, 1, dchannel, 0, 1);
% 
%             UDPInput input = new UDPInput(
%                 Convert.ToChar(data[0]),
%                 BitConverter.ToUInt16(dchannel, 0),
%                 (sbyte)(data[2]),
%                 (sbyte)(data[3]));
% 
%             return input;
%         }
%         else
%             return new UDPInput();
%     }


% 			//Debug.Log ("received UDP");
% 			try
%             {
%                 byte[] data = client.Receive(ref rpiEndPoint);
% 				UDPInput i = DecodeMessage (data);
%                 //i.Print();
% 
%                 if( i.channel == 1 )
%                 {
% 		
%                     this.input1 = i;
%                     if (Globals.lastMouse1X.Count == 1)
%                     {
%                         Globals.lastMouse1X.Dequeue();
%                         Globals.lastMouse1Y.Dequeue();
%                     }
%                     Globals.lastMouse1X.Enqueue(i.dx);
%                     Globals.lastMouse1Y.Enqueue(i.dy);
%                     this.received1 = true;
%                 }
%                 else if( i.channel == 2 )
%                 {
%                     this.input2 = i;
%                     if (Globals.lastMouse2X.Count == 1)
%                     {
%                         Globals.lastMouse2X.Dequeue();
%                         Globals.lastMouse2Y.Dequeue();
%                     }
%                     Globals.lastMouse2X.Enqueue(i.dx);
%                     Globals.lastMouse2Y.Enqueue(i.dy);
%                     this.received2 = true;
%                 }
% 
% 				// NB: Dont' need updates from both mice to process motion - pure vertical motion won't be detected on mouse 1
% 				//	if( this.received1 && this.received2 )  
% 				if( this.received1 || this.received2 )  
% 				{
% 		
%                     this.received1 = this.received2 = false;
%                     Globals.sphereInput = new SphereInput(this.input1.dx, this.input1.dy, this.input2.dx, this.input2.dy);
%                     Globals.newData = true;
% 					//Debug.Log ("got newdata at");
% 		
%                 }
%                 
%             }
%             catch (Exception err)
%             {
%                 print(err.ToString());
%             }