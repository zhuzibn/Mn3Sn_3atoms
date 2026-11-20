function output_dir = run_regression(output_dir,suite)
%RUN_REGRESSION Fresh candidates only; never creates or updates a baseline.
if nargin<2, suite='quick'; end
repo=fileparts(fileparts(mfilename('fullpath')));
assert(strcmpi(which('mn3sn_resolve_path'),fullfile(repo,'mn3sn_resolve_path.m')), ...
    'Mn3SnBenchmark:ShadowedSource','Unexpected mn3sn_resolve_path resolution.');
assert(ischar(suite) && ismember(suite,{'quick','extended'}), ...
    'Mn3SnBenchmark:Suite','suite must be quick or extended.');
[manifest,baseline]=read_baseline();
assert(ischar(output_dir) && isrow(output_dir) && ~isempty(output_dir), ...
    'Mn3SnBenchmark:Output','Specify a fresh output directory.');
output_dir=mn3sn_resolve_path(output_dir);
protected=mn3sn_resolve_path(baseline);
assert(~strcmpi(output_dir,protected) && ...
    ~startsWith(lower(output_dir),lower([protected,filesep])), ...
    'Mn3SnBenchmark:Protected','Cannot write candidates inside accepted references.');
assert(~isfolder(output_dir) && ~isfile(output_dir),'Mn3SnBenchmark:Exists','Candidate destination exists.');
assert(isfolder(fileparts(output_dir)) && java.io.File(output_dir).mkdir(), ...
    'Mn3SnBenchmark:Output','Cannot reserve fresh candidate directory.');
cases=manifest.cases(strcmp({manifest.cases.suite},suite));
for k=1:numel(cases)
    c=cases(k); data=load(fullfile(baseline,'cases',[c.name,'.mat']),'reference');
    if strcmp(c.name,'default_5ns')
        cfg=mn3sn_default_config(); % Test real defaults, not overrides hiding drift.
    else
        cfg=reference_config(data.reference);
    end
    mn3sn_run(cfg,fullfile(output_dir,c.name));
    fprintf('Candidate complete: %s\n',c.name);
end
record=struct('schema',1,'suite',suite,'baseline_id',manifest.id,'cases',{{cases.name}});
fid=fopen(fullfile(output_dir,'suite.json'),'w'); assert(fid>=0);
cleanup=onCleanup(@() fclose(fid)); fprintf(fid,'%s\n',jsonencode(record,PrettyPrint=true));
end
