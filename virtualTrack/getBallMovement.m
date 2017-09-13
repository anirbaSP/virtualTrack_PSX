function d = getBallMovement(run)
% This function is to get the displacement of the running ball sending
% from the Raspberry Pi through udp

% Written by PSX 09/2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get udp line and read udp data
data = fscanf(run.u_ball);

% decode udp data and get the ball position
mouseInput = decodeMessage(data);

d = computeDisplacement(mouseInput);

function mouseInput = decodeMessage(data)
mouseInput.channel = uint16(data(2));
mouseInput.dx = int8(data(3));
mouseInput.dy = int8(data(4));

function d = computeDisplacement(mouseInput)
mouse1.dx = 0;
mouse1.dy = 0;
if mouseInput.channel == 1
    mouse1.dx = mouseInput.dx;
    mouse1.dy = mouseInput.dy;
else if mouseInput.channel == 2
        mouse2.dx = mouseInput.dx;
        mouse2.dy = mouseInput.dy;
    end
end

% for current application for 1-dimenstion movement. Feel free to add cases
% for other applications
% applications
d = mouse1.dx;

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