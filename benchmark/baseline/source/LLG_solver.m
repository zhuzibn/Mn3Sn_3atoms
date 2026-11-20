%% LLG equation with precession term, damping term, spin current
% usage: add path which contain this file, call the function
% don't create the same function in new project 
%1.alp:damping constant,value
%2.mmm:magnetization, 1-by-3 matrix
%3.hh:effective field, 1-by-3 matrix
%4.pSOT:SOT polarization, 1-by-3 matrix
%5.pSTT:STT polarization, 1-by-3 matrix
%6.sttdlt:strength of STT DLT,value
%7.sttflt:strength of STT DLT,value
%8.sotdlt:strength of STT DLT,value
%9.sotflt:strength of STT DLT,value
function [dmdt,AA,AB,BA,BB,CA,CB,Heffctive]=LLG_solver(alp,mmm,hh,pSOTD,pSOTF,pSTT,sttdlt,sttflt,sotdlt,sotflt)
% call this function by feval(@(t,m) LLG_solver(t,m,Hk,alpha),t0,m0)
% t0 is the initial value of t
% m0 is the initial value of m
%     hh(:,2,:)=0;
    dmdt=-cross(mmm,hh)-alp*cross(mmm,cross(mmm,hh))-...
    sttdlt*cross(mmm,cross(mmm,pSTT))+alp*sttdlt*cross(mmm,pSTT)+...
    sttflt*cross(mmm,pSTT)+alp*sttflt*cross(mmm,cross(mmm,pSTT))-...
    sotdlt*cross(mmm,cross(mmm,pSOTD))+alp*sotdlt*cross(mmm,pSOTD)+...
    sotflt*cross(mmm,pSOTF)+alp*sotflt*cross(mmm,cross(mmm,pSOTF));
    
    Heffctive=hh;
    AA=-cross(mmm,hh);
    AB=-alp*cross(mmm,cross(mmm,hh));
    BB=sotflt*cross(mmm,pSOTF);
    BA=alp*sotflt*cross(mmm,cross(mmm,pSOTF));
    CA=-sotdlt*cross(mmm,cross(mmm,pSOTD));
    CB=alp*sotdlt*cross(mmm,pSOTD);
end

