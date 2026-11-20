function report = prepare_reference(output_dir, action, repetition)
%PREPARE_REFERENCE Capture a reviewable proposal from unchanged legacy sources.
% prepare_reference(new_folder) prepares, captures twice, and verifies.
% Separate processes may capture repetitions 1 and 2 after action='prepare'.
% action='verify' writes a proposal manifest only after both repeats pass.
% No action accepts a baseline or writes benchmark/baseline.
if nargin<2, action='all'; end
if nargin<3, repetition=[]; end
assert(ischar(output_dir) && isrow(output_dir) && ~isempty(output_dir), ...
    'Mn3SnReference:Path','output_dir must be a nonempty character path.');
assert(ismember(action,{'all','prepare','capture','verify'}), ...
    'Mn3SnReference:Action','Unknown reference action.');
repo=fileparts(fileparts(mfilename('fullpath')));
output_dir=canonical(output_dir);
% Keep proposals separate from accepted references and existing historical runs.
assert(strcmpi(fileparts(output_dir),canonical(fullfile(repo,'.sisyphus'))), ...
    'Mn3SnReference:Path','Proposals must be direct children of .sisyphus.');
[~,name]=fileparts(output_dir);
assert(startsWith(name,'cq-reference-proposal-'), ...
    'Mn3SnReference:Path','Use a fresh cq-reference-proposal-* directory.');
report=[];
if ismember(action,{'all','prepare'}), prepare(repo,output_dir); end
if strcmp(action,'all')
    capture(output_dir,1); capture(output_dir,2);
    report=verify(output_dir);
elseif strcmp(action,'capture')
    assert(isscalar(repetition) && ismember(repetition,[1,2]), ...
        'Mn3SnReference:Repetition','repetition must be 1 or 2.');
    capture(output_dir,repetition);
elseif strcmp(action,'verify')
    report=verify(output_dir);
end
end

function prepare(repo,root)
assert(~isfile(root) && ~isfolder(root), ...
    'Mn3SnReference:Exists','Destination already exists: %s',root);
history=fullfile(repo,'.sisyphus','rk4-verification-20261029');
old_hashes=jsondecode(fileread(fullfile(history,'source-hashes.json')));
names=source_names();
for k=1:numel(names)
    key=matlab.lang.makeValidName(names{k});
    assert(isfield(old_hashes,key) && ...
        strcmp(sha256(fullfile(repo,names{k})),old_hashes.(key)), ...
        'Mn3SnReference:ChangedSource','Pre-migration source changed: %s',names{k});
end
cases=regression_cases();
source=normalized_text(fullfile(repo,'main.m'));
prefix=split(source,sprintf('\nrk4_4llg();'));
assert(numel(prefix)==2,'Mn3SnReference:SourceLayout','Expected one RK4 call.');
init=replace_once(prefix{1},'clear ;clc;close all;','');
init=replace_once(init,sprintf('\ntic\n'),sprintf('\n'));
% Verify every historical fixture before creating any proposal output.
initializers=cell(1,numel(cases));
for k=1:numel(cases)
    c=cases(k); s=init;
    if k<=9
        s=replace_once(s,'runtime=5000e-12;','runtime=20e-12;');
        s=replace_once(s,'starttime=1000e-12;','starttime=0;');
        s=replace_once(s,'pulsewidth=3000e-12;','pulsewidth=runtime;');
        s=replace_once(s,'Hext=[0,0.0250,0];',sprintf('Hext=[0,%.17g,0];',c.field_T));
        s=replace_once(s,'jc_SOT=50e9;',sprintf('jc_SOT=%.17g;',c.current_Apm2));
        assert(strcmp(s,normalized_text(fullfile(history,c.name,'initialize.m'))), ...
            'Mn3SnReference:Fixture','Historical initialization differs: %s',c.name);
        assert(isfile(fullfile(history,c.name,'matlab.csv')) && ...
            isfile(fullfile(history,c.name,'diagnostic.csv')), ...
            'Mn3SnReference:MissingFixture','Missing historical arrays: %s',c.name);
        if ~isempty(c.seed_file)
            seed=readmatrix(fullfile(history,c.name,c.seed_file));
            assert(isequal(size(seed),[6,3]) && all(isfinite(seed),'all'), ...
                'Mn3SnReference:Seed','Invalid fixed seed: %s',c.name);
        end
    elseif k==10
        s=replace_once(s,'runtime=5000e-12;','runtime=20e-12;');
        s=replace_once(s,'starttime=1000e-12;','starttime=5e-12;');
        s=replace_once(s,'pulsewidth=3000e-12;','pulsewidth=10e-12;');
    end
    initializers{k}=s;
