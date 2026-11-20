%% function for effective field calculation
% usage: add path which contain this file, call the function
% don't create the same function in new project 
%input
%1. mmm, magnetization, [1x3] vector, [emu/cm3]
%2. Hk, crystalline anisotropy field, double, [Tesla]
%3. Demag_, demagnetizing tensor, [3x3] matrix
%4. Hext, external field, [1x3] vector, [Tesla]
%5. jc_STT, spin current density, double, [A/m2]
%6. tFL, free layer thickness, double, [m]
%7. Ms, saturation magnetization, double, [emu/cm3]
%8. facFLT_SHE,ratio of FLT/DLT
%9. K12Dipole, dipole tensor, [3x3] matrix
%10. mmmPL: magnetization of PL
%11. PolFL:polarization of FL
%12. lFL: length of FL [m]
%13. wFL: width of FL [m]
%14. facFLT_STT:ratio of FLT/DLT in STT 
%15. thetaSH:spin hall angle
%16. tHM:[m] thickness of HM
%17. lambdaSF: [m]spin diffusion length
%18. jc_SOT:[A/m2] SOT current density
%19. TT:[K] Temperature
%20. alp:damping constant, dimensionless
%21. tstep: [s] time step
%22. thermalnois: flag for thermal noise
%output
%1. hh,total effective field (include SOT FLT), [1x3] vector, [Tesla]
%2. sttdlt, STT DLT cofficient, double, [Tesla]
%3. sttflt, STT DLT cofficient, double, [Tesla]
%4. sotdlt, STT DLT cofficient, double, [Tesla]
%5. sotflt, STT DLT cofficient, double, [Tesla]
function [hh_Fe1,hh_Fe2,hh_Fe3,sttdlt_Fe,sttflt_Fe,sotdlt_Fe,sotflt_Fe,hh_Gd1,hh_Gd2,hh_Gd3,sttdlt_Gd,sttflt_Gd,sotdlt_Gd,sotflt_Gd]=field_eta(hk6,mmm_Fe1,mmm_Fe2,mmm_Fe3,mmm_Gd1,mmm_Gd2,mmm_Gd3,Hk_Fe_z,Hk_Gd_z,Hk_Fe_x,Hk_Gd_x,Demag_,Hext,jc_STT,...
    tFL,Ms_Fe,Ms_Gd,facFLT_SHE,K12Dipole,mmmPL,PolFL,lFL,wFL,facFLT_STT,...
    thetaSH,tHM,lambdaSF,jc_SOT,TT,alp,tstep,thermalnois,Hex_1,Hex_2,Hk_Fe_y,Hk_Gd_y,jc_SOT2,DMI)
conf_file();%load configuration
constantfile();%load constant
%% phi(abc)
% hk_Fe1=2*hk6*[0,cos(pi/6),sin(pi/6)].*mmm_Fe1.*[0,cos(pi/6),sin(pi/6)];%phi1
% hk_Fe2=2*hk6*[0,cos(9*pi/6),sin(9*pi/6)].*mmm_Fe2.*[0,cos(9*pi/6),sin(9*pi/6)];%phi2
% hk_Fe3=2*hk6*[0,cos(5*pi/6),sin(5*pi/6)].*mmm_Fe3.*[0,cos(5*pi/6),sin(5*pi/6)];%phi3

% hk_Fe1=2*hk6*dot([0,0,1],mmm_Fe1)*[0,0,1];%phi1
% hk_Fe2=2*hk6*dot([0,sin(4*pi/3),cos(4*pi/3)],mmm_Fe2)*[0,sin(4*pi/3),cos(4*pi/3)];%phi1
% hk_Fe3=2*hk6*dot([0,cos(pi/6),-sin(pi/6)],mmm_Fe3)*[0,cos(pi/6),-sin(pi/6)];%phi3

hk_Fe1=hk6*dot([0,sin(1*pi/6),cos(1*pi/6)],mmm_Fe1)*[0,sin(1*pi/6),cos(1*pi/6)];%phi1
hk_Fe2=hk6*dot([0,sin(9*pi/6),cos(9*pi/6)],mmm_Fe2)*[0,sin(9*pi/6),cos(9*pi/6)];%phi1
hk_Fe3=hk6*dot([0,sin(5*pi/6),cos(5*pi/6)],mmm_Fe3)*[0,sin(5*pi/6),cos(5*pi/6)];%phi3

