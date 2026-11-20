function mn3sn_validate_config(cfg)
%MN3SN_VALIDATE_CONFIG Reject invalid/unsupported inputs before integration.
assert(isstruct(cfg) && isscalar(cfg),'Mn3Sn:InvalidConfig','cfg must be a scalar struct.');
root=fileparts(mfilename('fullpath'));
assert(strcmpi(which('mn3sn_default_config'),fullfile(root,'mn3sn_default_config.m')), ...
    'Mn3Sn:ShadowedSource','Unexpected mn3sn_default_config resolution.');
expected=fieldnames(mn3sn_default_config()); actual=fieldnames(cfg);
unknown=setdiff(actual,expected); missing=setdiff(expected,actual);
assert(isempty(unknown),'Mn3Sn:UnknownField','Unknown cfg fields: %s',strjoin(unknown,', '));
assert(isempty(missing),'Mn3Sn:MissingField','Missing cfg fields: %s',strjoin(missing,', '));
assert(ischar(cfg.solver) && strcmp(cfg.solver,'rk4'), ...
    'Mn3Sn:UnsupportedMode','cfg.solver must be ''rk4''.');
flags={'SOT_DLT','SOT_FLT','STT_DLT','STT_FLT','dipolee','thermalnois','dimensionlessLLG'};
for k=1:numel(flags)
    x=cfg.(flags{k});
    assert((isa(x,'double') || islogical(x)) && isreal(x) && isscalar(x) && ...
        ismember(x,[0,1]),'Mn3Sn:InvalidParameter','cfg.%s must be 0 or 1.',flags{k});
end
for k=1:numel(expected)
    name=expected{k};
    if ismember(name,[flags,{'solver','Hext','initial_m'}]), continue; end
    x=cfg.(name);
    assert(isa(x,'double') && isscalar(x) && isreal(x) && isfinite(x), ...
        'Mn3Sn:InvalidParameter','cfg.%s must be a finite real double scalar.',name);
end
for name={'runtime','tstep','savestep','Ms_Fe','Ms_Gd','tFL'}
    assert(cfg.(name{1})>0,'Mn3Sn:InvalidParameter','cfg.%s must be positive.',name{1});
end
for name={'alp','Hex_2','hk_constant','starttime','pulsewidth','risetime','downtime'}
    assert(cfg.(name{1})>=0,'Mn3Sn:InvalidParameter','cfg.%s must be nonnegative.',name{1});
end
assert(cfg.savestep==fix(cfg.savestep) && cfg.savestep<=flintmax, ...
    'Mn3Sn:InvalidParameter','cfg.savestep must be a positive exactly represented integer.');
assert(isa(cfg.Hext,'double') && isreal(cfg.Hext) && isequal(size(cfg.Hext),[1,3]) && ...
    all(isfinite(cfg.Hext)),'Mn3Sn:InvalidParameter','cfg.Hext must be a finite real 1x3 double vector in tesla.');
assert(isa(cfg.initial_m,'double') && isreal(cfg.initial_m) && ...
    isequal(size(cfg.initial_m),[6,3]) && all(isfinite(cfg.initial_m),'all'), ...
    'Mn3Sn:InvalidParameter','cfg.initial_m must be a finite real 6x3 double array.');
assert(all(abs(sqrt(sum(cfg.initial_m.^2,2))-1)<1e-12), ...
    'Mn3Sn:InvalidParameter','Each row of cfg.initial_m must have unit norm (tolerance 1e-12).');
for name={'STT_DLT','STT_FLT','dipolee','thermalnois','dimensionlessLLG','Hex_1','jc_SOT2'}
    assert(cfg.(name{1})==0,'Mn3Sn:UnsupportedMode', ...
        'cfg.%s must be zero in the supported deterministic model.',name{1});
end
n=round(cfg.runtime/cfg.tstep);
assert(isfinite(n) && n>=2 && n<=flintmax,'Mn3Sn:InvalidTiming', ...
    'round(cfg.runtime/cfg.tstep) must be an exactly represented integer >=2.');
assert(isfinite(cfg.tstep*cfg.savestep),'Mn3Sn:InvalidTiming','Sampling interval must be finite.');
assert(cfg.risetime+cfg.downtime<=cfg.pulsewidth && ...
    cfg.starttime+cfg.pulsewidth<=cfg.runtime+32*eps(cfg.runtime), ...
    'Mn3Sn:InvalidTiming','Pulse edges must fit its width and cfg.runtime.');
segments=round([cfg.starttime,cfg.risetime, ...
    cfg.pulsewidth-cfg.risetime-cfg.downtime,cfg.downtime]/cfg.tstep);
assert(all(isfinite(segments)) && all(segments>=0) && sum(segments)<=n && ...
    round(cfg.starttime/cfg.tstep)+round(cfg.pulsewidth/cfg.tstep)<=n, ...
    'Mn3Sn:InvalidTiming','Rounded pulse segments must fit the integration array.');
run(fullfile(root,'constantfile.m'));
assert(isfinite(1+cfg.alp^2),'Mn3Sn:InvalidParameter','cfg.alp overflows the damping scale.');
assert(isfinite(2*cfg.hk_constant/(3*mub)), ...
    'Mn3Sn:InvalidParameter','cfg.hk_constant overflows its field conversion.');
assert(isfinite(cfg.DMI_constant/(3*mub)), ...
    'Mn3Sn:InvalidParameter','cfg.DMI_constant overflows its field conversion.');
for name={'Ms_Fe','Ms_Gd'}
    jp=2*cfg.tFL*(cfg.(name{1})*1e3)/hbar;
    assert(isfinite(jp) && jp>0,'Mn3Sn:InvalidParameter', ...
        'cfg.tFL and cfg.%s must give a finite positive torque denominator.',name{1});
    if cfg.SOT_DLT
        assert(isfinite(cfg.thetaSH*cfg.jc_SOT/jp),'Mn3Sn:InvalidParameter', ...
            'cfg.thetaSH, cfg.jc_SOT, cfg.tFL and cfg.%s overflow the torque amplitude.',name{1});
    end
end
end
