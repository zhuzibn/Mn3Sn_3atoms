clear all;close all;clc
addpath('D:\tmp\2019STTosc\macrospin\RanCheng_param\wperp_FiM_nodemag_SOT\Iswitch')
if (0)
    subplot(2,1,1);
    plot(tt*1e12,mmx(:,1),tt*1e12,mmy(:,1),tt*1e12,mmz(:,1),'linewidth',2);
    xlabel('time(ps)');ylabel('m');
    legend('mx','my','mz')
    subplot(2,1,2);
    plot(tt*1e12,mmx(:,2),tt*1e12,mmy(:,2),tt*1e12,mmz(:,2),'linewidth',2);
    xlabel('time(ps)');ylabel('m');
    legend('mx','my','mz')
end
if (1)% one level
    %datrange=[-1100:-200:-1700];
    %datrange=[1:2:11];
    datrange=[5000,2000,1000,500,200,100,50,20,10,-10,-20,-50,-100,-200,-500,-1000,-2000,-5000];
    szdate=size(datrange,2);
    mzFe_=zeros(szdate,1);mzGd_=zeros(szdate,1);
    angleFeGd_=zeros(szdate,1);
    Freqq_=zeros(szdate,1);
    angleFez_=zeros(szdate,1);
    for ctdat=1:szdate
        datname=sprintf('final%d.mat',datrange(ctdat));
        datname
        load(datname);
        if (1)
            subplot(2,1,1);
            plot(tt*1e12,mmx(:,1),tt*1e12,mmy(:,1),tt*1e12,mmz(:,1),'linewidth',2);
            xlabel('time(ps)');ylabel('m');
            legend('mx','my','mz')
            ylim([-1 1])
            subplot(2,1,2);
            plot(tt*1e12,mmx(:,2),tt*1e12,mmy(:,2),tt*1e12,mmz(:,2),'linewidth',2);
            xlabel('time(ps)');ylabel('m');
            legend('mx','my','mz')
            ylim([-1 1])
        end
        if (0)
            subplot(2,1,1);
            plot(tt*1e12,mmz(:,1),'linewidth',2);
            xlabel('time(ps)');ylabel('m');
            subplot(2,1,2);
            plot(tt*1e12,mmz(:,2),'linewidth',2);
            xlabel('time(ps)');ylabel('m');
        end
        if(0)%3D plot
            startcount=20000;
            endcount=24000;
            M1(:,1)=mmx(startcount:endcount,1);
            M1(:,2)=mmy(startcount:endcount,1);
            M1(:,3)=mmz(startcount:endcount,1);
            M2(:,1)=mmx(startcount:endcount,2);
            M2(:,2)=mmy(startcount:endcount,2);
            M2(:,3)=mmz(startcount:endcount,2);
            figure;hold on
            plot3(M1(:,1),M1(:,2),M1(:,3));
            plot3(M2(:,1),M2(:,2),M2(:,3));
            grid on;
            
            quiver3(0,0,0,M1(end,1),M1(end,2),M1(end,3),'AutoScale','off','LineWidth',2.5,'Color',[0 0 1]);
            quiver3(0,0,0,M2(end,1),M2(end,2),M2(end,3),'AutoScale','off','LineWidth',2.5,'Color',[0 1 0]);
            
            view(70,26)
            legend('FeCo','Gd');
            xlim([-1 1]);ylim([-1 1]);zlim([-1 1]);
            axis square; xlabel('x');ylabel('y');zlabel('z');
            set(gca,'TickLength',[0.025 0.025],'LineWidth',2);
        end
        if (0)%FFT
            plotfft=1;
            nT0=size(mmx,1);
            runTime0=runtime*1e9;%[ns]
            y=mmx(:,1)';
            rminit=0.6;
            rmlast=0.01;
            Freqq_(ctdat)=FFT_module(nT0,runTime0,y,rminit,rmlast,plotfft);
        end
        close all;
        mzFe_(ctdat)=mmz(end-1,1);
        mzGd_(ctdat)=mmz(end-1,2);
        u=[mmx(end-1,1),mmy(end-1,1),mmz(end-1,1)];
        v=[mmx(end-1,2),mmy(end-1,2),mmz(end-1,2)];
        CosTheta = dot(u,v)/(norm(u)*norm(v));
        angleFeGd_(ctdat) = acosd(CosTheta);
        angleFez_(ctdat)=acosd(mzFe_(ctdat));
    end
end


