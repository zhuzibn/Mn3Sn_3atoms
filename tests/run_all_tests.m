function report = run_all_tests(candidate)
%RUN_ALL_TESTS Focused interface, output, path and comparator acceptance checks.
repo=fileparts(fileparts(mfilename('fullpath')));
addpath(repo,fullfile(repo,'benchmark'));
root=fullfile(repo,'.sisyphus',['cq-tests-',char(java.util.UUID.randomUUID())]); mkdir(root);
if nargin<1, candidate=run_regression(fullfile(root,'quick'),'quick'); end
checks={}; cfg=mn3sn_default_config();
data=load(fullfile(repo,'benchmark','baseline','cases','default_5ns.mat'),'reference');
expected=reference_config(data.reference);
assert(isequal(cfg,expected)); checks{end+1}='exact original defaults';
names={'tstep','runtime','savestep','alp','Ms_Fe','initial_m','initial_m','Hext', ...
    'starttime','pulsewidth','risetime','solver','thermalnois','STT_DLT','jc_SOT2', ...
    'Hex_1','dimensionlessLLG','hk_constant','DMI_constant','alp','tFL', ...
    'runtime','tstep','Hext','savestep','SOT_DLT'};
values={0,NaN,1.5,-1,0,zeros(6,3),ones(3,6),[0,1i,0], ...
    -1,10e-9,4e-9,'euler',1,1,1,1,1,realmax,realmax,realmax,realmin*eps, ...
    1e-16,'5e-15',[0,Inf,0],Inf,2};
for k=1:numel(names)
    bad=cfg; bad.(names{k})=values{k};
    dest=fullfile(root,sprintf('invalid-%d',k));
    must_fail(@() mn3sn_run(bad,dest),'Mn3Sn:');
    assert(~isfolder(dest));
