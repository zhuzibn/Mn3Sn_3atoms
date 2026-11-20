function resolved = mn3sn_resolve_path(filename)
%MN3SN_RESOLVE_PATH Resolve existing ancestors, including Windows junctions.
if ~java.io.File(filename).isAbsolute(), filename=fullfile(pwd,filename); end
filename=char(java.io.File(filename).getCanonicalPath());
tail={};
while ~isfolder(filename) && ~isfile(filename)
    [parent,name,ext]=fileparts(filename);
    assert(~strcmp(parent,filename) && ~isempty(parent), ...
        'Mn3Sn:InvalidOutput','Cannot resolve output parent.');
    tail=[{[name,ext]},tail]; %#ok<AGROW>
    filename=parent;
end
resolved=char(java.io.File(filename).toPath().toRealPath( ...
    javaArray('java.nio.file.LinkOption',0)).toString());
if ~isempty(tail), resolved=fullfile(resolved,tail{:}); end
end
