#!/bin/bash
#$ -S /bin/bash
#$ -o /ifshome/disaev/log -j y  ###### Path to your own log file directory 


#----Wrapper for shape version of mass_uv_regr.R script.
#----See readme to change the parameters for your data
#-Dmitry Isaev
#-Boris Gutman
#-Neda Jahanshad
# Beta version for testing on sites.
#-Imaging Genetics Center, Keck School of Medicine, University of Southern California
#-ENIGMA Project, 2015
# enigma@ini.usc.edu 
# http://enigma.ini.usc.edu
#-----------------------------------------------

#---Section 1. Script directories
scriptDir=/ifs/loni/faculty/thompson/four_d/disaev/mass_uv_regr/script
resDir=/ifs/loni/faculty/thompson/four_d/disaev/mass_uv_regr/res
logDir=/ifs/loni/faculty/thompson/four_d/disaev/mass_uv_regr/log

if [ ! -d $scriptDir ]
then
   mkdir -p $scriptDir
fi

if [ ! -d $resDir ]
then
   mkdir -p $resDir
fi

if [ ! -d $logDir ]
then
   mkdir -p $logDir
fi


#---Section 2. Configuration variables-----

RUN_ID="IJSHAPES"
CONFIG_PATH="https://docs.google.com/spreadsheets/d/1AxtW4xN8ETZUHvztqqkF0jD68Mm_5SNPWV2Y6HPFrh8"
SITE="indiana"
DATADIR="/ifs/loni/faculty/thompson/four_d/disaev/Indiana_Joint/data/"
ROI_LIST=("10" "11") # "12" "13" "17" "18" "26" "49" "50" "51" "52" "53" "54" "58")
SUBJECTS_COV="/ifs/loni/faculty/thompson/four_d/disaev/Indiana_Joint/config_studyIndiana.csv"
EXCLUDE_FILE="/ifs/loni/faculty/thompson/four_d/disaev/Indiana_Joint/config_exclude.csv"
SHAPE_METR_PREFIX=""

#Nnodes=${#ROI_LIST[@]} 	#Set number of nodes to the length of ROI list
Nnodes=1		#Set number of nodes to 1 if running without grid

#---Section 3. DO NOT EDIT. some additional processing of arbitrary variables
if [ "$EXCLUDE_FILE" != "" ]; then
	EXCLUDE_STR="-exclude_path $EXCLUDE_FILE"
else
	EXCLUDE_STR=""
fi

if [ "$SHAPE_METR_PREFIX" != "" ]; then
	SHAPE_METR_PREFIX_STR="-shape_prefix $SHAPE_METR_PREFIX"
else
	SHAPE_METR_PREFIX_STR=""
fi


#---Section 4. DO NOT EDIT. qsub variable ---
#cur_roi=${ROI_LIST[${SGE_TASK_ID}-1]}  
Nroi=${#ROI_LIST[@]}	
if [ $Nnodes == 1 ]
then
	SGE_TASK_ID=1
fi
NchunksPerTask=$((Nroi/Nnodes))
start_pt=$(($((${SGE_TASK_ID}-1))*${NchunksPerTask}+1))
end_pt=$((${SGE_TASK_ID}*${NchunksPerTask}))

if [ "$SGE_TASK_ID" == "$Nnodes" ]
then
end_pt=$((${Nroi}))
fi

#---Section 5. R binary
#Rbin=/usr/local/R-2.9.2_64bit/bin/R
Rbin=/usr/local/R-3.1.3/bin/R

#---Section 6. DO NOT EDIT. Running the R script
cd $scriptDir
echo "CHANGING DIRECTORY into $scriptDir"

OUT=log.txt
touch $OUT
for ((i=${start_pt}; i<=${end_pt};i++));
do
	cur_roi=${ROI_LIST[$i-1]}  

	cmd="${Rbin} --no-save --slave --args\
			${RUN_ID}\
			${SITE} \
			${DATADIR} \
			${logDir} \
			${resDir}
			${SUBJECTS_COV} \
			${cur_roi} \
			${CONFIG_PATH} \
			${EXCLUDE_STR} \
			${SHAPE_METR_PREFIX_STR} \
			<  ${scriptDir}//mass_uv_regr.R
		"
	echo $cmd
	echo $cmd >> $OUT
	eval $cmd
done
