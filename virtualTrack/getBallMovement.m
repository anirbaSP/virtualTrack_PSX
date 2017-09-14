function d = getBallMovement(run)
% This function is to get the displacement of the running ball sending
% from the Raspberry Pi through udp

% Written by PSX 09/2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
warning off
% get udp line and read udp data
data = fscanf(run.u_ball);

% decode udp data for movement detected on each mouse, current support 2
% mice, can add when necessay
[mouse1, mouse2] = decodeMessage(data);

% comput the ball position
d = computeDisplacement(mouse1, mouse2);
end

function [mouse1, mouse2] = decodeMessage(data)
% incase there are incomplete package due to the udp send/receive timing,
% make sure the data contain complete packet first
mouse1.dx = [];
mouse1.dy = [];
mouse2.dx = [];
mouse2.dy = [];

idx = strfind(data, 'M');

if isempty(idx)
    return
end

if idx(end)+3 > length(data)
    idx(end) = [];
end

for i = 1:length(idx)
    thisChannel = uint16(data(idx(i)+1));
    dx = int8(data(idx(i)+2));
    dy = uint8(data(idx(i)+3));
    if dy == 255
    a = de2bi(dy)
    b = bi2de(de2bi(dy), 'left-msb')
    c = uint8(bi2de(de2bi(dy), 'left-msb'))
    e = typecast(uint8(bi2de(de2bi(dy), 'left-msb')), 'int8')
    end
    dy = typecast(uint8(bi2de(de2bi(dy), 'left-msb')), 'int8');
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

function d = computeDisplacement(mouse1, mouse2)
% For current application for 1-dimenstion movement, only mouse1.dx data is
% useful. Feel free to add cases for other applications.
x = mouse1.dx
d = mouse1.dy

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