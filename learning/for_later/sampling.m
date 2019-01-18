%addpath('C:\Users\tom\Desktop\matlab_aurora');
rng (12);
%cam=webcam(2);
try
    % Aurora Comm
    useTX = 0;
    commPort = 'COM5';
    ard=serial('COM6','BaudRate',9600,'Timeout',10);
    fopen(ard);
   
    % open up the serial port.
    aurora = serial(commPort, 'BaudRate',   9600 , 'terminator', 'CR', 'BytesAvailableFcnMode', 'terminator');
    fopen(aurora);

    %% send a serial break to ensure default set-up.
    serialbreak(aurora)
    [reply, count, msg] = fscanf(aurora);
    if( count <= 0 )
        error('%s', msg)
    elseif( ~strcmpi( reply(1:5), 'RESET') )
        fclose(aurora);
        error('Error: System did not receive the initial RESET');
    end
    
fprintf(aurora, 'COMM A0001');
reply = fscanf(aurora);
fprintf(['COMM 60001 Reply: ', reply]);
if( ~strcmpi(reply(1:4), 'OKAY') )
    fclose(aurora);
    error('Error: COMM 60001 failed');
end
% now change the system baud rate.
set(aurora, 'BaudRate', 230400 , 'StopBits', 1, 'FlowControl', 'hardware');
%set(aurora, 'BaudRate', 921600);
pause(1);
    
    
    
    
    %% init the system.
    fprintf(aurora, 'INIT '); % note that the extra space is important here.
    reply = fscanf(aurora);
    fprintf(['INIT Reply: ', reply])
    if( ~strcmpi(reply(1:4), 'OKAY') )
        fclose(aurora);
        error('Error: INIT command failed.');
    end
    
    %% set up the port handles.
    
    % any port handles need freeing?
    fprintf(aurora, 'PHSR 01');
    phsr_reply = fscanf(aurora);
    fprintf(['PHSR 01 Reply: ', phsr_reply]);
    loc = 1;
    nToFree = hex2dec(phsr_reply(1:2));
    loc = loc + 2;
    if(nToFree > 0)
        for i = 1:nToFree
            handle = phsr_reply(loc:loc+1);
            fprintf(aurora, 'PHF %s', handle);
            reply = fscanf(aurora);
            if( ~strcmpi(reply(1:4), 'OKAY') )
                fclose(aurora);
                error('Error: PHF command failed.');
            end
            loc = loc + 5;
        end
    end
    
  
    
    % any port handles need to be initialized?
    fprintf(aurora, 'PHSR 02');
    phsr_reply = fscanf(aurora);
    fprintf(['PHSR 02 Reply: ', phsr_reply]);
    loc = 1;
    nToInit = hex2dec(phsr_reply(1:2));
    loc = loc + 2;
    if(nToInit > 0)
        for i = 1:nToInit
            handle = phsr_reply(loc:loc+1);
            send = sprintf('PINIT %s', handle);
            fprintf(['Sending... ', send, '\n']);
            fprintf(aurora, send);
            reply = fscanf(aurora);
            if( ~strcmpi(reply(1:4), 'OKAY') )
                fclose(aurora);
                error('Error: PINIT command failed.');
            end
            loc = loc + 5;
        end
    end
    
    % any port handle need to be enabled?
    fprintf(aurora, 'PHSR 03');
    phsr_reply = fscanf(aurora);
    fprintf(['PHSR 03 Reply: ', phsr_reply]);
    loc = 1;
    nToEnable = hex2dec(phsr_reply(1:2));
    loc = loc + 2;
    if(nToEnable > 0)
        for i = 1:nToEnable
            handle = phsr_reply(loc:loc+1);
            send = sprintf('PENA %sD', handle);
            fprintf(['Sending... ', send, '\n']);
            fprintf(aurora, send);
            reply = fscanf(aurora);
            if( ~strcmpi(reply(1:4), 'OKAY') )
                fclose(aurora);
                error('Error: PENA command failed.');
            end
            loc = loc + 5;
        end
    end
    
    
    fprintf(aurora, 'VSEL 3');
    reply = fscanf(aurora);
    fprintf(['FF: ', reply]);
    
    % start tracking.
    fprintf(aurora, 'TSTART ');
    reply = fscanf(aurora);
    fprintf(['TSTART Reply: ', reply]);
    if( ~strcmpi(reply(1:4), 'OKAY') )
        fclose(aurora);
        error('Error: TSTART command failed.');
    end
    
    

    
    % get some data using TX..
    for i=1:10
      fprintf(aurora, 'TX 0001');
        %fprintf(aurora, 'TX 1001');
       reply = fscanf(aurora);
     pos{i}=reply;
    end
     fprintf(ard,'%d/n' ,256);
     tic

    for i = 10:8050




        
        fprintf(aurora, 'TX 0001');
        %fprintf(aurora, 'TX 1001');
        reply = fscanf(aurora);
        tim(i)=toc;
      %  [a,b]=NDIAuroraPoseOrientation(reply);
%         for jj=1:3
%             if abs(b.pose(1,jj))<400
%                 b.pose(1,jj)=b.pose(1,jj)/4;
%             elseif abs(b.pose(1,jj))>400&&abs(b.pose(1,jj))<1000
%                 b.pose(1,jj)=(b.pose(1,jj)-250*sign(b.pose(1,jj)))/4;
%             else
%                 b.pose(1,jj)=(b.pose(1,jj)-500*sign(b.pose(1,jj)))/4;
%             end
%         end
%         posnow(:,i)= b.pose';
%         
%         b.orientation=normr(b.orientation);
%         quatori= b.orientation;
%         [orirad(1,1),orirad(1,2),orirad(1,3)]=quat2angle(b.orientation);
%         orinow(:,i)=radtodeg(orirad);
% 
%          if orinow(3,i)>90
%              orinow(3,i)=orinow(3,i)-360;
%          elseif orinow(1,i)<-90
%              orinow(1,i)=orinow(1,i)+360;
%          end
  

        

        pos{i+1}=reply;
      
        
    end
    
   

    
    % stop tracking.
    fprintf(aurora, 'TSTOP ');
    
    reply = fscanf(aurora);
    fprintf(['TSTOP Reply: ', reply]);
    if( ~strcmpi(reply(1:4), 'OKAY') )
        fclose(aurora);
        error('Error: TSTOP command failed.');
    end
    
            fclose(ard);
    delete(ard);
    clear ard;
    


    fclose(aurora);
    delete(aurora);
    clear aurora;
catch
    
        fclose(ard);
    delete(ard);
    clear ard;
    


    fclose(aurora);
    delete(aurora);
    clear aurora;
    

    %clear cam;
end





