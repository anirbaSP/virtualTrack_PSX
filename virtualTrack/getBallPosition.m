function d = getBallPosition(run)
% This function is to get the absolute position of the running ball sending
% from the Raspberry Pi through udp

% get udp line
data = fscanf(run.u_ball)

d = data(2);

% read udp data

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