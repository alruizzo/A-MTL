# A-MTL
---
## Analysis scripts

### Description

- **Scripts used for the analyses of the results reported in**

[![DOI:10.1016/j.neuroimage.2019.116404](https://zenodo.org/badge/DOI/10.1016/j.neuroimage.2019.116404.svg)](https://doi.org/10.1016/j.neuroimage.2019.116404)


- **Project information**

[![DOI:10.17605/OSF.IO/DX7QP](https://zenodo.org/badge/DOI/10.17605/OSF.IO/DX7QP.svg)](https://doi.org/10.17605/OSF.IO/DX7QP)


- **Anatomical mask MNI space**

Download the mediat temporal lobe (A-MTL) mask (.nii) used for the analyses [here](https://osf.io/8j9ts/)


### Content

`tissue_prob_ic_sel.sh` Script that helps us determine which independent component (IC) is more likely to be noise (cerebrospinal fluid, CSF or white matter, WM) than a true network (gray matter, GM) based on the volume of each tissue compartment (for Fig. 1 of the paper)

`ES_per_structure.sh` Script to calculate mean and standard deviation for later effect size calculation per structure and IC using *fslstats* (Fig. 2B of the paper)

`masks_in_fun_space.sh` Script to rescale the A-MTL structure to the functional native space to calculate the temporal SNR (for the Supplement)

`TSNR_AMTL.sh` Script to calculate the temporal signal-to-noise-ratio for each A-MTL structure using *fslstats* (reported in the Supplement)

`coord_max_voxel.sh` Script to obtain and store the MNI coordinates of the 'peak' voxel of functional connectivity, based on the *tstat* image and using *fslstats* (Table 1 of the paper)

`create_table.sh` Script to create a table in .txt using the *column* command

`slicewise_voxel_count.sh` Script to count the number of voxels in each slice along the anterior-posterior axis (y-axis) for each A-MTL structure, for each IC/brain network (Fig. 4, schematics, of the paper)