end
[ok,msg]=mkdir(root); assert(ok,'Mn3SnReference:Create','%s',msg);
mkdir(fullfile(root,'source')); mkdir(fullfile(root,'fixtures'));
for k=1:numel(names), copyfile(fullfile(repo,names{k}),fullfile(root,'source',names{k})); end
copyfile(fullfile(repo,'SOURCE_SHA256SUMS'),fullfile(root,'source','SOURCE_SHA256SUMS'));
copyfile(fullfile(history,'source-hashes.json'),fullfile(root,'historical-source-hashes.json'));
for k=1:numel(cases)
    c=cases(k); dest=fullfile(root,'fixtures',c.name); mkdir(dest);
    write_text(fullfile(dest,'initialize.m'),initializers{k});
    if c.historical
        copyfile(fullfile(history,c.name,'matlab.csv'),fullfile(dest,'historical-matlab.csv'));
        copyfile(fullfile(history,c.name,'diagnostic.csv'),fullfile(dest,'historical-diagnostic.csv'));
    end
    if ~isempty(c.seed_file)
        copyfile(fullfile(history,c.name,c.seed_file),fullfile(dest,c.seed_file));
    end
end
mkdir(fullfile(root,'tools'));
for name={'prepare_reference.m','regression_cases.m'}
    copyfile(fullfile(repo,'benchmark',name{1}),fullfile(root,'tools',name{1}));
end
[git_status,git_head]=system(sprintf('git -C "%s" rev-parse HEAD',repo));
[dirty_status,dirty]=system(sprintf('git -C "%s" status --short',repo));
metadata=struct('schema',1,'status','proposal-unaccepted','created_utc',utc_now(), ...
    'repo',repo,'git_probe_status',git_status,'git_head',strtrim(git_head), ...
    'working_tree_probe_status',dirty_status,'working_tree_status',dirty, ...
    'cases',cases,'files',file_manifest(root));
write_json(fullfile(root,'preparation.json'),metadata);
fprintf('Prepared unchanged sources and %d fixtures in %s\n',numel(cases),root);
end

function capture(root,repetition)
metadata=check_preparation(root);
dest=fullfile(root,sprintf('repeat-%d',repetition));
assert(~isfolder(dest) && ~isfile(dest),'Mn3SnReference:Exists', ...
    'Repetition destination exists; choose a new proposal, do not overwrite.');
mkdir(dest);
old=pwd; cleanup=onCleanup(@() cd(old));
cases=metadata.cases;
for k=1:numel(cases)
    c=cases(k); folder=fullfile(dest,c.name); mkdir(folder);
    copyfile(fullfile(root,'source','*.m'),folder);
    copyfile(fullfile(root,'fixtures',c.name,'initialize.m'),folder);
    if ~isempty(c.seed_file), copyfile(fullfile(root,'fixtures',c.name,c.seed_file),folder); end
    check_case_files(root,c,folder);
    cd(folder);
    for source={'main','field_eta','LLG_solver','rk4_4llg','pulsee','Hpulsee','conf_file','constantfile','initialize'}
        assert(strcmpi(canonical(which(source{1})),canonical(fullfile(folder,[source{1},'.m']))), ...
            'Mn3SnReference:Shadowed','Unexpected function resolution: %s',source{1});
    end
    inputs=legacy_inputs();
    check_case_inputs(inputs,c);
    rng_before=rng;
    started=utc_now(); timer=tic;
    fprintf('START repeat %d / %s at %s\n',repetition,c.name,started);
    if strcmp(c.name,'default_5ns'), raw=execute_main(); else, raw=execute_fixture(); end
    elapsed=toc(timer);
    check_case_files(root,c,folder);
    reference=struct('schema',1,'case',c,'inputs',inputs, ...
        'initial_m',[inputs.ma_init1;inputs.ma_init2;inputs.ma_init3; ...
                     inputs.mb_init1;inputs.mb_init2;inputs.mb_init3], ...
        'state_order',{{'ma1','ma2','ma3','mb1','mb2','mb3'}}, ...
        'component_order',{{'x','y','z'}},'time_unit','s', ...
        'mmx',raw.mmx,'mmy',raw.mmy,'mmz',raw.mmz,'legacy_tt',raw.tt, ...
        'sample_index',1:inputs.savestep:inputs.totstep, ...
        'runtime',struct('matlab',version,'release',version('-release'), ...
            'computer',computer,'toolboxes',ver,'rng_before',rng_before, ...
            'rng_after',rng,'started_utc',started,'elapsed_s',elapsed), ...
        'text_sha256',sha256('result.txt'));
    reference.time_s=(reference.sample_index-1)*inputs.tstep;
    validate_reference(reference);
    save('reference.mat','reference','-v7');
    fprintf('PASS repeat %d / %s: %d samples, %.3f s\n', ...
        repetition,c.name,size(raw.mmx,1),elapsed);
    cd(old);
