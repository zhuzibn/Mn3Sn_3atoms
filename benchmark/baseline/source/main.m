% template for main.m, 
% clear;clc;close all;
% for countnum=1:99
% usage:copy to new dir, rename to main.m, change parameters
clear ;clc;close all;
%delete result*.txt runtime.txt
tic
%*******configuration**********
conf_file();
enable_Hk_x=1;%1(0):enable(disable) hard axis anisotropy
% time
runtime=5000e-12;
tstep=5e-15;
savestep=50;
scheduledoutput=tstep*savestep;%
tstepcount=round(scheduledoutput/tstep);

starttime=1000e-12;%[s]
endtime=runtime;%[s]
pulsewidth=3000e-12;%[s]
risetime=0e-15;%[s]
downtime=0e-15;%[s]

%**********paramaters**********t
%constant
constantfile();
%dimensions
LFL=50e-9;WFL=50e-9;tFL=30e-9;
LHM=LFL*1.1;WHM=WFL*1.1;tHM=7e-9;
% LFL=50e-9;WFL=50e-9;tFL=8.3e-9;%Chiral-spin rotation of non-collinear antiferromagnet by spin–orbit torque
% LHM=LFL*1.1;WHM=WFL*1.1;tHM=3e-9;
%known parameters
% Ms_Fe=12;%12[emu/cm3]=12e3 A/m, PHYSICAL REVIEW MATERIALS 5, 084406 (2021)
% Ms_Gd=12;%1149;
Ms_Fe=441.85;%1000[emu/cm3]=1.0e6 A/m, PHYSICAL REVIEW MATERIALS 5, 084406 (2021)
Ms_Gd=441.85;%
%Ms_Gd=332;%[emu/cm3]=1012e3 A/m, see THz osc paper ->d=0.4 nm, \mu_Gd=0.4^3*1012e-24=6.9838\mu_B
%%unknown parameters
alp=0.003;
% Hex_1=133.132;%T;23.15meV：Perpendicular full switching of chiral antiferromagnetic order by current 
Hex_1=0;
Hex_2=100.812;%T;100.812T = 17.53meV
% Hex_2=0;

% Hex_Fe=7;%27.4/(gam*1e-12);%[T]3meV->3meV/7.9293\mu_B=6.5355
% Hex_Gd=Hex_Fe;%7.63/2.21*Hex_Fe;%[T]3meV->3meV/6.9838\mu_B=7.4204
% Hk_Fe_z=-2.16;%[T]0.04meV->2*0.04meV/7.9293\mu_B=0.1742 T
Hk_Fe_z=0;
Hk_Gd_z=0;%0.1978/0.1742*Hk_Fe_z;%[T]0.04meV->2*0.04meV/6.9838\mu_B=0.1978 T
Hk_Fe_y=0;
Hk_Gd_y=0;
if enable_Hk_x
Hk_Fe_x=0;%-0.023/(gam*1e-12);%[T]hard axis anisotropy, According to Ran Cheng's 2016 PRL paper, it is 23 times of easy axis anisotropy
Hk_Gd_x=Hk_Fe_x;
%Hk_Gd_x=0.1978/0.1742*Hk_Fe_x;%[T]
else
Hk_Fe_x=0;%[T]
Hk_Gd_x=0;%[T]    
end

% hk_constant=0.4e6;% 1.6e6 J/m3;Advanced Materials 34.23 (2022): 2200327
hk_constant=0.196*1e-3*ele;%0.196 meV
hk6=2*hk_constant/(3*mub);
% hk6=2.13;%K = 2.13T = 0.196 meV
% hk6=2;
DMI_constant=0.833*1e-3*ele;
DMI=DMI_constant/(3*mub);
% DMI=4.796;%D = 4.796T = 0.833 meV
% DMI=0;
% DMI_constant=1e7;% J/m3;Advanced Materials 34.23 (2022): 2200327
% DMI=DMI_constant/(Ms_Fe*1e3);

Hext=[0,0.0250,0];%[T]
Hstarttime=starttime;
Hendtime=runtime;
Hpulsewidth=pulsewidth;
Hext_pulse=Hpulsee(Hstarttime,Hendtime,tstep,Hpulsewidth,Hext);

