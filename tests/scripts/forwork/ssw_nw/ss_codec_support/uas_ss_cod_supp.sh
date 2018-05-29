#!/bin/bash

# Пути
SRC_PATH=~/test/ss_codec_support
TEMP_PATH=~/test/temp
mkdir $TEMP_PATH/ss_codec_support
LOG_PATH=~/test/log
SIPP_PATH=~/sipp


$SIPP_PATH/sipp $1 -sf $SRC_PATH/uas_cod_supp.xml -inf $TEMP_PATH/ss_codec_support/B.csv -mi $2 -s $4 -ap $4 -nd -i $2 -p $3 -m 1 -timeout 20 -timeout_error&



