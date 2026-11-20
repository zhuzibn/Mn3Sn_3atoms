%% 2.0
ct=1;
AAA=round(totstep/savestep);
mtot_1x=zeros(round(totstep/savestep),1);mtot_1y=zeros(round(totstep/savestep),1);mtot_1z=zeros(round(totstep/savestep),1);
thetamtot=zeros(round(totstep/savestep),1);
while(ct<=AAA)
mtot_1x(ct,1)=(mmx(ct,1)+mmx(ct,2)+mmx(ct,3))/3;mtot_1y(ct,1)=(mmy(ct,1)+mmy(ct,2)+mmy(ct,3))/3;mtot_1z(ct,1)=(mmz(ct,1)+mmz(ct,2)+mmz(ct,3))/3;
mtot_1y(ct,1) = ((mtot_1x(ct,1))^2+(mtot_1y(ct,1))^2)^0.5;
thetamtot(ct,1)=atan2(mtot_1y(ct,1), mtot_1z(ct,1));
thetamtot(ct,1)=rad2deg(thetamtot(ct,1));
ct=ct+1;
end
plot(tt*1e12,thetamtot(:,1),'linewidth',2);
xlabel('time(ps)');ylabel('theta_mtot');