% hk_Fe1=2*hk6*([Hk_Fe_x,Hk_Fe_y,Hk_Fe_z].*mmm_Fe1);%phi1
% hk_Fe2=2*hk6*([Hk_Fe_x,Hk_Fe_y,Hk_Fe_z].*mmm_Fe2);%phi2
% hk_Fe3=2*hk6*([Hk_Fe_x,Hk_Fe_y,Hk_Fe_z].*mmm_Fe3);%phi3

% hk_Fe1=2*hk6*[0,(mmm_Fe1(2)+mmm_Fe1(3))*cos(2*pi/6),(mmm_Fe1(2)+mmm_Fe1(3))*sin(2*pi/6)];%phi1
% hk_Fe2=2*hk6*[0,(mmm_Fe1(2)+mmm_Fe1(3))*cos(10*pi/6),(mmm_Fe1(2)+mmm_Fe1(3))*sin(10*pi/6)];%phi2
% hk_Fe3=2*hk6*[0,(mmm_Fe1(2)+mmm_Fe1(3))*cos(6*pi/6),(mmm_Fe1(2)+mmm_Fe1(3))*sin(6*pi/6)];%phi3

% hk_Gd1=([Hk_Gd_x,Hk_Gd_y,Hk_Gd_z].*mmm_Gd1)+([hk_Gd1_x,hk_Gd1_y,hk_Gd1_z]);
% hk_Gd2=([Hk_Gd_x,Hk_Gd_y,Hk_Gd_z].*mmm_Gd2)+([hk_Gd2_x,hk_Gd2_y,hk_Gd2_z]);
% hk_Gd3=([Hk_Gd_x,Hk_Gd_y,Hk_Gd_z].*mmm_Gd3)+([hk_Gd3_x,hk_Gd3_y,hk_Gd3_z]);

% hk_Gd1=0*2*hk6*[0,cos(pi/6),sin(pi/6)].*mmm_Fe1.*[0,cos(pi/6),sin(pi/6)];%phi1
% hk_Gd2=0*2*hk6*[0,cos(9*pi/6),sin(9*pi/6)].*mmm_Fe2.*[0,cos(9*pi/6),sin(9*pi/6)];%phi2
% hk_Gd3=0*2*hk6*[0,cos(5*pi/6),sin(5*pi/6)].*mmm_Fe3.*[0,cos(5*pi/6),sin(5*pi/6)];%phi3

hk_Gd1=0*2*hk6*dot([0,sin(5*pi/6),cos(5*pi/6)],mmm_Gd1)*[0,sin(5*pi/6),cos(5*pi/6)];%phi1
hk_Gd2=0*2*hk6*dot([0,sin(9*pi/6),cos(9*pi/6)],mmm_Gd2)*[0,sin(9*pi/6),cos(9*pi/6)];%phi1
hk_Gd3=0*2*hk6*dot([0,sin(1*pi/6),cos(1*pi/6)],mmm_Gd3)*[0,sin(1*pi/6),cos(1*pi/6)];%phi3
%% 按照2023-All-electrical switching of a topological non-collinear antiferromagnet at room temperature
% hDMI_Gd1=DMI*[-(mmm_Gd2(3)+mmm_Fe1(3)),mmm_Gd3(3)+mmm_Fe3(3),mmm_Gd2(2)+mmm_Fe1(2)-mmm_Gd3(1)-mmm_Fe3(1)];
% hDMI_Gd2=DMI*[-(mmm_Gd3(3)+mmm_Fe1(3)),mmm_Gd1(3)+mmm_Fe2(3),mmm_Gd3(2)+mmm_Fe1(2)-mmm_Gd1(1)-mmm_Fe2(1)];
% hDMI_Gd3=DMI*[-(mmm_Gd1(3)+mmm_Fe3(3)),mmm_Gd2(3)+mmm_Fe2(3),mmm_Gd1(2)+mmm_Fe3(2)-mmm_Gd2(1)-mmm_Fe2(1)];
% 
% hDMI_Fe1=DMI*[-(mmm_Fe2(3)+mmm_Gd2(3)),mmm_Fe3(3)+mmm_Gd1(3),mmm_Fe2(2)+mmm_Gd2(2)-mmm_Fe3(1)-mmm_Gd1(1)];
% hDMI_Fe2=DMI*[-(mmm_Fe3(3)+mmm_Gd3(3)),mmm_Fe1(3)+mmm_Gd2(3),mmm_Fe3(2)+mmm_Gd3(2)-mmm_Fe1(1)-mmm_Gd2(1)];
% hDMI_Fe3=DMI*[-(mmm_Fe1(3)+mmm_Gd1(3)),mmm_Fe2(3)+mmm_Gd3(3),mmm_Fe1(2)+mmm_Gd1(2)-mmm_Fe2(1)-mmm_Gd3(1)];

