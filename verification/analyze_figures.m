function analyze_figures(root)
% Analyze all raw trajectories at common physical sample times; export plots.
seeds=[30 90 150 210 270 330];
fields=[175 200 225 250 275 300 325 350 375 400 450 500];
names={}; expected=[];
signs={'pp','pm','mm','mp'}; destinations=[30 -150 -30 150];
signlabels={'+J, +100 Oe','+J, -100 Oe','-J, -100 Oe','-J, +100 Oe'};
for s=1:4
    for seed=seeds
        names{end+1}=sprintf('fig2_%s_%d',signs{s},seed); %#ok<AGROW>
        expected(end+1)=destinations(s); %#ok<AGROW>
    end
end
for field=fields
    names{end+1}=sprintf('fig5_%d',field); %#ok<AGROW>
    expected(end+1)=NaN; %#ok<AGROW>
end
for sign={'p','m'}
    for seed=seeds
        names{end+1}=sprintf('fig5_1000%s_%d',sign{1},seed); %#ok<AGROW>
        expected(end+1)=90; %#ok<AGROW>
    end
end
results=struct([]);
for k=1:numel(names)
    name=names{k};
    [t,a,pa,norma,spina]=trace(root,[name '_dt5']);
    [tb,b,pb,normb]=trace(root,[name '_dt2.5']);
    [tc,c,pc,normc]=trace(root,[name '_dt1.25']);
    [tl,l,pl,norml]=trace(root,[name '_legacy']);
    assert(max(abs(t-tb))<1e-12 && max(abs(t-tc))<1e-12 && max(abs(t-tl))<1e-12);
    r=struct('case',name,'final_deg_legacy',pl(end),'final_deg_5fs',pa(end), ...
        'final_deg_2_5fs',pb(end),'final_deg_1_25fs',pc(end), ...
        'driven_deg_5fs',pa(find(t<4,1,'last')), ...
        'max_mean_difference_legacy',max(abs(a-l),[],'all'), ...
        'max_mean_difference_5_2_5fs',max(abs(a-b),[],'all'), ...
        'max_mean_difference_2_5_1_25fs',max(abs(b-c),[],'all'), ...
        'max_norm_error',max([norma normb normc norml]), ...
        'expected_final_deg',expected(k),'endpoint_pass',true);
    if isfinite(expected(k))
        r.endpoint_pass=all(abs(mod([pa(end) pb(end) pc(end)]-expected(k)+180,360)-180)<.1);
    end
    r.convergence_pass=r.max_mean_difference_5_2_5fs<1e-5 && r.max_mean_difference_2_5_1_25fs<1e-5;
    if k==1, results=r; else, results(k)=r; end %#ok<AGROW>
    assert(r.max_norm_error<1e-12);
    if strcmp(name,'fig2_pp_210')
        fig4=struct('zero_crossing_ns_legacy',crossing(t,l(:,3)), ...
            'zero_crossing_ns_5fs',crossing(t,a(:,3)), ...
            'zero_crossing_ns_2_5fs',crossing(tb,b(:,3)), ...
            'zero_crossing_ns_1_25fs',crossing(tc,c(:,3)), ...
            'initial_mean',a(find(t<1,1,'last'),:),'final_mean',a(end,:), ...
            'driven_mean',a(find(t<4,1,'last'),:),'peak_y',max(a(t>1 & t<4,2)), ...
            'maximum_abs_x_during_drive',max(abs(a(t>1 & t<4,1))), ...
            'max_spin_difference_legacy',NaN);
        raw=readmatrix(fullfile(root,[name '_legacy.csv']));
        fig4.max_spin_difference_legacy=max(abs(spina-raw(:,3:20)),[],'all');
        assert(abs(fig4.zero_crossing_ns_5fs-fig4.zero_crossing_ns_2_5fs)<.001);
        assert(abs(fig4.zero_crossing_ns_2_5fs-fig4.zero_crossing_ns_1_25fs)<.001);
    end
end
writetable(struct2table(results),fullfile(root,'summary.csv'));
fid=fopen(fullfile(root,'analysis.json'),'w');
fprintf(fid,'%s\n',jsonencode(struct('cases',results,'fig4a',fig4),PrettyPrint=true));
fclose(fid);
fprintf('Analyzed %d cases, 4 integrator/timestep variants each\n',numel(results));
fprintf('Worst norm error %.4g; convergence error 5/2.5fs %.4g, 2.5/1.25fs %.4g\n', ...
    max([results.max_norm_error]),max([results.max_mean_difference_5_2_5fs]),max([results.max_mean_difference_2_5_1_25fs]));
