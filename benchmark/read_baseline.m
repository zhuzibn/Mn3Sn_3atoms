function [manifest,root] = read_baseline(root)
%READ_BASELINE Require the accepted inventory and verify every artifact hash.
if nargin<1, root=fullfile(fileparts(mfilename('fullpath')),'baseline'); end
manifest_file=fullfile(fileparts(root),'baseline_manifest.json');
assert(isfile(manifest_file),'Mn3SnBenchmark:MissingBaseline','Missing accepted baseline manifest.');
manifest=jsondecode(fileread(manifest_file));
assert(manifest.schema==1 && manifest.accepted && strcmp(manifest.status,'accepted'), ...
    'Mn3SnBenchmark:Unaccepted','A reviewed accepted baseline is required.');
expected=regression_cases();
assert(isequal(manifest.cases(:),expected(:)) && numel(manifest.artifacts)==75, ...
    'Mn3SnBenchmark:Inventory','Accepted case/artifact inventory is incompatible.');
paths={manifest.artifacts.baseline_path};
required=[strcat('cases/',{expected.name},'.mat'),strcat('text/',{expected.name},'.txt')];
assert(numel(unique(paths))==numel(paths) && all(ismember(required,paths)) && ...
    all(cellfun(@(p) ~startsWith(p,{'/','\'}) && ...
    isempty(regexp(p,'(^|[/\\])\.\.([/\\]|$)|:','once')),paths)), ...
    'Mn3SnBenchmark:Inventory','Reference paths must be unique, relative and include every consumed case.');
for k=1:numel(manifest.artifacts)
    f=manifest.artifacts(k); filename=fullfile(root,f.baseline_path);
    assert(isfile(filename),'Mn3SnBenchmark:MissingBaseline','Missing reference: %s',filename);
    assert(strcmp(mn3sn_sha256(filename),f.sha256),'Mn3SnBenchmark:Integrity', ...
        'Accepted reference hash differs: %s',filename);
end
end
