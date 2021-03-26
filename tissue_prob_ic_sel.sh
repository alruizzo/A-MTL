#bash script to select neural vs nonneural ICs, based on A-MTL global FC ALRR, 08.07.2019

#!/bin/bash

##first SPECIFY the path where the dual regressed data will be saved ("SOURCE"), the path to your working folder ("OUTPUT" and "INPUTIMG"), and the path for your log file
ORIGPATH=/mnt/DATA/MTL/Masked_ICA/???????/4_DR_MTL_WB_0.5_unsmoothed/ #where DR data are stored
SOURCEPATH=/mnt/DATA/MTL/Masked_ICA/???????/5_Tissue_unsmoothed/DR_WB/ #working source
OUTPUTPATH=/mnt/DATA/MTL/Masked_ICA/???????/5_Tissue_unsmoothed/ #where results will be saved to
TISSUEPATH=/mnt/DATA/MTL/Masked_ICA/???????/3_DR_MTL_WB_0.5/

rm -r ${OUTPUTPATH}

mkdir ${OUTPUTPATH}
mkdir ${SOURCEPATH}

##copying the respective image files from the data folder
cp ${ORIGPATH}/dr_stage3_ic0???_tfce_corrp_tstat1.nii.gz ${SOURCEPATH}

##thresholding and binarizing the p-corr images (hence the threshold used is 0.95, 1-0.95 for a p-value threshold of 0.05)
for i in ${SOURCEPATH}*
do
	INAME=`basename ${i}`
	fslmaths $i -thr 0.95 ${SOURCEPATH}/${INAME}_thr
	fslmaths ${i}_thr -bin ${SOURCEPATH}/${INAME}_thr_bin
done

##to save space, let's remove the image files we don't need now
rm -r ${SOURCEPATH}/dr_stage3_ic0???_tfce_corrp_tstat1_thr.nii.gz
rm -r ${SOURCEPATH}/dr_stage3_ic0???_tfce_corrp_tstat1.nii.gz

##stripping the file name to leave in only the IC number
for filename in ${SOURCEPATH}*
do
	[ -f "$filename" ] || continue
	mv "$filename" "${filename//_tfce_corrp_tstat1/}"
done

for filename in ${SOURCEPATH}*
do
	[ -f "$filename" ] || continue
	mv "$filename" "${filename//dr_stage3_/}"
done

##create respective tissue folders
cd ${OUTPUTPATH}
mkdir GM
mkdir WM
mkdir CSF

##multiply each binary map of tissue type by each IC to obtain tissue-specific IC maps
for SUBJECT in ${SOURCEPATH}*
do
	SUBJECTNAME=`basename $SUBJECT`
	fslmaths $SUBJECT -mul $TISSUEPATH/CSF_2mm_thr.nii.gz ${OUTPUTPATH}/CSF/${SUBJECTNAME}_CSF
	fslmaths $SUBJECT -mul $TISSUEPATH/GM_2mm_thr.nii.gz ${OUTPUTPATH}/GM/${SUBJECTNAME}_GM
	fslmaths $SUBJECT -mul $TISSUEPATH/WM_2mm_thr.nii.gz ${OUTPUTPATH}/WM/${SUBJECTNAME}_WM
done

##Extract number of voxels (volume) for each tissue-specific component with fslstats and write it to a text file
mkdir ${OUTPUTPATH}/Results

for img in ${OUTPUTPATH}/CSF/*
do
	IMGNAME=`basename $img`
	fslstats $img -V >> $OUTPUTPATH/Results/2_CSF_vol_vx.txt
done
sed -i -r 's/(\s+)?\S+//2' $OUTPUTPATH/Results/2_CSF_vol_vx.txt

for img in ${OUTPUTPATH}/WM/*
do
	IMGNAME=`basename $img`
	fslstats $img -V >> $OUTPUTPATH/Results/3_WM_vol_vx.txt
done
sed -i -r 's/(\s+)?\S+//2' $OUTPUTPATH/Results/3_WM_vol_vx.txt

for img in ${OUTPUTPATH}/GM/*
do
	IMGNAME=`basename $img`
	fslstats $img -V >> $OUTPUTPATH/Results/4_GM_vol_vx.txt
done
sed -i -r 's/(\s+)?\S+//2' $OUTPUTPATH/Results/4_GM_vol_vx.txt

for img in ${OUTPUTPATH}/DR_WB/*
do
	IMGNAME=`basename $img`
	fslstats $img -V >> $OUTPUTPATH/Results/5_IC_vol_vx.txt
done
sed -i -r 's/(\s+)?\S+//2' $OUTPUTPATH/Results/5_IC_vol_vx.txt

##writing the results to a single text file
cd $SOURCEPATH
ls > $OUTPUTPATH/Results/1_IC.txt

cd $OUTPUTPATH/Results/
paste -d '\t' * | column >> /mnt/DATA/MTL/Masked_ICA/???????/tissue_unsmoothed_table.txt
echo -e "IC\tCSF_vx\tWM_vx\tGM_vx\tTotal_vx" | cat - /mnt/DATA/MTL/Masked_ICA/???????/tissue_unsmoothed_table.txt &> ${OUTPUTPATH}/Results/Tissue_unsmoothed_table.txt
rm -r /mnt/DATA/MTL/Masked_ICA/???????/tissue_unsmoothed_table.txt

echo "tissue probabilities for ICs finished!"