disp(fig4);
disp(struct2table(results(25:36)));

set(groot,'defaultAxesFontName','Arial','defaultAxesFontSize',11);
fig=figure('Visible','off','Color','w','Position',[50 50 1200 850]);
tiledlayout(2,2,'TileSpacing','compact');
for k=1:3
    nexttile; hold on;
    [t,~,p]=trace(root,sprintf('fig2_%s_270_dt5',signs{k}));
    plot(t(t>=.05),p(t>=.05),'LineWidth',1.3);
    angle_axes(sprintf('Fig. 2(%c): %s',char('a'+k-1),signlabels{k}));
end
nexttile; hold on;
for seed=seeds
    [t,~,p]=trace(root,sprintf('fig2_pp_%d_dt5',seed));
    plot(t(t>=.05),p(t>=.05),'LineWidth',1.3,'DisplayName',sprintf('%g deg',p(find(t<1,1,'last'))));
end
angle_axes('Fig. 2(d): all six initial states'); legend('Location','best');
sgtitle('Fig. 2 | signed octupole angle | drive 1-4 ns');
exportgraphics(fig,fullfile(root,'fig2-corrected.png'),'Resolution',160); close(fig);

fig=figure('Visible','off','Color','w','Position',[50 50 1050 600]); hold on;
colors=[.85 .15 .15; .2 .6 .1; .1 .3 .8];
[t,m]=trace(root,'fig2_pp_210_dt5');
for q=1:3
    plot(t,m(:,q)*1e3,'Color',colors(q,:),'LineWidth',1.4, ...
        'DisplayName',sprintf('m_{oct,%c}','x'+q-1));
end
xline(1,':','HandleVisibility','off'); xline(4,':','HandleVisibility','off'); grid on; xlim([0 5]);
xlabel('Physical time (ns)'); ylabel('Mean spin components (10^{-3})');
title('Fig. 4(a): Mn_3Sn switching | +J, +100 Oe');
legend('Location','eastoutside');
exportgraphics(fig,fullfile(root,'fig4a-corrected.png'),'Resolution',160); close(fig);

fig=figure('Visible','off','Color','w','Position',[50 50 1500 530]);
tiledlayout(1,3,'TileSpacing','compact');
nexttile; hold on;
colororder(turbo(numel(fields)));
for field=fields
    [t,~,p]=trace(root,sprintf('fig5_%d_dt5',field));
    plot(t(t>=.05),p(t>=.05),'LineWidth',1.2,'DisplayName',sprintf('%d Oe',field));
end
angle_axes('Fig. 5(a): field sweep, +J'); legend('Location','best','NumColumns',2,'FontSize',8);
for sign={'p','m'}
    nexttile; hold on;
    for seed=seeds
        [t,~,p]=trace(root,sprintf('fig5_1000%s_%d_dt5',sign{1},seed));
        plot(t(t>=.05),p(t>=.05),'LineWidth',1.2,'DisplayName',sprintf('%g deg',p(find(t<1,1,'last'))));
    end
    if strcmp(sign{1},'p'), label='Fig. 5(b): +J'; else, label='Fig. 5(c): -J'; end
    angle_axes([label ', 1000 Oe']); legend('Location','best','FontSize',8);
end
sgtitle('Fig. 5 | |J| = 5 x 10^{10} A/m^2 | dt = 5 fs');
exportgraphics(fig,fullfile(root,'fig5-corrected.png'),'Resolution',160); close(fig);
assert(all([results.endpoint_pass]),'Some published destinations did not survive');
assert(all([results.convergence_pass]),'Some cases require further convergence study');
end

function [t,m,p,normerror,spin]=trace(root,name)
a=readmatrix(fullfile(root,[name '.csv']));
assert(all(isfinite(a),'all'),'Nonfinite trajectory: %s',name);
t=a(:,2)*1e9; spin=a(:,3:20);
m=[mean(a(:,3:5),2),mean(a(:,9:11),2),mean(a(:,15:17),2)];
p=atan2d(m(:,2),m(:,3));
normerror=max(abs(sqrt(a(:,3:8).^2+a(:,9:14).^2+a(:,15:20).^2)-1),[],'all');
end

function t0=crossing(t,z)
i=find(t>1 & z>=0,1);
t0=t(i-1)-z(i-1)*(t(i)-t(i-1))/(z(i)-z(i-1));
end

function angle_axes(label)
xline(1,':','HandleVisibility','off'); xline(4,':','HandleVisibility','off'); grid on; xlim([0 5]); ylim([-185 185]);
yticks(-180:60:180); xlabel('Physical time (ns)'); ylabel('Octupole angle (deg)'); title(label);
end
