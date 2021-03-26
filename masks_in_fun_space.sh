#!/bin/bash

## Code to adjust A-MTL masks to the functional native space to then calculate T-SNR

SOURCEPATH=/mnt/DATA/MTL/Original/REP1/FunImgR/
MASKSPATH=/mnt/DATA/MTL/Masked_ICA/???????/ROI_MTL_50pc/masks/Effect_sizes/Masks/
MIDVOLUME='vol0074.nii.gz' #write here the index for the middle volume of your time series

for i in ${SOURCEPATH}*
do
	SUBJECTNAME=`basename $i`
	echo ${SUBJECTNAME}
	cd ${SOURCEPATH}/${SUBJECTNAME}
	#fslsplit ra${SUBJECTNAME}-d0600.nii.gz
	fslsplit rfrest.nii.gz

	# remove all volumes but the one in the middle (where the values will be obtained) to save space. I chose the middle one because it's the most representative of the time series regarding motion correction, etc. Taking the whole time series will cause errors in registration
	rm -r vol{0000..0073}.nii.gz #volume range before the middle one ("299")
	rm -r vol{0075..0149}.nii.gz #volume range after the middle one

	flirt -usesqform -in ${MASKSPATH}/ninBilatAmy.nii.gz -ref ${MIDVOLUME} -applyxfm -out ${SUBJECTNAME}_AM.nii.gz
	fslmaths ${SUBJECTNAME}_AM.nii.gz -thr 0.5 ${SUBJECTNAME}_AM_thr.nii.gz
	fslmaths ${SUBJECTNAME}_AM_thr.nii.gz -bin ${SUBJECTNAME}_AM_thr_bin.nii.gz

	flirt -usesqform -in ${MASKSPATH}/reduced_aphg.nii.gz -ref ${MIDVOLUME} -applyxfm -out ${SUBJECTNAME}_EC.nii.gz
	fslmaths ${SUBJECTNAME}_EC.nii.gz -thr 0.5 ${SUBJECTNAME}_EC_thr.nii.gz
	fslmaths ${SUBJECTNAME}_EC_thr.nii.gz -bin ${SUBJECTNAME}_EC_thr_bin.nii.gz

	flirt -usesqform -in ${MASKSPATH}/ninBilatHipp.nii.gz -ref ${MIDVOLUME} -applyxfm -out ${SUBJECTNAME}_HC.nii.gz
	fslmaths ${SUBJECTNAME}_HC.nii.gz -thr 0.5 ${SUBJECTNAME}_HC_thr.nii.gz
	fslmaths ${SUBJECTNAME}_HC_thr.nii.gz -bin ${SUBJECTNAME}_HC_thr_bin.nii.gz

	flirt -usesqform -in ${MASKSPATH}/resl_prhmanualreduced.nii.gz -ref ${MIDVOLUME} -applyxfm -out ${SUBJECTNAME}_PRC.nii.gz
	fslmaths ${SUBJECTNAME}_PRC.nii.gz -thr 0.5 ${SUBJECTNAME}_PRC_thr.nii.gz
	fslmaths ${SUBJECTNAME}_PRC_thr.nii.gz -bin ${SUBJECTNAME}_PRC_thr_bin.nii.gz

	flirt -usesqform -in ${MASKSPATH}/ninPPHR.nii.gz -ref ${MIDVOLUME} -applyxfm -out ${SUBJECTNAME}_PHC.nii.gz
	fslmaths ${SUBJECTNAME}_PHC.nii.gz -thr 0.5 ${SUBJECTNAME}_PHC_thr.nii.gz
	fslmaths ${SUBJECTNAME}_PHC_thr.nii.gz -bin ${SUBJECTNAME}_PHC_thr_bin.nii.gz

	flirt -usesqform -in ${MASKSPATH}/allAMTL.nii.gz -ref ${MIDVOLUME} -applyxfm -out ${SUBJECTNAME}_allAMTL.nii.gz
	fslmaths ${SUBJECTNAME}_allAMTL.nii.gz -thr 0.5 ${SUBJECTNAME}_allAMTL_thr.nii.gz
	fslmaths ${SUBJECTNAME}_allAMTL_thr.nii.gz -bin ${SUBJECTNAME}_allAMTL_thr_bin.nii.gz
done

echo "done"
