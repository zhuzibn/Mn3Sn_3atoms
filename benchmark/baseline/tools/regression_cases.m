function cases = regression_cases()
%REGRESSION_CASES Fixed pre-migration reference inventory, not production defaults.
names = {'pilot','replay_pp','replay_pm','replay_mm','replay_mp', ...
    'replay_275','replay_300','replay_1000p','replay_1000m', ...
    'pulse_edges','default_5ns'};
fields_Oe = [0,100,-100,-100,100,275,300,1000,1000,250,250];
currents = [0,5e10,5e10,-5e10,-5e10,5e10,5e10,5e10,-5e10,5e10,5e10];
cases = struct([]);
for k = 1:numel(names)
    c = struct('name',names{k},'suite','quick','field_T',fields_Oe(k)*1e-4, ...
        'current_Apm2',currents(k),'runtime_s',20e-12, ...
        'start_s',0,'width_s',20e-12,'tstep_s',5e-15, ...
        'savestep',50,'historical',k<=9,'seed_file','');
    if k>=2 && k<=9, c.seed_file = 'seed.csv'; end
    if k==10, c.start_s=5e-12; c.width_s=10e-12; end
    if k==11
        c.suite='extended'; c.runtime_s=5000e-12;
        c.start_s=1000e-12; c.width_s=3000e-12;
    end
    if k==1, cases=repmat(c,1,numel(names)); else, cases(k)=c; end
end
end