totstep=round(runtime/tstep);
unitstep=round(totstep/(runtime*1e13));%steps per ps 
%% STT parameters
jc_STT=0e9;%[A/m2]
PolFL=0.4;%polarization of FL layer
PolSTT=[0,0,1];
if STT_FLT
facFLT_STT=0.2;%ratio of FLT over DLT
else
facFLT_STT=0;
end
%% SOT parameters
%% DLT
thetaSH=0.06;
lambdaSF=5e-9;%spin diffusion length
polSOTD_Fe=[1,0,0];%p [0.0250]
polSOTD_Gd=[0,0,0];%spin flux polarization
jc_SOT=50e9;%[A/m2]
%% FLT
jc_SOT2=0e12;%[A/m2]
polSOTF_Fe=[0,0,-1];
polSOTF_Gd=[-1,0,0];%spin flux polarization
if SOT_FLT
    facFLT_SHE=1;%ratio of FLT/DLT
else
    facFLT_SHE=0;
end
jc_SOTpulse=pulsee(starttime,endtime,tstep,pulsewidth,risetime,downtime,jc_SOT);
%% initial condition
inita_theta=210/180*pi;inita_phi=90/180*pi;%first sublattice in FL
ma_init1=[sin(inita_theta)*cos(inita_phi),sin(inita_theta)*sin(inita_phi),cos(inita_theta)];
ma_init2=[sin(inita_theta+120/180*pi)*cos(inita_phi),sin(inita_theta+120/180*pi)*sin(inita_phi),cos(inita_theta+120/180*pi)];
ma_init3=[sin(inita_theta+240/180*pi)*cos(inita_phi),sin(inita_theta+240/180*pi)*sin(inita_phi),cos(inita_theta+240/180*pi)];

initb_thetb=150/180*pi;initb_phi=90/180*pi;%second sublattice in FL
mb_init1=[sin(initb_thetb)*cos(initb_phi),sin(initb_thetb)*sin(initb_phi),cos(initb_thetb)];
mb_init3=[sin(initb_thetb+120/180*pi)*cos(initb_phi),sin(initb_thetb+120/180*pi)*sin(initb_phi),cos(initb_thetb+120/180*pi)];
mb_init2=[sin(initb_thetb+240/180*pi)*cos(initb_phi),sin(initb_thetb+240/180*pi)*sin(initb_phi),cos(initb_thetb+240/180*pi)];

% mb_init1=[sin(initb_theta)*cos(initb_phi),sin(initb_theta)*sin(initb_phi),cos(initb_theta)];
% mb_init2=[sin(initb_theta)*cos(initb_phi+240/180*pi),sin(initb_theta)*sin(initb_phi+240/180*pi),cos(initb_theta)];
% mb_init3=[sin(initb_theta)*cos(initb_phi+120/180*pi),sin(initb_theta)*sin(initb_phi+120/180*pi),cos(initb_theta)];

% inita_theta=90/180*pi;%first sublattice in FL
% initb_theta=90/180*pi;%second sublattice in FL
% ma_init1=[sin(inita_theta)*cos(120/180*pi),sin(inita_theta)*sin(120/180*pi),cos(inita_theta)];
% ma_init2=[sin(inita_theta)*cos(-120/180*pi),sin(inita_theta)*sin(-120/180*pi),cos(inita_theta)];
% ma_init3=[sin(inita_theta)*cos(0/180*pi),sin(inita_theta)*sin(0/180*pi),cos(inita_theta)];
% 
% mb_init1=[sin(initb_theta)*cos(-120/180*pi),sin(initb_theta)*sin(-120/180*pi),cos(initb_theta)];
% mb_init2=[sin(initb_theta)*cos(0),sin(initb_theta)*sin(0),cos(initb_theta)];
% mb_init3=[sin(initb_theta)*cos(120/180*pi),sin(initb_theta)*sin(120/180*pi),cos(initb_theta)];

mmmPL=[0,0,1];
%% others
TT=1000;%[K]
if dipolee
    %to do
