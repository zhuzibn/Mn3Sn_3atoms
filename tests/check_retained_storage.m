function check_retained_storage(before_file)
% Compare sampled storage with full-cadence output and optional pre-change captures.
repo=fileparts(fileparts(mfilename('fullpath'))); addpath(repo);
out=fullfile(repo,'.sisyphus',['retention-',char(java.util.UUID.randomUUID())]); mkdir(out);
settings=[2 1;17 1;17 4;19 50;18 4];
if nargin>0, old=load(before_file,'cases'); end
for k=1:size(settings,1)
    cfg=mn3sn_default_config(); cfg.runtime=settings(k,1)*cfg.tstep;
    cfg.starttime=0; cfg.pulsewidth=cfg.runtime; cfg.savestep=settings(k,2);
    sampled=mn3sn_run(cfg,fullfile(out,sprintf('sampled-%d',k)));
    dense_cfg=cfg; dense_cfg.savestep=1;
    dense=mn3sn_run(dense_cfg,fullfile(out,sprintf('dense-%d',k)));
    indices=1:cfg.savestep:settings(k,1);
    for name={'mmx','mmy','mmz'}
        assert(isequal(sampled.(name{1}),dense.(name{1})(indices,:)),...
            'Mn3Sn:Retention','Output cadence changed spin samples.');
    end
    assert(isequal(sampled.time_s,dense.time_s(indices)) && ...
        isequal(sampled.legacy_tt,dense.legacy_tt(indices)));
    steps=cfg.savestep:cfg.savestep:settings(k,1)-1;
    rows=[dense.legacy_tt(steps)'*1e12,dense.mmx(steps+1,1),dense.mmy(steps+1,1),...
        dense.mmz(steps+1,1),dense.mmx(steps+1,2),dense.mmy(steps+1,2),dense.mmz(steps+1,2)];
    expected=sprintf('%4.4f %8.4f %12.4f %16.4f %20.4f %24.4f %28.4f\n',rows');
    assert(strcmp(strrep(fileread(sampled.text.file),sprintf('\r\n'),sprintf('\n')),expected));
    if nargin>0 && k<=numel(old.cases)
        reference=old.cases{k}; assert(isequal(cfg,reference.cfg));
        for name={'mmx','mmy','mmz','time_s','legacy_tt','effective_inputs'}
            assert(isequal(sampled.(name{1}),reference.result.(name{1})),...
                'Mn3Sn:Retention','Pre-change capture differs: %s',name{1});
        end
        assert(strcmp(fileread(sampled.text.file),reference.text));
    end
end
fprintf('PASS five retention edge cases: every spin/clock, dense subsets and exact text; %s\n',out);
end
