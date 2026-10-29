%% 4th order Runge Kutta method, for LLG calaulation in both IMA, PMA MTJ with FLT and DLT
% usage: add path which contain this file, call the function
% don't create the same function in new project

% call this function using: [,]=rk4_4llg(,)

%zzf,March.18,19.2016;
%1.changed based on PMA;2.add in FL torque
%% input
% Demag_, 3 by 3 matrix
% tstep is time step, unit [s]
% totstep is total number of steps
% m_init is initial magnetization, it is a 1-by-3 matrix, unit vector
% Ms: saturation magnetization, unit [emu/cm3]
% Hk: uniaxial anisotropy field, one value unit [tesla]
% Hext: applied field, 1-by-3 vector, unit [tesla]
% alp: damping constant
% P: polarization of FL and PL, currently only support same for both layer

% psj: unit 1-by-3 vector, spin flux polarization,
% note in STT the reflection type is opposite to m_pin_layer

% dimension FL_length,FL_width,FL_thickness, unit [nm]

%% output
%mmx,mmy,mmz: magnetization component, unit vector
%tt: simulation time list, unit [ns]
%Icri: critical current for switching unit:[Ampere]
A1=zeros(1,3,totstep);
B1=zeros(1,3,totstep);
C1=zeros(1,3,totstep);
D1=zeros(1,3,totstep);
E1=zeros(1,3,totstep);
F1=zeros(1,3,totstep);
Heffective1=zeros(1,3,totstep);
if dimensionlessLLG
    Hk_=Hk;
    Hk=[1*(FL_width<FL_length)*Hk,1*(FL_width>FL_length)*Hk,0];
    tau_c=(g*Hk(2*(FL_width>FL_length)+1*(FL_width<FL_length)))/(1+alp^2); %natural time constant 1/s
    scal=1;
else
    %Hk=[1,1,1];%normalization purpose
    tau_c=1;
    scal=gam/(1+alp^2);%scale parameter
end
ts1=tstep*tau_c; %time step

ct1=1; %count 1
t=linspace(0,runtime,totstep);
mmx=zeros(totstep,6);%(:,1)is Fe, (:,2)is Gd
mmy=zeros(totstep,6);
mmz=zeros(totstep,6);
mmx(1,1)=ma_init1(1);mmy(1,1)=ma_init1(2);mmz(1,1)=ma_init1(3);
mmx(1,2)=ma_init2(1);mmy(1,2)=ma_init2(2);mmz(1,2)=ma_init2(3);
mmx(1,3)=ma_init3(1);mmy(1,3)=ma_init3(2);mmz(1,3)=ma_init3(3);

mmx(1,4)=mb_init1(1);mmy(1,4)=mb_init1(2);mmz(1,4)=mb_init1(3);
mmx(1,5)=mb_init2(1);mmy(1,5)=mb_init2(2);mmz(1,5)=mb_init2(3);
mmx(1,6)=mb_init3(1);mmy(1,6)=mb_init3(2);mmz(1,6)=mb_init3(3);

