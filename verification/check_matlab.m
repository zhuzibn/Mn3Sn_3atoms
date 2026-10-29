function check_matlab(root)
% Validate the actual MATLAB integrator in isolated source copies.
% root is an absolute output directory prepared by run_checks.py.
original=pwd;
cleanup=onCleanup(@() cd(original));
orders=struct();
for damping=[0 .1]
for legacy=0:1
    folder=fullfile(root,sprintf('analytical_%d',legacy));
    errors=zeros(1,4);
    for k=1:4
        cd(folder);
        errors(k)=precession(10*2^(k-1),damping);
    end
    order=log2(errors(1:end-1)./errors(2:end));
    fprintf('Precession damping=%g legacy=%d errors=%s orders=%s\n',damping,legacy,mat2str(errors,12),mat2str(order,8));
    if legacy==0
        assert(all(order>3.8 & order<4.2),'Corrected integrator is not fourth order');
    else
        assert(any(order<3.8),'Archived defect unexpectedly passes');
    end
    orders.(sprintf('legacy%d_damping%d',legacy,round(damping*10)))=struct('damping',damping,'errors',errors,'orders',order);
end
end
names={'pilot','replay_pp','replay_pm','replay_mm','replay_mp','replay_275','replay_300','replay_1000p','replay_1000m'};
checks=struct();
for k=1:numel(names)
    folder=fullfile(root,names{k});
    if ~isfolder(folder), continue; end
    cd(folder);
    trajectory();
    a=readmatrix('matlab.csv'); b=readmatrix('diagnostic.csv');
    err=max(abs(a(:,3:20)-b(:,3:20)),[],'all');
    assert(err<1e-10,'MATLAB/C mismatch: %s',names{k});
    fprintf('PASS %s maximum spin error %.17g\n',names{k},err);
    checks.(names{k})=err;
end
fid=fopen(fullfile(root,'matlab-checks.json'),'w');
fprintf(fid,'%s\n',jsonencode(struct('precession',orders,'crosschecks',checks),PrettyPrint=true));
fclose(fid);
end

function error=precession(n,damping)
initialize;
alp=damping; hk6=0; Hex_1=0; Hex_2=0; DMI=0;
tstep=(1+alp^2)/(gam*n); runtime=n*tstep; totstep=n+1;
savestep=1; tstepcount=Inf;
Hext_pulse=repmat([0,0,1],1,1,totstep);
jc_SOTpulse=zeros(1,totstep);
ma_init1=[1,0,0]; ma_init2=ma_init1; ma_init3=ma_init1;
mb_init1=ma_init1; mb_init2=ma_init1; mb_init3=ma_init1;
rk4_4llg;
exact=[cos(1)*sech(alp),sin(1)*sech(alp),tanh(alp)];
error=max(abs([mmx(end,:)',mmy(end,:)',mmz(end,:)']-exact),[],'all');
end

function trajectory()
initialize;
if isfile('seed.csv')
    m=readmatrix('seed.csv');
    ma_init1=m(1,:); ma_init2=m(2,:); ma_init3=m(3,:);
    mb_init1=m(4,:); mb_init2=m(5,:); mb_init3=m(6,:);
end
rk4_4llg;
writematrix([tt(:),(0:savestep:totstep-1)'*tstep,mmx,mmy,mmz],'matlab.csv');
end
