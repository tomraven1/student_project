

para.stp=200;
para.cc=2;
para.num=1;
for kk= 1
    %inp1=zeros(6,para.stp);
    inp1=zeros(3,fix(para.stp/para.cc)+1);
    ang=1:1:para.stp;
   targetact=[-50*ones(1,para.stp);100*sin(ang/10);-210*ones(1,para.stp)];
   %def=[-0.11 0.00; 0.11 0.00; 0.00 -0.11; 0.00 0.11;0.0577 0.0577;-0.0577 -0.0577;-0.0577 0.0577;0.0577 -0.0577 ];
   %def=[-0.08 0.00; 0.08 0.00; 0.00 -0.08; 0.00 0.08;0.042 0.042;-0.042 -0.042;-0.042 0.042;0.042 -0.042 ];
 
  % targetact=[def(kk,1)*ones(1,para.stp);0.18*ones(1,para.stp);def(kk,2)*ones(1,para.stp)];
      %targetact=cursor_info(:).Position;
   % targetact=0*ones(2,para.stp);
 %  targetact=[-106.333868725108,33.7520027957471,-244.584257053253]; 
   % para.obs=[-0.00796299318661765,0.170378626294614,0.0952718378531714;0.0403764130586912,0.184328638051578,0.0635181972469682;1.12900702264791e-05,0.195085976342545,0.0442471856046379;-0.00435217346239558,0.186798823951194,0.0655488278035311;0.0214830331295295,0.190109500431443,0.0483183335485488;0.0250670043008947,0.176749364643438,0.0779074361220406];
%     pk=randi(5000,1,para.num);
%     targetact(:,1:50)=repmat(Pos(pk,:),50,1)';
%     
%         pk=randi(5000,1,para.num);
%     targetact(:,51:100)=repmat(Pos(pk,:),50,1)';
%    
%             pk=randi(5000,1,para.num);
%     targetact(:,101:150)=repmat(Pos(pk,:),50,1)';
% 
%             pk=randi(5000,1,para.num);
%     targetact(:,151:200)=repmat(Pos(pk,:),50,1)';
    
    para.tar=targetact;
   % parpool
    A=1*ones(1,3*(para.stp+1));
    b=1;
    lb=30*ones(1,3*(para.stp+1));
    ub=100*ones(1,3*(para.stp+1));
    para.aic=aic;
    para.xic=xic;
    
    f = @(inp)evalu(inp,para);
    
    
    options =  optimoptions (@fmincon,'Display','iter','MaxIterations',30,'algorithm','sqp');
    %options =  optimset ('Display','iter');
    %options =  optimoptions (@fmincon,'MaxIterations',5,'algorithm','sqp','UseParallel',false);
    %options =  optimset ('Display','iter');
    
    
    
    tic
    [inp,fval] = fmincon(f,inp1,[],[],[],[],lb,ub,[],options);%fminsearch%fminunc
    
    %[x,fval] = fmincon(@evalu,inp1,[],[],[],[],lb,ub,[],options);%fminsearch%fminunc
    
    %[inp,fval] = ga(f,inp1,[],[],[],[],lb,ub,[],options)
    toc
    
   % delete(gcp('nocreate'))
    
    tim=(para.stp)/100;
    inp2(:,1)=inp(:,1);
    for i=2:para.stp
        if mod(i,para.cc)==0
            inp2(:,i)=inp(:,fix(i/para.cc)+1);
        else
            inp2(:,i)=inp2(:,i-1);
        end
    end
    inp2(:,para.stp+1)=0;
    %
    % inp3(1,:,:)=inp2(1:4,:);
    % inp3(2,:,:)=inp2(5:8,:);
    
    
    %pos = piecewise_driver(inp2,tim,ini_cond);
    
    
    % test(:,1)=net(x(:,1));
    %  test(:,2)=net(x(:,2));
    target=targetact;
    %
    % for i=1:para.stp
    %
    %     test(:,i+2)=net([test(1:6,i);test(1:6,i+1);inp2(:,i);test(7:12,i);test(7:12,i+1)]);
    %
    % end
    
    siz=length(inp2);
    
    X = tonndata(inp2,true,false);
    T=para.T;
    %T = tonndata(t,true,false);
    [xc,xic,aic] = preparets(netc,X,{},T(1,1:siz));
    yc = netc(xc,xic,aic);
    test=cell2mat(yc);
    %testdyn(kk,:)=[test(4,para.stp-1),test(5,para.stp-1),test(6,para.stp-1)];
   % testall(:,:,kk)=test;
    plot(  rssq((test(4:6,2:end-1))-(test(4:6,1:end-2))))
    hold on
    %posdyn(kk,:)=[pos(1,end,end-1,2),pos(2,end,end-1,2),pos(3,end,end-1,2)];
