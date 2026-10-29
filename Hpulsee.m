function Hextp=Hpulsee(Hstarttime,Hendtime,tstep,Hpulsewidth,Hext)
stabletime=Hpulsewidth;
startstep=round(Hstarttime/tstep);
stablestep=round(stabletime/tstep);
endstep=round(Hendtime/tstep);
lattertime=endstep-startstep-stablestep;
Hextp = cat(3, zeros(1, 3, startstep), repmat(reshape(Hext, 1, 3, 1), [1, 1, stablestep]), zeros(1, 3, lattertime));
end
