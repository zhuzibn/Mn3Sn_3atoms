function cfg = reference_config(reference)
%REFERENCE_CONFIG Map fixed legacy reference inputs to the public interface.
cfg=mn3sn_default_config(); names=fieldnames(cfg);
for k=1:numel(names)
    name=names{k};
    if strcmp(name,'initial_m'), cfg.initial_m=reference.initial_m;
    elseif ~strcmp(name,'solver')
        assert(isfield(reference.inputs,name),'Mn3SnBenchmark:Inputs','Missing reference input %s.',name);
        cfg.(name)=reference.inputs.(name);
    end
end
mn3sn_validate_config(cfg);
end