end

     
%   for i=1:1
%     asd=cross((squeeze(posall(:,end,1:end-2,2,i)-posall(:,end,2:end-1,2,i)))',(squeeze(posall(:,end,2:end-1,2,i)-posall(:,end-1,2:end-1,2,i)))')';
%     %plot(  rssq(asd))
%     plot(  rssq(asd)/max(rssq(asd)))
%      %/max(rssq(squeeze(testall(4:6,2:end-1,i))-(testall(4:6,1:end-2,i)))))
% 
%    % plot(  rssq(squeeze(testall(4:6,2:end-1,i))-(testall(4:6,1:end-2,i))))%/max(rssq(squeeze(testall(4:6,2:end-1,i))-(testall(4:6,1:end-2,i)))))
%     hold on
%   end
% 
%   
% 
% scatter3(test(4,1:para.stp-1),test(5,1:para.stp-1),test(6,1:para.stp-1))
% hold on
% scatter3(pos(1,end,1:end-1,2),pos(2,end,1:end-1,2),pos(3,end,1:end-1,2))
% hold on
% scatter3(target(1,:),target(2,:),target(3,:),'g')
% scatter3(endpos(4,:),endpos(5,:),endpos(6,:),'.')
% scatter3(endpos(4,1),endpos(5,1),endpos(6,1),'k')
% toc
% % for i=1:100
% %
% %     scatter3(inipos(1,:,i),inipos(2,:,i),inipos(3,:,i),'r')
% %     pause(0.1)
% %     hold on
% %     if mod(i,10)==0
% %         clear figure;
% %     end
% % end
% 
% 
% 
% 
% 
% for i=1:para.stp-1
%     
%     scatter3(pos(1,:,i,1),pos(2,:,i,1),pos(3,:,i,1),'r')
%     hold on
%     scatter3(pos(1,:,i,2),pos(2,:,i,2),pos(3,:,i,2),'b')
%     pause(0.2)
%     hold on
%     
% end
% 
% 
% for kk=1:8
%     targetact(kk,:)=[def(kk,1);0.16;def(kk,2)];
% end
% 
% 
% 
% 
% 
% scatter3(test(4,1:para.stp-1),test(5,1:para.stp-1),test(6,1:para.stp-1))
% hold on
% scatter3(pos(1,end,1:end-1,2),pos(2,end,1:end-1,2),pos(3,end,1:end-1,2))
%  scatter3(targetact(1),targetact(2),targetact(3))
% 
% scatter3(para.obs(:,1),para.obs(:,2),para.obs(:,3))
% 
% plot(  rssq(squeeze(pos(:,end,2:end-1,2))-squeeze(pos(:,end,1:end-2,2))))
% 
% 
%  
% kl=5000;
% R1       =13.8e-3*kl;                       % [m] Raggio sezione 1
% R2       =11.1e-3*kl;                       % [m] Raggio sezione 2
% R3       =8.2e-3*kl;                        % [m] Raggio sezione 3
% R4       =5.4e-3*kl;                        % [m] Raggio sezione 4
% 
% 
% 
% 
%   h=scatter3(pos(1,:,i,1),pos(2,:,i,1),pos(3,:,i,1),R1,'r');
%     hold on
%     h1=scatter3(pos(1,:,i,2),pos(2,:,i,2),pos(3,:,i,2),R2,'b');
%     
%     
%     
%     
%     
%     
%     