else
   K12Dipole=zeros(3,3); 
end
Dx=0;Dy=0;Dz=0;
Demag_=[Dx,0,0;0,Dy,0;0,0,Dz];
%% calc
% totstep=round(runtime/tstep);
%**********dynamics**********
if (0)%label of output file
  fileID = fopen('result.txt','w');
  fprintf(fileID,'%4s %8s %12s %16s %20s %24s %28s\n','#Time(ns)','mx_Fe','my_Fe','mz_Fe','mx_Gd','my_Gd','mz_Gd');
  fclose(fileID);
  
  fileID = fopen('result.txt','w');
  fprintf(fileID,'%4s\n','#Runtime(ps)');
  fclose(fileID);
end
% Atmp=runtime*1e12;
% fileID = fopen('runtime.txt','w');
% fprintf(fileID,'%4.2f\n',Atmp);
% fclose(fileID);
% clear Atmp

rk4_4llg();

% AAA=[mmx(end,1) mmy(end,1) mmz(end,1)];BBB=[mmx(end,2) mmy(end,2) mmz(end,2)];
% sigma=180/pi*acos(dot(AAA,BBB));%[°] angle between m1 and m2
% AAA=[mmx(:,1) mmy(:,1) mmz(:,1)];BBB=[mmx(:,2) mmy(:,2) mmz(:,2)];
% i=1;
% while i<=(totstep/savestep)
% sigma(i,1)=180/pi*acos(dot(AAA(i,:),BBB(i,:)));%[°] angle between m1 and m2
% theta_m1(i,1)=180/pi*acos(dot(AAA(i,:),[0 0 1]));
% theta_m2(i,1)=180/pi*acos(dot(BBB(i,:),[0 0 1]));
% i=i+1;
% end
% figure
% plot(tt*1e12,sigma(:,1),tt*1e12,theta_m1(:,1),tt*1e12,theta_m2(:,1),'linewidth',2);
% xlabel('time(ps)');ylabel('angle');
% legend('m1&m2','m1&z','m2&z');

toc

clear Heffective1 Hext_pulse

