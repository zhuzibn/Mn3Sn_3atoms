function checks = check_reference_capture(proposal)
%CHECK_REFERENCE_CAPTURE Exercise capture guards using disposable proposal copies.
% Requires two completed captures. Never edits the supplied reference proposal.
repo=fileparts(fileparts(mfilename('fullpath')));
checks={};
expect_error(@() prepare_reference(proposal,'prepare'),'Mn3SnReference:Exists');
checks{end+1}='existing proposal rejected';
expect_error(@() prepare_reference(proposal,'capture',1),'Mn3SnReference:Exists');
checks{end+1}='existing repetition rejected';
expect_error(@() prepare_reference(fullfile(repo,'benchmark','baseline'),'prepare'), ...
    'Mn3SnReference:Path');
checks{end+1}='accepted-reference destination rejected';

mutations={'missing_case','wrong_case_input','missing_fixture','changed_source', ...
    'changed_text','middle_sample','wrong_clock','legacy_clock','nonfinite', ...
    'wrong_initial','norm_defect','stored_input'};
errors={'Inventory','Inventory','Inventory','Integrity','Text','Repeat', ...
    'Clock','Clock','Arrays','Initial','Norm','Inputs'};
for k=1:numel(mutations)
    root=copy_proposal(proposal,repo);
    file=fullfile(root,'preparation.json');
    metadata=jsondecode(fileread(file));
    ref_file=fullfile(root,'repeat-1','pilot','reference.mat');
    if strcmp(mutations{k},'missing_case')
        metadata.cases(end)=[];
        write_json(file,metadata);
    elseif strcmp(mutations{k},'wrong_case_input')
        metadata.cases(10).width_s=5e-12;
        write_json(file,metadata);
    elseif strcmp(mutations{k},'missing_fixture')
        metadata.files(end)=[];
        write_json(file,metadata);
    elseif strcmp(mutations{k},'changed_source')
        append(fullfile(root,'repeat-1','pilot','rk4_4llg.m'),'% deliberate test mutation');
    elseif strcmp(mutations{k},'changed_text')
        append(fullfile(root,'repeat-1','pilot','result.txt'),'0 0 0 0 0 0 0');
    else
        load(ref_file,'reference');
        row=round(size(reference.mmx,1)/2);
        switch mutations{k}
            case 'middle_sample'
                % Rotate an interior spin; keep the norm and endpoints intact.
                y=reference.mmy(row,1); z=reference.mmz(row,1); angle=1e-4;
                reference.mmy(row,1)=cos(angle)*y-sin(angle)*z;
                reference.mmz(row,1)=sin(angle)*y+cos(angle)*z;
            case 'wrong_clock'
                reference.time_s(row)=reference.time_s(row)+reference.inputs.tstep;
            case 'legacy_clock'
                reference.legacy_tt(row)=reference.legacy_tt(row)+reference.inputs.tstep;
            case 'nonfinite'
                reference.mmx(row,1)=NaN;
            case 'wrong_initial'
                reference.initial_m(1,1)=reference.initial_m(1,1)+1e-4;
            case 'norm_defect'
                reference.mmy(row,1)=1.001*reference.mmy(row,1);
            case 'stored_input'
                reference.inputs.jc_SOT=1e9;
        end
        save(ref_file,'reference','-v7');
    end
    expect_error(@() prepare_reference(root,'verify'),['Mn3SnReference:',errors{k}]);
    assert(~isfile(fullfile(root,'proposal-manifest.json')), ...
        'Mn3SnReferenceTest:Manifest','Failed proposal received a verified manifest.');
    checks{end+1}=mutations{k};
end
fprintf('PASS %d reference capture protection/mutation checks.\n',numel(checks));
end

function root=copy_proposal(source,repo)
root=fullfile(repo,'.sisyphus',['cq-reference-proposal-test-',char(java.util.UUID.randomUUID())]);
mkdir(root);
for name={'source','fixtures','tools','repeat-1','repeat-2'}
    copyfile(fullfile(source,name{1}),fullfile(root,name{1}));
end
copyfile(fullfile(source,'preparation.json'),root);
copyfile(fullfile(source,'historical-source-hashes.json'),root);
% Do not copy proposal-manifest.json: these are independently unverified fixtures.
end

function expect_error(action,expected)
try
    action();
catch problem
    assert(strcmp(problem.identifier,expected), ...
        'Mn3SnReferenceTest:WrongError','Expected %s, got %s: %s', ...
        expected,problem.identifier,problem.message);
    return;
end
error('Mn3SnReferenceTest:DidNotFail','Expected error %s was not raised.',expected);
end

function append(path,text)
fid=fopen(path,'ab'); assert(fid>=0);
cleanup=onCleanup(@() fclose(fid)); fprintf(fid,'\n%s\n',text);
end

function write_json(path,value)
fid=fopen(path,'wb'); assert(fid>=0);
cleanup=onCleanup(@() fclose(fid));
fwrite(fid,unicode2native(jsonencode(value,PrettyPrint=true),'UTF-8'),'uint8');
end
