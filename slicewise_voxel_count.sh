#bash script to creating the input for schematics (i.e., slicewise analysis along the longitudinal axis of the A-MTL) ALRR, 05.06.2019

#!/bin/bash

DATE=`date +%Y%m%d`

##first SPECIFY the path where the dual regressed data will be saved ("SOURCE"), the path to your working folder ("OUTPUT" and "INPUTIMG"), and the path for your log file
ORIGPATH=/mnt/DATA/MTL/Masked_ICA/???????/3_DR_MTL_local_0.5/ica20/ #where DR data are stored
OUTPUTPATH=/mnt/DATA/MTL/Masked_ICA/???????/6_Slicewise/ #where results will be saved
SOURCEPATH=/mnt/DATA/MTL/Masked_ICA/???????/6_Slicewise/DR_local_20/ #working source you want to have (e.g., inside OUTPUTPATH)
LOGPATH=/mnt/DATA/MTL/Masked_ICA/???????/${DATE}_slicewise_log.txt #where log file will be saved to
INPUTIMG=/mnt/DATA/MTL/Masked_ICA/???????/6_Slicewise/ICs/ #slice-split ICs

rm -r ${OUTPUTPATH}
rm -r ${LOGPATH}

date >> ${LOGPATH}
echo "Starting slicewise analysis" >> ${LOGPATH}

mkdir ${OUTPUTPATH}
mkdir ${SOURCEPATH}

##copying the respective image files from the data folder
cp ${ORIGPATH}/dr_stage3_ic0???_tfce_corrp_tstat1.nii.gz ${SOURCEPATH} >> ${LOGPATH}
#cd $SOURCEPATH
#find . -name "dr_stage3*.txt" -type f -delete #not entirely necessary now that I added the file extension, but just in case!

##stripping the file name to leave in only the IC number (sorry for the little elegant way to do it)
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

##thresholding and binarizing the p-corr images (hence the threshold used is 0.95, 1-0.95 for a p-value threshold of 0.05)
cd $OUTPUTPATH
mkdir DR_local_20_thr_and_bin

for i in ${SOURCEPATH}*
do
	INAME=`basename ${i}`
	echo "thresholding the p-corr images for $INAME..." >> ${LOGPATH}
	fslmaths $i -thr 0.95 ${OUTPUTPATH}/DR_local_20_thr_and_bin/thr_$INAME
done
echo "thresholding done" >> ${LOGPATH}