save('final.mat')
% 
% ct=1;
% AAA=round(totstep/savestep);
% lx=zeros(round(totstep/savestep),1);ly=zeros(round(totstep/savestep),1);lz=zeros(round(totstep/savestep),1);
% while(ct<=AAA)
% lx(ct,1)=(mmx(ct,1)-mmx(ct,2))/2;ly(ct,1)=(mmy(ct,1)-mmy(ct,2))/2;lz(ct,1)=(mmz(ct,1)-mmz(ct,2))/2;
% ct=ct+1;
% end
%% 2D plot 
% figure
% subplot(3,3,2);%Fe1
% quiver(0, 0, mmy(end,1), mmz(end,1),'AutoScale','off','LineWidth',2.5,'Color',[1 0 0.5],'MaxHeadSize', 1.5);
% hold on
% quiver(0, 0, mmy(1,1), mmz(1,1), 'LineStyle', ':', 'LineWidth', 2.5, 'Color', [1 0 0.5], 'AutoScale', 'off','MaxHeadSize', 1.5);
% xlim([-1 1]);ylim([-1 1]);
% 
% inita_theta = atan2(ma_init1(2), ma_init1(3));% Calculate inita_phi (in radians)
% inita_theta_deg = rad2deg(inita_theta);% Convert inita_theta and inita_phi from radians to degrees
% final_theta = atan2(real(mnFe1(2)), real(mnFe1(3)));% Calculate inita_phi (in radians)
% final_theta_deg = rad2deg(final_theta);% Convert inita_theta and inita_phi from radians to degrees
% 
% xlabel(['inita\_theta\_deg = ', num2str(inita_theta_deg), ', final\_theta\_deg = ', num2str(final_theta_deg)]);
% ylabel('mFe1');
% clear inita_ptheta inita_theta_deg final_theta final_theta_deg
% 
% 
% subplot(3,3,5);%Fe1
% ct=1;
% AAA=round(totstep/savestep);
% mtot_1x=zeros(round(totstep/savestep),1);mtot_1y=zeros(round(totstep/savestep),1);mtot_1z=zeros(round(totstep/savestep),1);
% while(ct<=AAA)
% mtot_1x(ct,1)=(mmx(ct,1)+mmx(ct,2)+mmx(ct,3))/3;mtot_1y(ct,1)=(mmy(ct,1)+mmy(ct,2)+mmy(ct,3))/3;mtot_1z(ct,1)=(mmz(ct,1)+mmz(ct,2)+mmz(ct,3))/3;
% ct=ct+1;
% end
% quiver(0, 0, mtot_1y(end,1), mtot_1z(end,1),'AutoScale','off','LineWidth',2.5,'Color',[1 0 0.5],'MaxHeadSize', 1.5);
% hold on
% 
% inita_theta = atan2(mtot_1y(1,1), mtot_1z(1,1));% Calculate inita_phi (in radians)
% inita_theta_deg = rad2deg(inita_theta);% Convert inita_theta and inita_phi from radians to degrees
% final_theta = atan2(mtot_1y(end,1), mtot_1z(end,1));% Calculate inita_phi (in radians)
% final_theta_deg = rad2deg(final_theta);% Convert inita_theta and inita_phi from radians to degrees
% 
% xlabel(['inita\_theta\_deg = ', num2str(inita_theta_deg), ', final\_theta\_deg = ', num2str(final_theta_deg)]);
% ylabel('mtot_1');
% clear inita_ptheta inita_theta_deg final_theta final_theta_deg
% 
% subplot(3,3,7);%Fe2
% quiver(0, 0, mmy(end,2), mmz(end,2),'AutoScale','off','LineWidth',2.5,'Color',[1 0 0.5],'MaxHeadSize', 1.5);
% hold on
% quiver(0, 0, mmy(1,2), mmz(1,2), 'LineStyle', ':', 'LineWidth', 2.5, 'Color', [1 0 0.5], 'AutoScale', 'off','MaxHeadSize', 1.5);
% xlim([-1 1]);ylim([-1 1]);
% 
% inita_theta = atan2(ma_init2(2), ma_init2(3));% Calculate inita_phi (in radians)
% inita_theta_deg = rad2deg(inita_theta);% Convert inita_theta and inita_phi from radians to degrees
% final_theta = atan2(real(mnFe2(2)), real(mnFe2(3)));% Calculate inita_phi (in radians)
% final_theta_deg = rad2deg(final_theta);% Convert inita_theta and inita_phi from radians to degrees
% 
% xlabel(['inita\_theta\_deg = ', num2str(inita_theta_deg), ', final\_theta\_deg = ', num2str(final_theta_deg)]);
% ylabel('mFe2');
% clear inita_ptheta inita_theta_deg final_theta final_theta_deg
% 
% subplot(3,3,9);%Fe3
% quiver(0, 0, mmy(end,3), mmz(end,3),'AutoScale','off','LineWidth',2.5,'Color',[1 0 0.5],'MaxHeadSize', 1.5);
% hold on
% quiver(0, 0, mmy(1,3), mmz(1,3), 'LineStyle', ':', 'LineWidth', 2.5, 'Color', [1 0 0.5], 'AutoScale', 'off','MaxHeadSize', 1.5);
% xlim([-1 1]);ylim([-1 1]);
% 
% inita_theta = atan2(ma_init3(2), ma_init3(3));% Calculate inita_phi (in radians)
% inita_theta_deg = rad2deg(inita_theta);% Convert inita_theta and inita_phi from radians to degrees
% final_theta = atan2(real(mnFe3(2)), real(mnFe3(3)));% Calculate inita_phi (in radians)
% final_theta_deg = rad2deg(final_theta);% Convert inita_theta and inita_phi from radians to degrees
% 
% xlabel(['inita\_theta\_deg = ', num2str(inita_theta_deg), ', final\_theta\_deg = ', num2str(final_theta_deg)]);
% ylabel('mFe3');
clear inita_ptheta inita_theta_deg final_theta final_theta_deg


% save('final.mat')
% chr=['final-',num2str(countnum),'.mat'];
% save(chr)
% clear ;clc;close all;
% end