end
write_json(fullfile(dest,'capture-complete.json'),struct('completed_utc',utc_now(), ...
    'repetition',repetition,'cases',{cellstr(string({cases.name}))}));
end

function inputs=legacy_inputs()
initialize;
if isfile('seed.csv')
    cq_seed=readmatrix('seed.csv');
    ma_init1=cq_seed(1,:); ma_init2=cq_seed(2,:); ma_init3=cq_seed(3,:);
    mb_init1=cq_seed(4,:); mb_init2=cq_seed(5,:); mb_init3=cq_seed(6,:);
end
cq_names=who; inputs=struct();
for cq_k=1:numel(cq_names)
    cq_name=cq_names{cq_k};
    if ~startsWith(cq_name,'cq_'), inputs.(cq_name)=eval(cq_name); end
end
end

function raw=execute_fixture()
initialize;
if isfile('seed.csv')
    cq_seed=readmatrix('seed.csv');
    ma_init1=cq_seed(1,:); ma_init2=cq_seed(2,:); ma_init3=cq_seed(3,:);
    mb_init1=cq_seed(4,:); mb_init2=cq_seed(5,:); mb_init3=cq_seed(6,:);
end
rk4_4llg;
raw=struct('tt',tt,'mmx',mmx,'mmy',mmy,'mmz',mmz);
end

function raw=execute_main()
% main clears this private function workspace, but not the outer driver.
main;
raw=struct('tt',tt,'mmx',mmx,'mmy',mmy,'mmz',mmz);
end

function report=verify(root)
metadata=check_preparation(root);
assert(~isfile(fullfile(root,'proposal-manifest.json')), ...
    'Mn3SnReference:Exists','Verification manifest already exists.');
