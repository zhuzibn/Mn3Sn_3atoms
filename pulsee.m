%% generate pulse
%{
% usage
jpulse=1;%enable pulse
pulsewidth=30e-9;%[s] pulse width
starttime=5e-9;%[s]
risetime=0.1e-9;%[s]
downtime=0.1e-9;%[s]
totstep=round((runtime+starttime)/tstepa);
t_=linspace(0,runtime+starttime,totstep);
if (runtime+starttime)<(starttime+pulsewidth)
    error('endtime has to be larger than starttime+pulsewidth')
end
jc_=pulsee(starttime,totstep,tstep,pulsewidth,risetime,downtime,Jc0,t_);
%}
%jpulse=1;%enable pulse
function jc_SOTp=pulsee(starttime,endtime,tstep,pulsewidth,risetime,downtime,jc_STT)
% if (0)%example
%      starttime=10e-12;%[s]
%      endtime=10e-12;%[s]
%      tstep=10e-15;%[s]
%      pulsewidth=5e-9;%[s]
%      risetime=100e-15;%[s]
%      downtime=100e-15;%[s]
%     jc_STT=1e11;%[A/m2]
% end
% pulsewidth=10e-12;%[s]
% ADAA=pulsewidth-risetime;

stabletime=pulsewidth-risetime-downtime;
% startstep=floor(starttime/tstep);
% risestep=floor(risetime/tstep);
% downstep=floor(downtime/tstep);
% stablestep=floor(stabletime/tstep);
% endstep=floor(endtime/tstep);
startstep=round(starttime/tstep);
risestep=round(risetime/tstep);
downstep=round(downtime/tstep);
stablestep=round(stabletime/tstep);
endstep=round(endtime/tstep);
lattertime=endstep-startstep-risestep-stablestep-downstep;

jc_SOTp=[zeros(1,startstep),linspace(0,jc_STT,risestep),jc_STT*ones(1,stablestep),...
    linspace(jc_STT,0,downstep),zeros(1,lattertime)];
% if (0)
%     figure;
%     plot(t_*1e9,jc_STT*1e-11);
%     xlabel('time(ns)');ylabel('jc(e-11A/m2)');
% end
end
