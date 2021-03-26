#!/bin/bash

rm -r /mnt/DATA/MTL/Masked_ICA/???????/8_Effect_sizes-unsmoothed/
#rm -r /mnt/DATA/MTL/Masked_ICA/???????/REP/ITN/ICA20_tmaps/

mkdir /mnt/DATA/MTL/Masked_ICA/???????/8_Effect_sizes-unsmoothed/
#mkdir /mnt/DATA/MTL/Masked_ICA/???????/REP/ITN/ICA20_tmaps/

SOURCEPATH=/mnt/DATA/MTL/Masked_ICA/???????/7_Max_voxel_unsmoothed/ICA20_tmaps_unsmoothed/
OUTPUTPATH=/mnt/DATA/MTL/Masked_ICA/???????/8_Effect_sizes-unsmoothed/
MASKSPATH=/mnt/DATA/MTL/Masked_ICA/???????/ROI_MTL_50pc/masks/Effect_sizes/Masks/

#cp /mnt/DATA/MTL/Masked_ICA/???????/REP/ITN/LOCAL_DR/dr_stage3_ic????_tstat1.nii.gz $SOURCEPATH

for i in ${SOURCEPATH}*
do
	basename $i &>> ${OUTPUTPATH}/1_20ICs.txt
	fslstats $i -l 0 -M &>> ${OUTPUTPATH}/2_20ICs_mean.txt
	fslstats $i -l 0 -S &>> ${OUTPUTPATH}/3_20ICs_SD.txt
	fslstats $i -k ${MASKSPATH}/ninBilatAmy.nii.gz -l 0 -M &>> ${OUTPUTPATH}/4_20ICs_mean_AM.txt
	fslstats $i -k ${MASKSPATH}/reduced_aphg.nii.gz -l 0 -M &>> ${OUTPUTPATH}/6_20ICs_mean_EC.txt
	fslstats $i -k ${MASKSPATH}/ninBilatHipp.nii.gz -l 0 -M &>> ${OUTPUTPATH}/5_20ICs_mean_HC.txt
	fslstats $i -k ${MASKSPATH}/ninPPHR.nii.gz -l 0 -M &>> ${OUTPUTPATH}/8_20ICs_mean_PPHC.txt
	fslstats $i -k ${MASKSPATH}/resl_prhmanualreduced.nii.gz -l 0 -M &>> ${OUTPUTPATH}/7_20ICs_mean_PRC.txt
done
paste ${OUTPUTPATH}/*.txt | column >> ${OUTPUTPATH}/results.txt
echo -e "ID\tmean\tSD\tAM\tHC\tEC\tPRC\tPPHC" | cat - ${OUTPUTPATH}/results.txt &> ${OUTPUTPATH}/Table.txt
echo "done"
