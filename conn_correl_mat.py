# -*- coding: utf-8 -*-
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import os
import scipy.io

sns.set(style="white", context='paper', font_scale=1, font='monospace')

def extract_conn_correl_mat():
    
    # Analysis Information
    wdir             = 'C:/Users/Raphael/Desktop/These/CONN_Club_Neuro/Conn_ClubNeuro_Example/results/secondlevel'
    correl_net       = 'Salience'
    correl_group     = 'AllSubjects'
    correl_run       = 'rest'
    correl_type      = 'p'
    correl_folder    = os.path.join(wdir, correl_net, correl_group, correl_run )
    
    # Load .mat file
    mdata           = scipy.io.loadmat(os.path.join(correl_folder, 'ROI.mat'))
    mdata           = mdata['ROI']
    mdtype          = mdata.dtype
    ndata           = {n: mdata[n] for n in mdtype.names}
    mcol            = ['names', 'h', 'F', 'p']

    mcorr           = pd.DataFrame(np.concatenate([ndata[c] for c in mcol], axis=0)).transpose()
    mcorr.columns   = mcol
    mcorr.names     = np.concatenate(mcorr.names[0][0])
    mcorr.names     = mcorr.names.str.split('.').str.get(1)
    
    # Extract selected values
    if correl_type == 'beta':
        corr = pd.DataFrame(np.concatenate([mcorr.h[c] for c in mcorr.h.keys()], axis=0 ), index=mcorr.names)
    elif correl_type == 'F':
        corr = pd.DataFrame(np.concatenate([mcorr.F[c] for c in mcorr.F.keys()], axis=0 ), index=mcorr.names)
    elif correl_type == 'p':
        corr = pd.DataFrame(np.concatenate([mcorr.p[c] for c in mcorr.p.keys()], axis=0 ), index=mcorr.names)
        
    corr            = corr.iloc[:, 0:corr.shape[0]]
    corr.columns    = mcorr.names
    
    # Export to csv
    corr.to_csv(os.path.join(correl_folder, correl_type + '_' + correl_net + '_' + correl_group + '_' + correl_run + '_corr_mat.csv'), sep=';', decimal='.')
    
    # Plot
    plot_correl_matrix(corr, correl_type, correl_net, correl_group, correl_run, correl_folder )
 
def plot_correl_matrix(corr, correl_type, correl_net, correl_group, correl_run, correl_folder ):
        
    # Mask diagonal
    mask = np.zeros_like(corr, dtype=np.bool)  
    mask[np.triu_indices_from(mask, k=1)] = True 
     
    # Define plot properties 
    if correl_type == 'F':
        vmin    = 0
        vmax    = 10
        annot   = False
        cmap    = "YlOrRd"
        
    elif correl_type == 'beta' :
        vmin    = 0
        vmax    = 1
        annot   = True
        cmap    = "YlOrRd"
        
    elif correl_type == 'p' :
        vmin    = 0
        vmax    = 0.1
        annot   = False
        cmap    = "YlOrRd_r"
        
    f, ax = plt.subplots()
    sns.heatmap(corr, mask=mask, vmin=vmin,  vmax=vmax, square=True, cmap=cmap, annot=annot, cbar=True, xticklabels=False, yticklabels=True, linewidths=.0 )
    
    plt.xticks(rotation=0) 
    plt.ylabel('')
    plt.xlabel('')
    plt.title(correl_type + '_' + correl_net + '_' + correl_group + '_' + correl_run)
    
    # Uncomment for multiple networks plot
    # Emphasize networks separation (in case of multiple networks)
#    networks = np.array(pd.read_csv(os.path.join(correl_folder, 'networks_level_values.csv')))
#    for i, network in enumerate(networks):
#        if i and network != networks[i - 1 ]:
#            ax.axhline(len(networks) - i, c="w")
#            ax.axvline(i, c="w")
#            f.tight_layout()

    plt.savefig(os.path.join(correl_folder,  correl_type + '_' + correl_net + '_' + correl_group + '_' + correl_run + '.png'), dpi=300)
               
if __name__ =='__main__':

    extract_conn_correl_mat()
    