end
checks{end+1}='26 invalid values rejected before output/integration';
bad=cfg; bad.typo=1; must_fail(@() mn3sn_validate_config(bad),'Mn3Sn:UnknownField');
bad=rmfield(cfg,'tstep'); must_fail(@() mn3sn_validate_config(bad),'Mn3Sn:MissingField');
checks{end+1}='unknown and missing fields rejected';
cfg.runtime=2e-12; cfg.starttime=.5e-12; cfg.pulsewidth=1e-12; cfg.savestep=13;
r=mn3sn_run(cfg,fullfile(root,'tiny'));
saved=load(fullfile(r.output_dir,'final.mat')); assert(isequaln(r,saved.result));
assert(isequal(r.config,cfg) && isequal(r.initial_m,cfg.initial_m));
n=round(cfg.runtime/cfg.tstep); idx=1:cfg.savestep:n; labels=linspace(0,cfg.runtime,n);
assert(isequal(r.time_s,(idx-1)*cfg.tstep) && isequal(r.legacy_tt,labels(idx)));
assert(r.solver.integrated_end_s==(n-1)*cfg.tstep && r.solver.sampled_end_s==r.time_s(end));
text=readmatrix(r.text.file); q=cfg.savestep:cfg.savestep:n-1;
assert(max(abs(text(:,1)-labels(q)'*1e12))<=5e-5);
states=[r.mmx(2:end,1),r.mmy(2:end,1),r.mmz(2:end,1), ...
    r.mmx(2:end,2),r.mmy(2:end,2),r.mmz(2:end,2)];
assert(max(abs(text(:,2:7)-states),[],'all')<=5e-5);
assert(isequal(r.provenance.rng_before,r.provenance.rng_after));
for k=1:numel(r.provenance.sources)
    source=r.provenance.sources(k); assert(strcmp(mn3sn_sha256(source.path),source.sha256));
end
assert(r.provenance.git.head.exit_status==0 && ~isempty(r.provenance.git.head.output));
checks{end+1}='schema round trip, raw sampling/text clocks and actual provenance';
mat_hash=mn3sn_sha256(fullfile(r.output_dir,'final.mat')); text_hash=mn3sn_sha256(r.text.file);
must_fail(@() mn3sn_run(cfg,r.output_dir),'Mn3Sn:OutputExists');
assert(strcmp(mat_hash,mn3sn_sha256(fullfile(r.output_dir,'final.mat'))) && ...
    strcmp(text_hash,mn3sn_sha256(r.text.file)));
must_fail(@() mn3sn_run(cfg,fullfile(root,'missing-parent','run')),'Mn3Sn:InvalidOutput');
checks{end+1}='rejected outputs preserve files';
caller=fullfile(root,'caller'); mkdir(caller);
other=run_elsewhere(cfg,caller,fullfile(root,'other'));
assert(isequal(r.mmx,other.mmx) && isequal(r.mmy,other.mmy) && isequal(r.mmz,other.mmz));
relative=run_elsewhere(cfg,caller,'relative-output');
assert(strcmpi(relative.output_dir,mn3sn_resolve_path(fullfile(caller,'relative-output'))));
checks{end+1}='independent caller workspace/current directory';
off=cfg; off.SOT_DLT=0; disabled=mn3sn_run(off);
zero=cfg; zero.jc_SOT=0; no_current=mn3sn_run(zero);
assert(isequal(disabled.mmx,no_current.mmx) && isequal(disabled.mmy,no_current.mmy) && ...
    isequal(disabled.mmz,no_current.mmz) && ~strcmp(disabled.output_dir,no_current.output_dir));
checks{end+1}='explicit DLT override and distinct automatically allocated destinations';
shadow=fullfile(root,'shadow'); mkdir(shadow);
fid=fopen(fullfile(shadow,'mn3sn_validate_config.m'),'w');
fprintf(fid,'function mn3sn_validate_config(~)\nend\n'); fclose(fid);
must_fail(@() run_elsewhere(cfg,shadow,fullfile(root,'shadow-result')),'Mn3Sn:ShadowedSource');
assert(~isfolder(fullfile(root,'shadow-result')));
checks{end+1}='shadowed validator rejected before writes';
shadow=fullfile(root,'shadow-resolver'); mkdir(shadow);
fid=fopen(fullfile(shadow,'mn3sn_resolve_path.m'),'w');
fprintf(fid,'function p=mn3sn_resolve_path(p)\nend\n'); fclose(fid);
dest=fullfile(root,'shadow-resolver-result');
must_fail(@() run_elsewhere(cfg,shadow,dest),'Mn3Sn:ShadowedSource');
must_fail(@() benchmark_elsewhere(shadow,dest),'Mn3SnBenchmark:ShadowedSource');
assert(~isfolder(dest));
checks{end+1}='shadowed resolver rejected by both runners before writes';

target=fullfile(repo,'benchmark','baseline'); alias=fullfile(root,'baseline-alias');
if ispc
    [code,message]=system(sprintf('cmd /c mklink /J "%s" "%s"',alias,target));
else
    java.nio.file.Files.createSymbolicLink(java.io.File(alias).toPath(), ...
        java.io.File(target).toPath(),javaArray('java.nio.file.attribute.FileAttribute',0));
    code=0; message='';
end
assert(code==0,'Mn3SnTest:Alias','Cannot prepare alias test: %s',message);
% Read-only resolution check comes first so a broken guard cannot create data in references.
assert(strcmpi(mn3sn_resolve_path(alias),mn3sn_resolve_path(target)), ...
    'Mn3SnTest:Alias','Alias must resolve to the baseline.');
must_fail(@() mn3sn_run(cfg,fullfile(alias,'forbidden')),'Mn3Sn:ProtectedBaseline');
must_fail(@() run_regression(fullfile(alias,'forbidden'),'quick'),'Mn3SnBenchmark:Protected');
assert(~isfolder(fullfile(target,'forbidden')));
checks{end+1}='baseline alias rejected by production and candidate runners';

positive=compare_to_baseline(candidate,'quick'); assert(positive.passed);
mutations={'middle','clock','legacy_clock','missing_case','config','shape', ...
    'nan','norm','order','initial','text','metadata','units'};
for k=1:numel(mutations)
    copy=fullfile(root,['mutant-',mutations{k}]); copyfile(candidate,copy);
    filename=fullfile(copy,'pilot','final.mat'); load(filename,'result');
    row=round(size(result.mmx,1)/2);
    switch mutations{k}
        case 'middle'
            y=result.mmy(row,1); z=result.mmz(row,1); a=1e-4;
            result.mmy(row,1)=cos(a)*y-sin(a)*z; result.mmz(row,1)=sin(a)*y+cos(a)*z;
        case 'clock', result.time_s(row)=result.time_s(row)+result.config.tstep;
        case 'legacy_clock', result.legacy_tt(row)=result.legacy_tt(row)+result.config.tstep;
        case 'missing_case'
            inventory=jsondecode(fileread(fullfile(copy,'suite.json'))); inventory.cases(end)=[];
            fid=fopen(fullfile(copy,'suite.json'),'w'); fprintf(fid,'%s',jsonencode(inventory)); fclose(fid);
        case 'config', result.config.alp=result.config.alp*2;
        case 'shape', result.mmx(:,end)=[];
        case 'nan', result.mmx(row,1)=NaN;
        case 'norm', result.mmy(row,1)=1.001*result.mmy(row,1);
        case 'order', result.state_order=result.state_order([2,1,3:6]);
        case 'initial', result.initial_m(1,1)=0.1;
        case 'metadata', result.solver.updates=result.solver.updates+1;
        case 'units', result.units.field='A/m';
        case 'text'
            fid=fopen(fullfile(copy,'pilot','result.txt'),'a'); fprintf(fid,'bad\n'); fclose(fid);
    end
    save(filename,'result','-v7');
    must_fail(@() compare_to_baseline(copy,'quick'),'Mn3SnBenchmark:');
end
checks{end+1}='13 comparator corruptions rejected';
bad_root=fullfile(root,'bad-reference'); mkdir(bad_root);
copyfile(fullfile(repo,'benchmark','baseline_manifest.json'),bad_root);
copyfile(target,fullfile(bad_root,'baseline'));
fid=fopen(fullfile(bad_root,'baseline','cases','pilot.mat'),'a'); fprintf(fid,'bad'); fclose(fid);
must_fail(@() compare_to_baseline(candidate,'quick',fullfile(bad_root,'baseline')), ...
    'Mn3SnBenchmark:Integrity');
checks{end+1}='malformed baseline rejected without rewriting accepted files';
manifest_file=fullfile(bad_root,'baseline_manifest.json');
manifest=jsondecode(fileread(manifest_file));
pilot=find(strcmp({manifest.artifacts.baseline_path},'cases/pilot.mat'));
other=find(~strcmp({manifest.artifacts.baseline_path},'cases/pilot.mat'),1);
manifest.artifacts(pilot)=manifest.artifacts(other);
fid=fopen(manifest_file,'w'); fprintf(fid,'%s',jsonencode(manifest)); fclose(fid);
must_fail(@() read_baseline(fullfile(bad_root,'baseline')),'Mn3SnBenchmark:Inventory');
checks{end+1}='duplicated manifest entry cannot hide an unhashed reference';
report=struct('passed',true,'checks',{checks},'output_dir',root,'matlab',version);
fid=fopen(fullfile(root,'test-report.json'),'w'); fprintf(fid,'%s\n',jsonencode(report,PrettyPrint=true)); fclose(fid);
fprintf('PASS all focused tests; report: %s\n',fullfile(root,'test-report.json'));
end

function result=run_elsewhere(cfg,folder,destination)
old=pwd; cleanup=onCleanup(@() cd(old)); cd(folder);
alp=99; thermalnois=1; %#ok<NASGU> Deliberately unrelated caller variables.
result=mn3sn_run(cfg,destination);
end

function must_fail(action,prefix)
try
    action();
catch problem
    assert(startsWith(problem.identifier,prefix),'Mn3SnTest:WrongError', ...
        'Expected %s, got %s: %s',prefix,problem.identifier,problem.message);
    return;
end
error('Mn3SnTest:MissingError','Expected failure %s was not raised.',prefix);
end

function benchmark_elsewhere(folder,destination)
old=pwd; cleanup=onCleanup(@() cd(old)); cd(folder);
run_regression(destination,'quick');
end