cp ${OUTPUTPATH}/DR_local_20_thr_and_bin/* ${SOURCEPATH}

rm -r ${SOURCEPATH}/ic*

for thr in ${SOURCEPATH}*
do
	THRNAME=`basename ${thr}`
	echo "binarizing the thresholded images for $THRNAME..." >> ${LOGPATH}
	fslmaths $thr -bin ${OUTPUTPATH}/DR_local_20_thr_and_bin/bin_$THRNAME
done
echo "binarizing done" >> ${LOGPATH}

#to save space, let's remove the image files we don't need now
cp ${OUTPUTPATH}/DR_local_20_thr_and_bin/bin_* ${OUTPUTPATH}
rm -r ${SOURCEPATH}
cd ${OUTPUTPATH}
rm -r 'DR_local_20_thr_and_bin'

#stripping the bin_thr_ prefix from the files
for filename in ${OUTPUTPATH}*
do
	[ -f "$filename" ] || continue
	mv "$filename" "${filename//bin_thr_/}"
done

##create folders for each IC map and each structure
cd ${OUTPUTPATH}
mkdir Input
mv ${OUTPUTPATH}/ic* ${OUTPUTPATH}/Input

mkdir ICs
cd ${OUTPUTPATH}/ICs
mkdir ic{0000..0019} #as many number of ICs you have; the count starts with 0

for SUBJECT in ${INPUTIMG}*
do
	SUBJECTNAME=`basename $SUBJECT`
	echo "creating folder $SUBJECTNAME" >> ${LOGPATH}
	cd ${OUTPUTPATH}/ICs/$SUBJECTNAME
#mkdir of the specific structures you are analyzing
	mkdir AM
	mkdir HC
	mkdir EC
	mkdir PRC
	mkdir PHC
done
echo "done" >> ${LOGPATH}

##multiplying each binary map by each A-MTL structure to obtain structure-specific IC maps
#specify first the path where your mask files are stored
MASKPATH=/mnt/DATA/MTL/Masked_ICA/???????/ROI_MTL_50pc/masks/Effect_sizes/Masks/
for i in ${OUTPUTPATH}/Input/*
do
	INAME=`basename $i`
	echo "multiplying each binary map by each A-MTL structure to obtain structure-specific IC maps for $INAME" >> ${LOGPATH}
	fslmaths $i -mul ${MASKPATH}/ninBilatAmy.nii.gz ${OUTPUTPATH}/ICs/${INAME%%.*}/AM/AM_$INAME >> ${LOGPATH}
	fslmaths $i -mul ${MASKPATH}/ninBilatHipp.nii.gz ${OUTPUTPATH}/ICs/${INAME%%.*}/HC/HC_$INAME >> ${LOGPATH}
	fslmaths $i -mul ${MASKPATH}/reduced_aphg.nii.gz ${OUTPUTPATH}/ICs/${INAME%%.*}/EC/EC_$INAME >> ${LOGPATH}
	fslmaths $i -mul ${MASKPATH}/resl_prhmanualreduced.nii.gz ${OUTPUTPATH}/ICs/${INAME%%.*}/PRC/PRC_$INAME >> ${LOGPATH}
	fslmaths $i -mul ${MASKPATH}/ninPPHR.nii.gz ${OUTPUTPATH}/ICs/${INAME%%.*}/PHC/PHC_$INAME >> ${LOGPATH}
done
echo "done" >> ${LOGPATH}

#within each individual folder, split the image files into the y direction (anterior-posterior; y=42 voxels [-42 mm] to y=65 voxels [4 mm] in MNI space)
for img in ${INPUTIMG}*
do
	IMGNAME=`basename $img`
	echo "now doing fslsplit for $IMGNAME..." >> ${LOGPATH}
	for MTLST in ${INPUTIMG}/${IMGNAME}/*
	do
		MTLSTNAME=`basename $MTLST`
		echo "...in the $MTLSTNAME" >> ${LOGPATH}
		cd ${INPUTIMG}/$IMGNAME/$MTLSTNAME
		fslsplit ${MTLSTNAME}_${IMGNAME}.nii.gz Y_${MTLSTNAME}_$IMGNAME.nii.gz -y >> ${LOGPATH}
	done
done
echo "done" >> ${LOGPATH}

##selecting slices spanning the entire mask and computing the volume with fslstats
for img in ${INPUTIMG}*
do
	IMGNAME=`basename $img`
	for MTLST in ${INPUTIMG}/${IMGNAME}/*
	do
		MTLSTNAME=`basename $MTLST`
		cd ${INPUTIMG}/$IMGNAME/$MTLSTNAME
		#optional, but recommended, to save space: remove additional slices that do not include A-MTL structures
		rm Y*{0000..0040}.nii.gz
		rm Y*{0065..0108}.nii.gz #adjust end of range depending on your image dimensions in y (fslinfo of image and look at dim2)
		echo "computing number of voxels (volume) per slice for $MTLSTNAME of $IMGNAME" >> ${LOGPATH}
		for slice in ${PWD}/*
		do
			SLCNAME=`basename $slice`
			fslstats $slice -V >> $MTLST/slices_${MTLSTNAME}.txt
			tr ' ' '\t' < $MTLST/slices_${MTLSTNAME}.txt 1<> $MTLST/slices_${MTLSTNAME}.txt
		done
	done
done
echo "done" >> ${LOGPATH}

##writing the results to a single text file
seq 4 -2 -42 > $OUTPUTPATH/slice_column.txt #number of slices in y axis
echo "sum" >> $OUTPUTPATH/slice_column.txt #this is necessary because, below, there will be an unnamed row

mkdir ${OUTPUTPATH}/Results_$DATE

for img in ${INPUTIMG}*
do
	IMGNAME=`basename $img`
	paste -d'\0' $img/*/slices*.txt | column >> $img/${IMGNAME}_results.txt
	tac $img/${IMGNAME}_results.txt > $img/${IMGNAME}_ant_post.txt
	paste $OUTPUTPATH/slice_column.txt $img/${IMGNAME}_ant_post.txt > $img/${IMGNAME}_results.txt
	echo -e "slice\tvox_AM\tmm_AM\tvox_EC\tmmEC\tvoxHC\tmmHC\tvoxPHC\tmmPHC\tvoxPRC\tmmPRC" | cat - $img/${IMGNAME}_results.txt &> ${OUTPUTPATH}/Results_$DATE/${IMGNAME}_Table_values.txt
done

echo "slicewise analysis finished!" >> ${LOGPATH}
echo "done"
#echo "slicewise analysis finished!" 2>&1 | tee ${LOGPATH}
