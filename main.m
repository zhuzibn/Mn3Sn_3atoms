% Default caller of the validated deterministic simulation API.
cfg=mn3sn_default_config();
result=mn3sn_run(cfg);
% Compatibility aliases for legacy workspace plotting.
tt=result.legacy_tt; mmx=result.mmx; mmy=result.mmy; mmz=result.mmz;
fprintf('Results: %s\n',result.output_dir);
