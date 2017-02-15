%% extract_correl_mat.m                         %
% Script to extract ROI-to-ROI correlation      %
% matrix from CONN Toolbox ROI.mat              %
% ----------------------------------------------%
% Author:   Raphael Vallat                      %
% Date:     February 2017                       %
% ----------------------------------------------%

clearvars

% Import data
corr_info               = [];
corr_info.date          = date;

corr_info.wdir          = 'C:\Users\Raphael\Desktop\These\CONN_Club_Neuro\Conn_ClubNeuro_Example\results\secondlevel\';       % Specify path to CONN second-level folder

corr_info.corr_net      = 'Salience';                               % Specify analysis name (i.e network of interest)
corr_info.corr_group    = 'AllSubjects';                            % Specify group (ex: Patients, Controls, AllSubjects)
corr_info.corr_run      = 'rest';                                   % Specify session

corr_info.corr_folder   = [ corr_info.wdir '\' corr_info.corr_net '\' corr_info.corr_group '\' corr_info.corr_run '\' ];

load([corr_info.corr_folder 'ROI.mat']);                    % ROI.mat is created when clicking 'results-explorer' in second-level interface

numROI  = size(ROI, 2);

% Loop on each ROI to import beta values
% -------------------------------------------
% h is the average of the y values for the particular pair of ROIs (essentially, the beta displayed in the results window)
% F has the appropriate statistical value (T value for example)
% p has the one sided uncorrected p value

corr_name   = ROI(1).names(1:numROI);

corr_h      = [];   % Beta value
corr_F      = [];   % T/F value
corr_p      = [];   % One-tailed p value

for i = 1:numROI
    
    corr_h      = [ corr_h ; ROI(i).h(1:numROI) ];
    corr_F      = [ corr_F ; ROI(i).F(1:numROI) ];
    corr_p      = [ corr_p ; ROI(i).p(1:numROI) ];
    
    % Split network name (ex DMN.MPFC >> MPFC)
    split = strsplit(corr_name{i}, '.');
    corr_name(i)= cellstr(split(end));
end

% Export to CSV

corr_name2  = strrep(corr_name, '-', '_');      % array2table does not work with '-' in var names
T_h         = array2table(corr_h, 'RowNames', corr_name2, 'VariableNames', corr_name2);
T_F         = array2table(corr_F, 'RowNames', corr_name2, 'VariableNames', corr_name2);
T_p         = array2table(corr_p, 'RowNames', corr_name2, 'VariableNames', corr_name2);

writetable( T_h, [corr_info.corr_folder 'beta_' corr_info.corr_net '_' corr_info.corr_group '_' corr_info.corr_run '.csv'], 'WriteVariableNames', true, 'WriteRowNames', true, 'delimiter', 'semi' );
writetable( T_F, [corr_info.corr_folder 'F_' corr_info.corr_net '_' corr_info.corr_group '_' corr_info.corr_run '.csv'], 'WriteVariableNames', true, 'WriteRowNames', true, 'delimiter', 'semi');
writetable( T_p, [corr_info.corr_folder 'p_' corr_info.corr_net '_' corr_info.corr_group '_' corr_info.corr_run '.csv'], 'WriteVariableNames', true, 'WriteRowNames', true, 'delimiter', 'semi');


% Plot using function plot_correl_mat_conn.m
% ====================================================================

do_plot = true;

% Plot preparation
corr_info.do_tril     = true;           % Plot only lower triangle of the matrix
corr_info.do_colorbar = true;           % Display colorbar
corr_info.labels      = true;           % Display label
corr_info.savefig     = true;           % Export as .tiff

corr_info.corr_h      = corr_h;
corr_info.corr_F      = corr_F;
corr_info.corr_p      = corr_p;
corr_info.corr_name   = corr_name;
corr_info.numROI      = numROI;

% COMPUTE AND WRITE STATISTICS
% If testing anti-correlations between two networks
if numROI > 10
    corr_info.do_acn    = true;
    corr_info.tail      = 'two-sided';
    corr_info.corr_p    = 2*min(corr_info.corr_p, 1-corr_info.corr_p);
    
else
    corr_info.do_acn    = false;
    corr_info.tail      = 'one-sided';
    
end

% Bonferroni and FDR correction
corr_info.alpha_bonf            = 0.05 / ((numROI)*(numROI-1)/2);
vector_fdr                      = nonzeros(triu(corr_info.corr_p)');
vector_fdr(isnan(vector_fdr))   = [];
corr_info.corr_p_fdr            = conn_fdr(vector_fdr);                 % conn_fdr function is in conn main folder


% WRITE OUTPUT
fprintf('\nANALYSIS INFO');
fprintf('\n--------------------------------------');
fprintf(['\nNetwork:\t ' corr_info.corr_net]);
fprintf(['\nGroup:\t\t ' corr_info.corr_group]);
fprintf(['\nRun:\t\t ' corr_info.corr_run]);
fprintf('\nSTATISTICS');
fprintf('\n--------------------------------------');
fprintf([ '\n' num2str(numROI) ' x ' num2str(numROI-1) ' ROIs matrix ; ' corr_info.tail]);
fprintf([ '\np-uncorrected:\t\t\t\t\t ' num2str(numel(corr_info.corr_p(corr_info.corr_p <= 0.05))/2)  ]);
fprintf([ '\np-bonferroni (alpha = ' num2str(round(corr_info.alpha_bonf, 5)) '):\t ' num2str(numel(corr_info.corr_p(corr_info.corr_p <= corr_info.alpha_bonf))/2) ]);
fprintf([ '\np-FDR corrected:\t\t\t\t ' num2str(numel(corr_info.corr_p_fdr(corr_info.corr_p_fdr <= 0.05))) ]);
fprintf('\n--------------------------------------\n');

if do_plot
    
    % Run plot function
    corr_info.corr_type   = 'h';
    plot_correl_mat(corr_info)
    
    corr_info.corr_type   = 'F';
    plot_correl_mat(corr_info)
    
    corr_info.corr_type   = 'p';
    plot_correl_mat(corr_info)
    
end

% Save main structure to .mat
clearvars -except corr_info

save([corr_info.corr_folder 'corr_info']);

close all;

%EOF