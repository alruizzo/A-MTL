#!/bin/bash
##calculate mean and standard deviation of *realigned* functional images with fslmaths,
##divide mean by standard deviation image (=TSNR image)
##and then extract the average of non-zero voxels of the resulting image with fslstats

basepath="/mnt/DATA/MTL/Original/REP1/FunImgR/"
outpath="/mnt/DATA/MTL/Masked_ICA/???????/REP/TSNR/"

for i in $(ls ${basepath})
do
echo $i
cd ${basepath}/${i}
#mv ra${i}-d0600.nii.gz ${i}.nii.gz
#rm -r vol0299.nii.gz
tcsh -c "fslmaths rfrest.nii.gz -mas ${i}_allAMTL_thr_bin.nii.gz -Tstd std_${i}.nii.gz"
tcsh -c "fslmaths rfrest.nii.gz -mas ${i}_allAMTL_thr_bin.nii.gz -Tmean mean_${i}.nii.gz"
tcsh -c "fslmaths mean_${i}.nii.gz -div std_${i}.nii.gz TSNR_allAMTL_${i}.nii.gz"
tcsh -c "fslstats TSNR_allAMTL_${i}.nii.gz -l 0 -M" >> TSNR_allAMTL_${i}.txt
cat TSNR_allAMTL_${i}.txt >> ${outpath}/2_TSNR_allAMTL_output.txt
done

for i in $(ls ${basepath})
do
echo $i
cd ${basepath}/${i}
tcsh -c "fslmaths rfrest.nii.gz -mas ${i}_AM_thr_bin.nii.gz -Tstd std_${i}.nii.gz"
tcsh -c "fslmaths rfrest.nii.gz -mas ${i}_AM_thr_bin.nii.gz -Tmean mean_${i}.nii.gz"
tcsh -c "fslmaths mean_${i}.nii.gz -div std_${i}.nii.gz TSNR_AM_${i}.nii.gz"
tcsh -c "fslstats TSNR_AM_${i}.nii.gz -l 0 -M" >> TSNR_AM_${i}.txt
cat TSNR_AM_${i}.txt >> ${outpath}/3_TSNR_AM_output.txt
done

for i in $(ls ${basepath})
do
echo $i
cd ${basepath}/${i}
tcsh -c "fslmaths rfrest.nii.gz -mas ${i}_EC_thr_bin.nii.gz -Tstd std_${i}.nii.gz"
tcsh -c "fslmaths rfrest.nii.gz -mas ${i}_EC_thr_bin.nii.gz -Tmean mean_${i}.nii.gz"
tcsh -c "fslmaths mean_${i}.nii.gz -div std_${i}.nii.gz TSNR_EC_${i}.nii.gz"
tcsh -c "fslstats TSNR_EC_${i}.nii.gz -l 0 -M" >> TSNR_EC_${i}.txt
cat TSNR_EC_${i}.txt >> ${outpath}/5_TSNR_EC_output.txt
done

for i in $(ls ${basepath})
do
echo $i
cd ${basepath}/${i}
tcsh -c "fslmaths rfrest.nii.gz -mas ${i}_HC_thr_bin.nii.gz -Tstd std_${i}.nii.gz"
tcsh -c "fslmaths rfrest.nii.gz -mas ${i}_HC_thr_bin.nii.gz -Tmean mean_${i}.nii.gz"
tcsh -c "fslmaths mean_${i}.nii.gz -div std_${i}.nii.gz TSNR_HC_${i}.nii.gz"
tcsh -c "fslstats TSNR_HC_${i}.nii.gz -l 0 -M" >> TSNR_HC_${i}.txt
cat TSNR_HC_${i}.txt >> ${outpath}/4_TSNR_HC_output.txt
done

for i in $(ls ${basepath})
do
echo $i
cd ${basepath}/${i}
tcsh -c "fslmaths rfrest.nii.gz -mas ${i}_PHC_thr_bin.nii.gz -Tstd std_${i}.nii.gz"
tcsh -c "fslmaths rfrest.nii.gz -mas ${i}_PHC_thr_bin.nii.gz -Tmean mean_${i}.nii.gz"
tcsh -c "fslmaths mean_${i}.nii.gz -div std_${i}.nii.gz TSNR_PHC_${i}.nii.gz"
tcsh -c "fslstats TSNR_PHC_${i}.nii.gz -l 0 -M" >> TSNR_PHC_${i}.txt
cat TSNR_PHC_${i}.txt >> ${outpath}/7_TSNR_PHC_output.txt
done

for i in $(ls ${basepath})
do
echo $i >> ${outpath}/1_participants.txt
cd ${basepath}/${i}
tcsh -c "fslmaths rfrest.nii.gz -mas ${i}_PRC_thr_bin.nii.gz -Tstd std_${i}.nii.gz"
tcsh -c "fslmaths rfrest.nii.gz -mas ${i}_PRC_thr_bin.nii.gz -Tmean mean_${i}.nii.gz"
tcsh -c "fslmaths mean_${i}.nii.gz -div std_${i}.nii.gz TSNR_PRC_${i}.nii.gz"
tcsh -c "fslstats TSNR_PRC_${i}.nii.gz -l 0 -M" >> TSNR_PRC_${i}.txt
cat TSNR_PRC_${i}.txt >> ${outpath}/6_TSNR_PRC_output.txt
done

cd ${outpath}
paste -d '\t' ./*.txt | column >> REP2_TSNR_table.txt
sed -i "1i participant\tTSNR_allAMTL\tTSNR_AM\tTSNR_HC\tTSNR_EC\tTSNR_PRC\tTSNR_PHC" ${outpath}/REP2_TSNR_table.txt
