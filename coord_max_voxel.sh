#!/bin/bash

rm -r /mnt/DATA/MTL/Masked_ICA/???????/7_Max_voxel_unsmoothed/

mkdir /mnt/DATA/MTL/Masked_ICA/???????/7_Max_voxel_unsmoothed/
mkdir /mnt/DATA/MTL/Masked_ICA/???????/7_Max_voxel_unsmoothed/Max_voxel_unsmoothed_results/
mkdir /mnt/DATA/MTL/Masked_ICA/???????/7_Max_voxel_unsmoothed/ICA20_tmaps_unsmoothed/

SOURCEPATH=/mnt/DATA/MTL/Masked_ICA/???????/7_Max_voxel_unsmoothed/ICA20_tmaps_unsmoothed/
OUTPUTPATH=/mnt/DATA/MTL/Masked_ICA/???????/7_Max_voxel_unsmoothed/Max_voxel_unsmoothed_results/
MASKSPATH=/mnt/DATA/MTL/Masked_ICA/???????/ROI_MTL_50pc/masks/Effect_sizes/Masks/

cp /mnt/DATA/MTL/Masked_ICA/???????/4_DR_MTL_local_0.5_unsmoothed/dr_stage3_ic????_tstat1.nii.gz $SOURCEPATH

for i in ${SOURCEPATH}*
do
	basename $i &>> ${OUTPUTPATH}/1_20ICs.txt
	fslstats $i -x &>> ${OUTPUTPATH}/2_20ICs_max_vox_unsmoothed.txt
done
paste ${OUTPUTPATH}/*.txt | column >> ${OUTPUTPATH}/results_max_vox_unsmoothed.txt
echo -e "IC\tvox_coordinates" | cat - ${OUTPUTPATH}/results_max_vox_unsmoothed.txt &> ${OUTPUTPATH}/Table_max_vox_coord.txt
echo "done"