cases=metadata.cases; results=struct([]);
for repeat=1:2
    done=jsondecode(fileread(fullfile(root,sprintf('repeat-%d',repeat),'capture-complete.json')));
    assert(isequal(string(done.cases(:)),string({cases.name})'), ...
        'Mn3SnReference:Inventory','Incomplete capture inventory.');
end
for k=1:numel(cases)
    c=cases(k);
    for repetition=1:2
        check_case_files(root,c,fullfile(root,sprintf('repeat-%d',repetition),c.name));
    end
    a=load(fullfile(root,'repeat-1',c.name,'reference.mat'),'reference'); a=a.reference;
    b=load(fullfile(root,'repeat-2',c.name,'reference.mat'),'reference'); b=b.reference;
    validate_reference(a); validate_reference(b);
    assert(isequaln(a.inputs,b.inputs) && isequal(a.case,c) && isequal(b.case,c), ...
        'Mn3SnReference:Inputs','Incompatible inputs: %s',c.name);
    err=max(abs([a.mmx,a.mmy,a.mmz]-[b.mmx,b.mmy,b.mmz]),[],'all');
    assert(err<1e-10,'Mn3SnReference:Repeat','Nonrepeatable trajectory: %s',c.name);
    check_clock(a.time_s,b.time_s); check_clock(a.legacy_tt,b.legacy_tt);
    assert(strcmp(a.text_sha256,sha256(fullfile(root,'repeat-1',c.name,'result.txt'))) && ...
        strcmp(b.text_sha256,sha256(fullfile(root,'repeat-2',c.name,'result.txt'))) && ...
        strcmp(a.text_sha256,b.text_sha256), ...
        'Mn3SnReference:Text','Text output differs between repeats: %s',c.name);
    r=struct('name',c.name,'samples',size(a.mmx,1),'repeat_spin_max_abs',err, ...
        'norm_max_abs',max(abs(sqrt(a.mmx.^2+a.mmy.^2+a.mmz.^2)-1),[],'all'), ...
        'historical_matlab_max_abs',[],'historical_c_max_abs',[], ...
        'elapsed_s',[a.runtime.elapsed_s,b.runtime.elapsed_s]);
    if c.historical
        for kind={'matlab','diagnostic'}
            old=readmatrix(fullfile(root,'fixtures',c.name,['historical-',kind{1},'.csv']));
            assert(isequal(size(old),[size(a.mmx,1),20]) && all(isfinite(old),'all'), ...
                'Mn3SnReference:Historical','Invalid historical array: %s',c.name);
            e=max(abs([a.mmx,a.mmy,a.mmz]-old(:,3:20)),[],'all');
            assert(e<1e-10,'Mn3SnReference:Historical','Historical mismatch: %s',c.name);
            check_clock(a.legacy_tt,old(:,1)); check_clock(a.time_s,old(:,2));
            if strcmp(kind{1},'matlab'), r.historical_matlab_max_abs=e;
            else, r.historical_c_max_abs=e; end
        end
    end
    if k==1, results=repmat(r,1,numel(cases)); else, results(k)=r; end
end
report=struct('schema',1,'status','verified-proposal-awaiting-user-acceptance', ...
    'verified_utc',utc_now(),'git_head',metadata.git_head,'cases',results, ...
    'files',file_manifest(root));
write_json(fullfile(root,'proposal-manifest.json'),report);
fprintf('PASS all %d cases, both repeats. Proposal NOT accepted: %s\n',numel(cases),root);
end

function validate_reference(r)
check_case_inputs(r.inputs,r.case);
n=round(r.inputs.runtime/r.inputs.tstep);
idx=1:r.inputs.savestep:n;
assert(isequal(r.sample_index,idx) && r.inputs.totstep==n, ...
    'Mn3SnReference:Sampling','Invalid step/sample count.');
for name={'mmx','mmy','mmz'}
    a=r.(name{1});
    assert(isreal(a) && isequal(size(a),[numel(idx),6]) && all(isfinite(a),'all'), ...
        'Mn3SnReference:Arrays','Malformed/nonfinite trajectory.');
end

assert(isequal([r.mmx(1,:)',r.mmy(1,:)',r.mmz(1,:)'],r.initial_m), ...
    'Mn3SnReference:Initial','First sample differs from initial inputs.');
assert(max(abs(sqrt(r.mmx.^2+r.mmy.^2+r.mmz.^2)-1),[],'all')<1e-12, ...
    'Mn3SnReference:Norm','Spin norm invariant failed.');
legacy=linspace(0,r.inputs.runtime,n);
check_clock(r.legacy_tt,legacy(idx)); check_clock(r.time_s,(idx-1)*r.inputs.tstep);
assert(isequal(r.runtime.rng_before,r.runtime.rng_after), ...
    'Mn3SnReference:RNG','Deterministic capture changed RNG state.');
assert(numel(r.inputs.jc_SOTpulse)==n && size(r.inputs.Hext_pulse,3)==n, ...
    'Mn3SnReference:Pulse','Pulse length disagrees with actual step count.');
end

function check_case_inputs(inputs,c)
assert(inputs.runtime==c.runtime_s && inputs.tstep==c.tstep_s && ...
    inputs.savestep==c.savestep && inputs.starttime==c.start_s && ...
    inputs.endtime==c.runtime_s && inputs.pulsewidth==c.width_s && ...
    inputs.Hstarttime==c.start_s && inputs.Hendtime==c.runtime_s && ...
    inputs.Hpulsewidth==c.width_s && inputs.risetime==0 && inputs.downtime==0 && ...
    isequal(inputs.Hext,[0,c.field_T,0]) && inputs.jc_SOT==c.current_Apm2, ...
    'Mn3SnReference:Inputs','Executed inputs differ from declared case: %s',c.name);
end

function check_case_files(root,c,folder)
for name=source_names()
    assert(strcmp(sha256(fullfile(folder,name{1})),sha256(fullfile(root,'source',name{1}))), ...
        'Mn3SnReference:Integrity','Execution source differs: %s/%s',c.name,name{1});
end
names={'initialize.m'};
if ~isempty(c.seed_file), names{end+1}=c.seed_file; end
for name=names
    assert(strcmp(sha256(fullfile(folder,name{1})), ...
        sha256(fullfile(root,'fixtures',c.name,name{1}))), ...
        'Mn3SnReference:Integrity','Execution fixture differs: %s/%s',c.name,name{1});
end
end

function check_clock(a,b)
assert(isreal(a) && isreal(b) && numel(a)==numel(b) && ...
    all(isfinite(a)) && all(isfinite(b)) && a(1)==0 && b(1)==0 && ...
    all(diff(a)>0) && all(diff(b)>0), ...
    'Mn3SnReference:Clock','Invalid clock.');
assert(max(abs(a(:)-b(:)))<=32*eps(max(abs(b))), ...
    'Mn3SnReference:Clock','Clock mismatch.');
end

function metadata=check_preparation(root)
metadata=jsondecode(fileread(fullfile(root,'preparation.json')));
assert(metadata.schema==1 && strcmp(metadata.status,'proposal-unaccepted'), ...
    'Mn3SnReference:Preparation','Invalid preparation record.');
expected=regression_cases();
assert(isequal(metadata.cases(:),expected(:)), ...
    'Mn3SnReference:Inventory','Preparation does not contain the fixed 11 cases.');
required={'historical-source-hashes.json','source/SOURCE_SHA256SUMS', ...
    'tools/prepare_reference.m','tools/regression_cases.m'};
for name=source_names(), required{end+1}=['source/',name{1}]; end
for k=1:numel(expected)
    c=expected(k); prefix=['fixtures/',c.name,'/'];
    required{end+1}=[prefix,'initialize.m'];
    if c.historical
        required(end+1:end+2)={[prefix,'historical-matlab.csv'],[prefix,'historical-diagnostic.csv']};
    end
    if ~isempty(c.seed_file), required{end+1}=[prefix,c.seed_file]; end
end
assert(isequal(sort(string({metadata.files.path})),sort(string(required))), ...
    'Mn3SnReference:Inventory','Incomplete or duplicated prepared source/fixture inventory.');
for k=1:numel(metadata.files)
    f=metadata.files(k);
    assert(strcmp(sha256(fullfile(root,f.path)),f.sha256), ...
        'Mn3SnReference:Integrity','Prepared source/fixture changed: %s',f.path);
end
for name={'prepare_reference.m','regression_cases.m'}
    assert(strcmp(sha256(fullfile(fileparts(mfilename('fullpath')),name{1})), ...
        sha256(fullfile(root,'tools',name{1}))), ...
        'Mn3SnReference:ToolChanged','Capture tool changed; prepare a new proposal.');
end
end

function names=source_names()
names={'main.m','conf_file.m','constantfile.m','rk4_4llg.m', ...
    'field_eta.m','LLG_solver.m','pulsee.m','Hpulsee.m', ...
    'datproc.m','FFT_module.m','theta_mtot.m'};
end

function files=file_manifest(root)
entries=dir(fullfile(root,'**','*')); files=struct('path',{},'sha256',{},'bytes',{});
for k=1:numel(entries)
    e=entries(k); if e.isdir, continue; end
    absolute=fullfile(e.folder,e.name); relative=absolute(numel(root)+2:end);
    files(end+1)=struct('path',strrep(relative,'\','/'), ...
        'sha256',sha256(absolute),'bytes',e.bytes);
end
end

function hash=sha256(path)
fid=fopen(path,'rb'); assert(fid>=0,'Mn3SnReference:Missing','Missing file: %s',path);
cleanup=onCleanup(@() fclose(fid));
md=java.security.MessageDigest.getInstance('SHA-256');
while ~feof(fid), md.update(fread(fid,1048576,'*uint8')); end
bytes=typecast(md.digest(),'uint8'); hash=lower(reshape(dec2hex(bytes,2).',1,[]));
end

function path=canonical(path)
path=char(java.io.File(path).getCanonicalPath());
end

function s=normalized_text(path)
fid=fopen(path,'rb'); assert(fid>=0,'Mn3SnReference:Missing','Missing file: %s',path);
cleanup=onCleanup(@() fclose(fid));
s=native2unicode(fread(fid,Inf,'*uint8')','UTF-8');
s=strrep(s,sprintf('\r\n'),sprintf('\n'));
end

function s=replace_once(s,old,new)
assert(numel(strfind(s,old))==1,'Mn3SnReference:SourceLayout', ...
    'Expected exactly one source marker: %s',old);
s=strrep(s,old,new);
end

function write_json(path,value)
write_text(path,[jsonencode(value,PrettyPrint=true),newline]);
end

function write_text(path,value)
assert(~isfile(path),'Mn3SnReference:Exists','Refusing to replace: %s',path);
fid=fopen(path,'wb'); assert(fid>=0,'Mn3SnReference:Write','Cannot write: %s',path);
cleanup=onCleanup(@() fclose(fid)); fwrite(fid,unicode2native(value,'UTF-8'),'uint8');
end

function s=utc_now()
s=char(datetime('now','TimeZone','UTC','Format','yyyy-MM-dd''T''HH:mm:ss.SSS''Z'''));
end