%% c=[0,1,0]2023-All-electrical switching of a topological non-collinear antiferromagnet at room temperature
% hDMI_Fe1=DMI*[-(mmm_Gd1(3)+mmm_Fe2(3)),mmm_Gd2(3)+mmm_Fe3(3),mmm_Gd1(2)+mmm_Fe2(2)-mmm_Gd2(1)-mmm_Fe3(1)];
% hDMI_Fe2=DMI*[-(mmm_Gd2(3)+mmm_Fe3(3)),mmm_Gd3(3)+mmm_Fe1(3),mmm_Gd2(2)+mmm_Fe3(2)-mmm_Gd3(1)-mmm_Fe1(1)];
% hDMI_Fe3=DMI*[-(mmm_Gd3(3)+mmm_Fe1(3)),mmm_Gd1(3)+mmm_Fe2(3),mmm_Gd3(2)+mmm_Fe1(2)-mmm_Gd1(1)-mmm_Fe2(1)];
% 
% hDMI_Gd1=DMI*[-(mmm_Gd2(3)+mmm_Fe3(3)),mmm_Gd3(3)+mmm_Fe1(3),mmm_Gd2(2)+mmm_Fe3(2)-mmm_Gd3(1)-mmm_Fe1(1)];
% hDMI_Gd2=DMI*[-(mmm_Gd3(3)+mmm_Fe1(3)),mmm_Gd1(3)+mmm_Fe2(3),mmm_Gd3(2)+mmm_Fe1(2)-mmm_Gd1(1)-mmm_Fe2(1)];
% hDMI_Gd3=DMI*[-(mmm_Gd1(3)+mmm_Fe2(3)),mmm_Gd2(3)+mmm_Fe3(3),mmm_Gd1(2)+mmm_Fe2(2)-mmm_Gd2(1)-mmm_Fe3(1)];

%% c=[0,0,1]_Three
% hDMI_Fe1=DMI*[mmm_Fe2(2)-mmm_Fe3(2),-mmm_Fe2(1)+mmm_Fe3(1),0];
% hDMI_Fe2=DMI*[-mmm_Fe1(2)+mmm_Fe3(2),mmm_Fe1(1)-mmm_Fe3(1),0];
% hDMI_Fe3=DMI*[-mmm_Fe2(2)+mmm_Fe1(2),mmm_Fe2(1)-mmm_Fe1(1),0];
%% c=[1,0,0]
hDMI_Fe1=-DMI*[0,mmm_Fe2(3)-mmm_Fe3(3),mmm_Fe3(2)-mmm_Fe2(2)];
hDMI_Fe2=-DMI*[0,-mmm_Fe1(3)+mmm_Fe3(3),mmm_Fe1(2)-mmm_Fe3(2)];
hDMI_Fe3=-DMI*[0,-mmm_Fe2(3)+mmm_Fe1(3),mmm_Fe2(2)-mmm_Fe1(2)];

% hDMI_Fe1=-DMI*[0,mmm_Fe2(3)+mmm_Fe3(3),-mmm_Fe2(2)-mmm_Fe3(2)];
% hDMI_Fe2=-DMI*[0,mmm_Fe1(3)+mmm_Fe3(3),-mmm_Fe1(2)-mmm_Fe3(2)];
% hDMI_Fe3=-DMI*[0,mmm_Fe1(3)+mmm_Fe2(3),-mmm_Fe1(2)-mmm_Fe2(2)];

hDMI_Gd1=-DMI*0*[0,mmm_Gd2(3)-mmm_Gd3(3),mmm_Gd3(2)-mmm_Gd2(2)];
hDMI_Gd2=-DMI*0*[0,-mmm_Gd1(3)+mmm_Gd3(3),mmm_Gd1(2)-mmm_Gd3(2)];
hDMI_Gd3=-DMI*0*[0,-mmm_Gd2(3)+mmm_Gd1(3),mmm_Gd2(2)-mmm_Gd1(2)];

Hd_Fe=4*pi*Ms_Fe*Demag_*1e-4;%Tesla
Hd_Gd=4*pi*Ms_Gd*Demag_*1e-4;%Tesla

