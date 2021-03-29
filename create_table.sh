#!/bin/bash

SOURCEPATH=/mnt/DATA/MTL/Masked_ICA/???????/ROI_MTL_50pc/
OUTPUTPATH=/mnt/DATA/MTL/Masked_ICA/???????/ROI_MTL_50pc/masks/

paste ${SOURCEPATH}/*.txt | column >> ${OUTPUTPATH}/results.txt
echo -e "allAMTL\tAM\tEC\tHC\tPPHC\tPRC" | cat - ${OUTPUTPATH}/results.txt &> ${OUTPUTPATH}/TSNR_table.txt
echo "done"
