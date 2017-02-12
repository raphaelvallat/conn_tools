function  plot_correl_mat( corr_info )

corr_type = corr_info.corr_type;

% Define dependent variable
if strcmp(corr_type, 'h')
    corr = corr_info.corr_h;
elseif strcmp(corr_type, 'F')
    corr = corr_info.corr_F;
elseif strcmp(corr_type, 'p')
    corr = corr_info.corr_p;
    
end

% MATRIX PREPARATION
% ==================================================

% Remove upper triangle + diagonal
if corr_info.do_tril; corr = tril(corr, -1); end


% For p-values, replace Nan by 1
if strcmp(corr_type, 'p') ; corr(corr == 0) = 1; end

% Define axis limits and colormap
if strcmp(corr_type, 'h')           % Case beta values
    if corr_info.do_acn             %...case several networks displayed
        clim = [ -0.5 1 ];
        my_jet = jet(9);
        my_jet(4,:) = [ 1 1 1 ];
        cmap = colormap(my_jet);
        corr(isnan(corr)) = 1;
    else
        clim = [ 0 1 ];
        cmap = colormap(flipud(hot(10)));
    end
    
elseif strcmp(corr_type, 'F')       % Case F value
    if corr_info.do_acn             %...case several networks displayed
        clim = [ -15 25 ];
        my_jet = jet(16);
        my_jet(7,:) = [ 1 1 1 ];
        cmap = colormap(my_jet);
        corr(isnan(corr)) = 25;
    else
        clim = [0 5];
        cmap = colormap(flipud(pink(10)));
    end
    
elseif strcmp(corr_type, 'p')       % Case p value
    clim = [ 0 0.055 ];
    my_cmap = copper(12);
    my_cmap(1, :) = [];
    my_cmap(end, :) = [ 1, 1, 1 ];
    cmap = colormap(my_cmap);
end


% START PLOTTING
% ======================================================================

close all;

set(0,'defaultfigurecolor',[ 1 1 1 ])
set(0,'DefaultAxesFontSize',12)


fig = figure;
set(gcf,'Units','inches', 'Position',[0 0 6 4])

im = imagesc(corr, clim );
im.AlphaData = 0.9;

%...colormap and colorbar
colormap(cmap);
if corr_info.do_colorbar;
    h = colorbar('eastoutside');
    xlabel(h, corr_type, 'FontSize', 14);
end

% Title and axis
title([corr_info.corr_net ' - ' corr_info.corr_group ' - ' corr_info.corr_run ], 'FontSize', 14);
set(gca, 'XTick', (1:corr_info.numROI));
set(gca, 'YTick', (1:corr_info.numROI));
set(gca, 'Ticklength', [0 0])
grid off
box off

if corr_info.labels
    set(gca, 'XTickLabel', (corr_info.corr_name), 'XTickLabelRotation', 0);
    set(gca, 'YTickLabel', (corr_info.corr_name));
else
    set(gca, 'XTickLabel', '');
    set(gca, 'YTickLabel', '');
end

if corr_info.savefig
    outfile = [ corr_info.corr_folder corr_type '_' corr_info.corr_net '_' corr_info.corr_group '_' corr_info.corr_run '.png' ];
    print(outfile, '-dpng', '-r300');
end

end

% EOF