hd_Fe=(-Hd_Fe*mmm_Fe1')';%([3x3]*[3x1])'=[1x3]
hd_Gd=(-Hd_Gd*mmm_Gd1')';%([3x3]*[3x1])'=[1x3]

%Hex_1 is the nearest-neighbour interlayer exchange interaction
%Hex_2 is the intralayer exchange interaction
hex_Fe1=-Hex_1*mmm_Gd1-Hex_1*mmm_Gd2-Hex_2*mmm_Fe2-Hex_2*mmm_Fe3;
hex_Fe2=-Hex_1*mmm_Gd2-Hex_1*mmm_Gd3-Hex_2*mmm_Fe1-Hex_2*mmm_Fe3;
hex_Fe3=-Hex_1*mmm_Gd1-Hex_1*mmm_Gd3-Hex_2*mmm_Fe1-Hex_2*mmm_Fe2;

hex_Gd1=-Hex_1*mmm_Fe1-Hex_1*mmm_Fe3-Hex_2*mmm_Gd2-Hex_2*mmm_Gd3;
hex_Gd2=-Hex_1*mmm_Fe1-Hex_1*mmm_Fe2-Hex_2*mmm_Gd1-Hex_2*mmm_Gd3;
hex_Gd3=-Hex_1*mmm_Fe2-Hex_1*mmm_Fe3-Hex_2*mmm_Gd1-Hex_2*mmm_Gd2;

hext=Hext;

if dipolee
    hdipole = 4*pi*1e-7*(K12Dipole*Ms_Fe*1e3*mmmPL')';%[Tesla]
else
    hdipole=[0,0,0];
end

Jp_Fe=2*tFL*(Ms_Fe*1e3)/hbar;
Jp_Gd=2*tFL*(Ms_Gd*1e3)/hbar;
if STT_DLT
    efficiencyselect=3;
    switch efficiencyselect%only for IMA, to modify to fit for PMA
        case 1
            b=1/(-4+((1+P)^3)*(3+mmm_Fe(2)*(wPL>lPL)+mmm_Fe(1)*(wPL<lPL)))/(4*(P^(3/2)));
            %Slonswski torque efficiency for GMR
        case 2%Slonswski torque efficiency for TMR
            b=PolFL/(1+(PolFL^2)*(dot(mmm_Fe,mmmPL)));
        case 3
            b=0.8; % fixed torque efficiency
    end
    sttdlt_Fe=jc_STT/Jp_Fe*b;
    sttdlt_Gd=jc_STT/Jp_Gd*b;
    sttflt_Fe=facFLT_STT*sttdlt_Fe;
    sttflt_Gd=facFLT_STT*sttdlt_Gd;
else
    sttdlt_Fe=0;
    sttdlt_Gd=0;
    sttflt_Fe=0;
    sttflt_Gd=0;
end
if SOT_DLT
    sotdlt_Fe=thetaSH*jc_SOT/Jp_Fe;%to modify to auto get easy (y) axis
    sotdlt_Gd=thetaSH*jc_SOT/Jp_Gd;

    sotdltflt_Fe=thetaSH*jc_SOT2/Jp_Fe;%to modify to auto get easy (y) axis
    sotdltflt_Gd=thetaSH*jc_SOT2/Jp_Gd;
    sotflt_Fe=facFLT_SHE*sotdltflt_Fe;
    sotflt_Gd=facFLT_SHE*sotdltflt_Gd;
else
    sotdlt_Fe=0;
    sotdlt_Gd=0;
    sotflt_Fe=0;
    sotflt_Gd=0;
end
%% thermal fluctuation
if thermalnois==1%1(0) (not) enable thermal noise
    hthermtmp=sqrt(2*kb*TT*alp/(lFL*wFL*tFL*Ms_Fe*1e3*gam*(1+alp^2)*tstep));%[T]
    hthermx=normrnd(0,hthermtmp);hthermy=normrnd(0,hthermtmp);hthermz=normrnd(0,hthermtmp);
    htherm=[hthermx,hthermy,hthermz];
else
    htherm=[0,0,0];
end

hh_Fe1=hk_Fe1+hd_Fe+hext+hdipole+htherm+hex_Fe1+hDMI_Fe1; %total field
hh_Fe2=hk_Fe2+hd_Fe+hext+hdipole+htherm+hex_Fe2+hDMI_Fe2; %total field
hh_Fe3=hk_Fe3+hd_Fe+hext+hdipole+htherm+hex_Fe3+hDMI_Fe3; %total field

hh_Gd1=hk_Gd1+hd_Gd+hext+hdipole+htherm+hex_Gd1+hDMI_Gd1;
hh_Gd2=hk_Gd2+hd_Gd+hext+hdipole+htherm+hex_Gd2+hDMI_Gd2;
hh_Gd3=hk_Gd3+hd_Gd+hext+hdipole+htherm+hex_Gd3+hDMI_Gd3;

end