while ct1<totstep
    mmFe1=[mmx(ct1,1),mmy(ct1,1),mmz(ct1,1)]; %Fe
    mmFe2=[mmx(ct1,2),mmy(ct1,2),mmz(ct1,2)]; %Fe
    mmFe3=[mmx(ct1,3),mmy(ct1,3),mmz(ct1,3)]; %Fe

    mmGd1=[mmx(ct1,4),mmy(ct1,4),mmz(ct1,4)]; %Gd
    mmGd2=[mmx(ct1,5),mmy(ct1,5),mmz(ct1,5)]; %Gd
    mmGd3=[mmx(ct1,6),mmy(ct1,6),mmz(ct1,6)]; %Gd

    %% current calc
    if (0) %unit conversion Tesla-->A/m,debug use
        hhtmp=(hh*Hk(2)*1e7)/4/pi;
        hk=(hk*Hk(2)*1e7)/4/pi;
        hd=(hd*Hk(2)*1e7)/4/pi;
        hext=(hext*Hk(2)*1e7)/4/pi;
        hdipole=(hdipole*Hk(2)*1e7)/4/pi;
    end
    %% unit convension:
    %e_tmp:[e],unit electron charge
    %hbar_tmp:[ev.s]
    %d_tmp:[m],FL thickness
    %Hk_tmp:[Gauss]
    mmm_Fe1=mmFe1;
    mmm_Fe2=mmFe2;
    mmm_Fe3=mmFe3;

    mmm_Gd1=mmGd1;
    mmm_Gd2=mmGd2;
    mmm_Gd3=mmGd3;

    [hh_Fe1,hh_Fe2,hh_Fe3,sttdlt_Fe,sttflt_Fe,sotdlt_Fe,sotflt_Fe,hh_Gd1,hh_Gd2,hh_Gd3,sttdlt_Gd,sttflt_Gd...
        ,sotdlt_Gd,sotflt_Gd]=field_eta(hk6,mmm_Fe1,mmm_Fe2,mmm_Fe3,mmm_Gd1,mmm_Gd2,mmm_Gd3,Hk_Fe_z,Hk_Gd_z,Hk_Fe_x,Hk_Gd_x,Demag_,Hext_pulse(1,:,ct1),jc_STT,...
        tFL,Ms_Fe,Ms_Gd,facFLT_SHE,K12Dipole,mmmPL,PolFL,LFL,WFL,facFLT_STT,...
        thetaSH,tHM,lambdaSF,jc_SOTpulse(1,ct1),TT,alp,tstep,thermalnois,Hex_1,Hex_2,Hk_Fe_y,Hk_Gd_y,jc_SOT2,DMI);
    [dmdt_Fe1,AA,AB,BA,BB,CA,CB,Heffective]=LLG_solver(alp,mmm_Fe1,hh_Fe1,polSOTD_Fe,polSOTF_Fe,PolSTT,sttdlt_Fe,sttflt_Fe,sotdlt_Fe,sotflt_Fe);
    dmdt_Fe2=LLG_solver(alp,mmm_Fe2,hh_Fe2,polSOTD_Fe,polSOTF_Fe,PolSTT,sttdlt_Fe,sttflt_Fe,sotdlt_Fe,sotflt_Fe);
    dmdt_Fe3=LLG_solver(alp,mmm_Fe3,hh_Fe3,polSOTD_Fe,polSOTF_Fe,PolSTT,sttdlt_Fe,sttflt_Fe,sotdlt_Fe,sotflt_Fe);
    dmdt_Gd1=LLG_solver(alp,mmm_Gd1,hh_Gd1,polSOTD_Gd,polSOTF_Gd,PolSTT,sttdlt_Gd,sttflt_Gd,sotdlt_Gd,sotflt_Gd);
    dmdt_Gd2=LLG_solver(alp,mmm_Gd2,hh_Gd2,polSOTD_Gd,polSOTF_Gd,PolSTT,sttdlt_Gd,sttflt_Gd,sotdlt_Gd,sotflt_Gd);
    dmdt_Gd3=LLG_solver(alp,mmm_Gd3,hh_Gd3,polSOTD_Gd,polSOTF_Gd,PolSTT,sttdlt_Gd,sttflt_Gd,sotdlt_Gd,sotflt_Gd);
    kk1_Fe1=scal*dmdt_Fe1;
    kk1_Fe2=scal*dmdt_Fe2;
    kk1_Fe3=scal*dmdt_Fe3;
    kk1_Gd1=scal*dmdt_Gd1;
    kk1_Gd2=scal*dmdt_Gd2;
    kk1_Gd3=scal*dmdt_Gd3;

    mmm_Fe1=mmFe1+kk1_Fe1*ts1/2;
    mmm_Fe2=mmFe2+kk1_Fe2*ts1/2;
    mmm_Fe3=mmFe3+kk1_Fe3*ts1/2;

    mmm_Gd1=mmGd1+kk1_Gd1*ts1/2;
    mmm_Gd2=mmGd2+kk1_Gd2*ts1/2;
    mmm_Gd3=mmGd3+kk1_Gd3*ts1/2;
    
    [hh_Fe1,hh_Fe2,hh_Fe3,sttdlt_Fe,sttflt_Fe,sotdlt_Fe,sotflt_Fe,hh_Gd1,hh_Gd2,hh_Gd3,sttdlt_Gd,sttflt_Gd...
        ,sotdlt_Gd,sotflt_Gd]=field_eta(hk6,mmm_Fe1,mmm_Fe2,mmm_Fe3,mmm_Gd1,mmm_Gd2,mmm_Gd3,Hk_Fe_z,Hk_Gd_z,Hk_Fe_x,Hk_Gd_x,Demag_,Hext_pulse(1,:,ct1),jc_STT,...
        tFL,Ms_Fe,Ms_Gd,facFLT_SHE,K12Dipole,mmmPL,PolFL,LFL,WFL,facFLT_STT,...
        thetaSH,tHM,lambdaSF,jc_SOTpulse(1,ct1),TT,alp,tstep,thermalnois,Hex_1,Hex_2,Hk_Fe_y,Hk_Gd_y,jc_SOT2,DMI);
    [dmdt_Fe1,AA,AB,BA,BB,CA,CB,Heffective]=LLG_solver(alp,mmm_Fe1,hh_Fe1,polSOTD_Fe,polSOTF_Fe,PolSTT,sttdlt_Fe,sttflt_Fe,sotdlt_Fe,sotflt_Fe);
    dmdt_Fe2=LLG_solver(alp,mmm_Fe2,hh_Fe2,polSOTD_Fe,polSOTF_Fe,PolSTT,sttdlt_Fe,sttflt_Fe,sotdlt_Fe,sotflt_Fe);
    dmdt_Fe3=LLG_solver(alp,mmm_Fe3,hh_Fe3,polSOTD_Fe,polSOTF_Fe,PolSTT,sttdlt_Fe,sttflt_Fe,sotdlt_Fe,sotflt_Fe);
    dmdt_Gd1=LLG_solver(alp,mmm_Gd1,hh_Gd1,polSOTD_Gd,polSOTF_Gd,PolSTT,sttdlt_Gd,sttflt_Gd,sotdlt_Gd,sotflt_Gd);
    dmdt_Gd2=LLG_solver(alp,mmm_Gd2,hh_Gd2,polSOTD_Gd,polSOTF_Gd,PolSTT,sttdlt_Gd,sttflt_Gd,sotdlt_Gd,sotflt_Gd);
    dmdt_Gd3=LLG_solver(alp,mmm_Gd3,hh_Gd3,polSOTD_Gd,polSOTF_Gd,PolSTT,sttdlt_Gd,sttflt_Gd,sotdlt_Gd,sotflt_Gd);
    kk2_Fe1=scal*dmdt_Fe1;
    kk2_Fe2=scal*dmdt_Fe2;
    kk2_Fe3=scal*dmdt_Fe3;
    kk2_Gd1=scal*dmdt_Gd1;
    kk2_Gd2=scal*dmdt_Gd2;
    kk2_Gd3=scal*dmdt_Gd3;
   
    mmm_Fe1=mmFe1+kk2_Fe1*ts1/2;
    mmm_Fe2=mmFe2+kk2_Fe2*ts1/2;
    mmm_Fe3=mmFe3+kk2_Fe3*ts1/2;

    mmm_Gd1=mmGd1+kk2_Gd1*ts1/2;
    mmm_Gd2=mmGd2+kk2_Gd2*ts1/2;
    mmm_Gd3=mmGd3+kk2_Gd3*ts1/2;

    [hh_Fe1,hh_Fe2,hh_Fe3,sttdlt_Fe,sttflt_Fe,sotdlt_Fe,sotflt_Fe,hh_Gd1,hh_Gd2,hh_Gd3,sttdlt_Gd,sttflt_Gd...
        ,sotdlt_Gd,sotflt_Gd]=field_eta(hk6,mmm_Fe1,mmm_Fe2,mmm_Fe3,mmm_Gd1,mmm_Gd2,mmm_Gd3,Hk_Fe_z,Hk_Gd_z,Hk_Fe_x,Hk_Gd_x,Demag_,Hext_pulse(1,:,ct1),jc_STT,...
        tFL,Ms_Fe,Ms_Gd,facFLT_SHE,K12Dipole,mmmPL,PolFL,LFL,WFL,facFLT_STT,...
        thetaSH,tHM,lambdaSF,jc_SOTpulse(1,ct1),TT,alp,tstep,thermalnois,Hex_1,Hex_2,Hk_Fe_y,Hk_Gd_y,jc_SOT2,DMI);
    [dmdt_Fe1,AA,AB,BA,BB,CA,CB,Heffective]=LLG_solver(alp,mmm_Fe1,hh_Fe1,polSOTD_Fe,polSOTF_Fe,PolSTT,sttdlt_Fe,sttflt_Fe,sotdlt_Fe,sotflt_Fe);
    dmdt_Fe2=LLG_solver(alp,mmm_Fe2,hh_Fe2,polSOTD_Fe,polSOTF_Fe,PolSTT,sttdlt_Fe,sttflt_Fe,sotdlt_Fe,sotflt_Fe);
    dmdt_Fe3=LLG_solver(alp,mmm_Fe3,hh_Fe3,polSOTD_Fe,polSOTF_Fe,PolSTT,sttdlt_Fe,sttflt_Fe,sotdlt_Fe,sotflt_Fe);
    dmdt_Gd1=LLG_solver(alp,mmm_Gd1,hh_Gd1,polSOTD_Gd,polSOTF_Gd,PolSTT,sttdlt_Gd,sttflt_Gd,sotdlt_Gd,sotflt_Gd);
    dmdt_Gd2=LLG_solver(alp,mmm_Gd2,hh_Gd2,polSOTD_Gd,polSOTF_Gd,PolSTT,sttdlt_Gd,sttflt_Gd,sotdlt_Gd,sotflt_Gd);
    dmdt_Gd3=LLG_solver(alp,mmm_Gd3,hh_Gd3,polSOTD_Gd,polSOTF_Gd,PolSTT,sttdlt_Gd,sttflt_Gd,sotdlt_Gd,sotflt_Gd);
    kk3_Fe1=scal*dmdt_Fe1;
    kk3_Fe2=scal*dmdt_Fe2;
    kk3_Fe3=scal*dmdt_Fe3;
    kk3_Gd1=scal*dmdt_Gd1;
    kk3_Gd2=scal*dmdt_Gd2;
    kk3_Gd3=scal*dmdt_Gd3;
    
    mmm_Fe1=mmFe1+kk3_Fe1*ts1;
    mmm_Fe2=mmFe2+kk3_Fe2*ts1;
    mmm_Fe3=mmFe3+kk3_Fe3*ts1;

    mmm_Gd1=mmGd1+kk3_Gd1*ts1;
    mmm_Gd2=mmGd2+kk3_Gd2*ts1;
    mmm_Gd3=mmGd3+kk3_Gd3*ts1;

    [hh_Fe1,hh_Fe2,hh_Fe3,sttdlt_Fe,sttflt_Fe,sotdlt_Fe,sotflt_Fe,hh_Gd1,hh_Gd2,hh_Gd3,sttdlt_Gd,sttflt_Gd...
        ,sotdlt_Gd,sotflt_Gd]=field_eta(hk6,mmm_Fe1,mmm_Fe2,mmm_Fe3,mmm_Gd1,mmm_Gd2,mmm_Gd3,Hk_Fe_z,Hk_Gd_z,Hk_Fe_x,Hk_Gd_x,Demag_,Hext_pulse(1,:,ct1),jc_STT,...
        tFL,Ms_Fe,Ms_Gd,facFLT_SHE,K12Dipole,mmmPL,PolFL,LFL,WFL,facFLT_STT,...
        thetaSH,tHM,lambdaSF,jc_SOTpulse(1,ct1),TT,alp,tstep,thermalnois,Hex_1,Hex_2,Hk_Fe_y,Hk_Gd_y,jc_SOT2,DMI);
    [dmdt_Fe1,AA,AB,BA,BB,CA,CB,Heffective]=LLG_solver(alp,mmm_Fe1,hh_Fe1,polSOTD_Fe,polSOTF_Fe,PolSTT,sttdlt_Fe,sttflt_Fe,sotdlt_Fe,sotflt_Fe);
    dmdt_Fe2=LLG_solver(alp,mmm_Fe2,hh_Fe2,polSOTD_Fe,polSOTF_Fe,PolSTT,sttdlt_Fe,sttflt_Fe,sotdlt_Fe,sotflt_Fe);
    dmdt_Fe3=LLG_solver(alp,mmm_Fe3,hh_Fe3,polSOTD_Fe,polSOTF_Fe,PolSTT,sttdlt_Fe,sttflt_Fe,sotdlt_Fe,sotflt_Fe);
    dmdt_Gd1=LLG_solver(alp,mmm_Gd1,hh_Gd1,polSOTD_Gd,polSOTF_Gd,PolSTT,sttdlt_Gd,sttflt_Gd,sotdlt_Gd,sotflt_Gd);
    dmdt_Gd2=LLG_solver(alp,mmm_Gd2,hh_Gd2,polSOTD_Gd,polSOTF_Gd,PolSTT,sttdlt_Gd,sttflt_Gd,sotdlt_Gd,sotflt_Gd);
    dmdt_Gd3=LLG_solver(alp,mmm_Gd3,hh_Gd3,polSOTD_Gd,polSOTF_Gd,PolSTT,sttdlt_Gd,sttflt_Gd,sotdlt_Gd,sotflt_Gd);
    kk4_Fe1=scal*dmdt_Fe1;
    kk4_Fe2=scal*dmdt_Fe2;
    kk4_Fe3=scal*dmdt_Fe3;
    kk4_Gd1=scal*dmdt_Gd1;
    kk4_Gd2=scal*dmdt_Gd2;
    kk4_Gd3=scal*dmdt_Gd3;

    A1(:,:,ct1+1)=AA;  B1(:,:,ct1+1)=AB; C1(:,:,ct1+1)=BA; D1(:,:,ct1+1)=BB;E1(:,:,ct1+1)=CA; F1(:,:,ct1+1)=CB; Heffective1(:,:,ct1+1)=Heffective;
    mnFe1=mmFe1+ts1/6*(kk1_Fe1+2*kk2_Fe1+2*kk3_Fe1+kk4_Fe1);
    mnFe2=mmFe2+ts1/6*(kk1_Fe2+2*kk2_Fe2+2*kk3_Fe2+kk4_Fe2);
    mnFe3=mmFe3+ts1/6*(kk1_Fe3+2*kk2_Fe3+2*kk3_Fe3+kk4_Fe3);

    mnGd1=mmGd1+ts1/6*(kk1_Gd1+2*kk2_Gd1+2*kk3_Gd1+kk4_Gd1);
    mnGd2=mmGd2+ts1/6*(kk1_Gd2+2*kk2_Gd2+2*kk3_Gd2+kk4_Gd2);
    mnGd3=mmGd3+ts1/6*(kk1_Gd3+2*kk2_Gd3+2*kk3_Gd3+kk4_Gd3);
    mnFe1=mnFe1/norm(mnFe1);
    mnFe2=mnFe2/norm(mnFe2);
    mnFe3=mnFe3/norm(mnFe3);
    mnGd1=mnGd1/norm(mnGd1);
    mnGd2=mnGd2/norm(mnGd2);
    mnGd3=mnGd3/norm(mnGd3);

    mmx(ct1+1,1)=mnFe1(1);mmy(ct1+1,1)=mnFe1(2);mmz(ct1+1,1)=mnFe1(3);
    mmx(ct1+1,2)=mnFe2(1);mmy(ct1+1,2)=mnFe2(2);mmz(ct1+1,2)=mnFe2(3);
    mmx(ct1+1,3)=mnFe3(1);mmy(ct1+1,3)=mnFe3(2);mmz(ct1+1,3)=mnFe3(3);
    mmx(ct1+1,4)=mnGd1(1);mmy(ct1+1,4)=mnGd1(2);mmz(ct1+1,4)=mnGd1(3);
    mmx(ct1+1,5)=mnGd2(1);mmy(ct1+1,5)=mnGd2(2);mmz(ct1+1,5)=mnGd2(3);
    mmx(ct1+1,6)=mnGd3(1);mmy(ct1+1,6)=mnGd3(2);mmz(ct1+1,6)=mnGd3(3);
    
    if mod(ct1,tstepcount)==0%      
        A=[(t(ct1))*1e12;mmx(ct1+1,1);mmy(ct1+1,1);mmz(ct1+1,1);mmx(ct1+1,2);mmy(ct1+1,2);mmz(ct1+1,2)];
       fileID = fopen('result.txt','a');
        fprintf(fileID,'%4.4f %8.4f %12.4f %16.4f %20.4f %24.4f %28.4f\n',A);
        fclose(fileID);
    end
    
    ct1=ct1+1;
end
if dimensionlessLLG
    tt=t/tau_c*1e9;%unit[ns]
else
    tt=t;
end
mmx_tmp=mmx(1:savestep:end,:);
mmy_tmp=mmy(1:savestep:end,:);
mmz_tmp=mmz(1:savestep:end,:);
tt_tmp=tt(1:savestep:end);
clear mmx mmy mmz tt t
mmx=mmx_tmp;mmy=mmy_tmp;mmz=mmz_tmp;tt=tt_tmp;
clear mmx_tmp mmy_tmp mmz_tmp tt_tmp A1 B1 C1 D1 E1 F1