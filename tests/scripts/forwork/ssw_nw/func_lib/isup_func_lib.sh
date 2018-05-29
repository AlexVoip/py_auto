#!/bin/bash

Path_filename=`readlink -e "$0"`
Path=`dirname "$Path_filename"`

########################################################################################################
#  	Формирование ISUP последовательностей вызывающего и вызываемого абонентов (IAM)
########################################################################################################
#	Формирование параметров:
#	Calling
#	Called
#	Lcalling
#	Lcalled
#	Pointer

#	Input variables:
#	NUM_CALLING
#	NUM_CALLED
#       NATURE_CALLING
#       NATURE_CALLED

#	Output variables:
#	HEX_CALLING
#	HEX_CALLED
#	LCALLIN
#	LCALLED
#	POINTER
########################################################################################################

IAM_primary()
{
# Извлечение и преобразование номера вызывающего абонента 

# Формирование массива номера вызывающего абонента

str=$NUM_CALLING
NA=0

while [ -n "$str" ]; do	
  temp=${str#?}  			# Все кроме первого символа
  char=${str%"$temp"}  			# Только первый символ
  arrayA+=($char) 			# добавление символа в массив
  str=$temp  				# восстановление строки без первого символа
  NA=$[$NA+1]
done
oddeven_cg=($char)

# Создание Lcalling: Parameter length for calling

if [ $NA -eq 3 ] || [ $NA -eq 5 ] || [ $NA -eq 7 ] || [ $NA -eq 9 ] || [ $NA -eq 11 ]; then 
  arrayA+=(0)
  oddeven_cg=8   #1 in fact, but we dont use first three bits in nature
  NA=$[$NA+1]
  Lcalling=$[2+$NA/2]
else
  oddeven_cg=0
  Lcalling=$[2+$NA/2]
fi

# Формирование инжекционной последовательности

M=1
binarA=''

while [ $NA -ge $M ]; do
  bi=${arrayA[$[$M]]}${arrayA[$[$M-1]]}
  M=$[$M+2]
  binarA=${binarA}'\'x${bi}
done


# Извлечение и преобразование номера вызываемого абонента

# Формирование массива номера вызываемого абонента

str=$NUM_CALLED
NB=0

while [ -n "$str" ]; do
  temp=${str#?}  
  char=${str%"$temp"}  
  array+=($char) 
  str=$temp  
  NB=$[$NB+1]
done
oddeven_cd=($char)

# Создание Lcalled: Parameter length for called

if [ $NB -eq 1 ] || [ $NB -eq 3 ] || [ $NB -eq 5 ] || [ $NB -eq 7 ] || [ $NB -eq 9 ] || [ $NB -eq 11 ]; then
  array+=(f)
  NB1=$NB
  oddeven_cd=0
else
  NB1=$[$NB+2]
  array+=(f)
  array+=(0)
  oddeven_cd=8   #1 in fact, but we dont use first three bits in nature
fi

# Формирование инжекционной последовательности

M=1
binarB=''

while [ $NB1 -ge $M ]; do
  bi=${array[$[$M]]}${array[$[$M-1]]}
  M=$[$M+2]
  binarB=${binarB}'\'x${bi}
done


# Создание Lcalled: Parameter length for calling

if [ $NB -eq 2 ] || [ $NB -eq 4 ] || [ $NB -eq 6 ] || [ $NB -eq 8 ] || [ $NB -eq 10 ]; then 
  NB=$[$NB+1]
  Lcalled=$[3+$NB/2]
else
  Lcalled=$[3+$NB/2]
fi

# Создание Pointer: Pointer to Parameter

Pointer=$[$Lcalled+2]

# Заполнение глобальных переменных

HEX_CALLING=$binarA
HEX_CALLED=$binarB
LCALLIN=$Lcalling
LCALLED=$Lcalled
POINTER=$Pointer
NCALLING='\x'$oddeven_cg$NATURE_CALLING
NCALLED='\x'$oddeven_cd$NATURE_CALLED

export NCALLED
export NCALLING
export HEX_CALLING
export HEX_CALLED
export LCALLIN
export LCALLED
export POINTER
}

########################################################################################################
#		Формирование ISUP последовательностей NCI, FCI, CPC, TMR для IAM
########################################################################################################
#	Input variables:
#	NCI_ABCD
#	NCI_EFGH
#	FCI_ABCD_1
#	FCI_EFGH_1
#	FCI_ABCD_2
#	FCI_EFGH_2
#	CPC_2_IAM
#	TMR_1
#	TMR_2
#	Output variables:
#	NCI_HEX
#	FCI_HEX_1
#	FCI_HEX_2
#	CPC_HEX_IAM
#	TMR_HEX
########################################################################################################

IAM_secondary()
{
#	NCI

BIN=$NCI_ABCD

conv4BINto1HEX

ABCD_HEX=$HEX

BIN=$NCI_EFGH

conv4BINto1HEX 

EFGH_HEX=$HEX

NCI_HEX=$EFGH_HEX$ABCD_HEX

export NCI_HEX

#	FCI 1 octet

BIN=$FCI_ABCD_1

conv4BINto1HEX

ABCD_HEX=$HEX

BIN=$FCI_EFGH_1

conv4BINto1HEX 

EFGH_HEX=$HEX

FCI_HEX_1=$EFGH_HEX$ABCD_HEX
export FCI_HEX_1

#	FCI 2 octet

BIN=$FCI_ABCD_2

conv4BINto1HEX

ABCD_HEX=$HEX

BIN=$FCI_EFGH_2

conv4BINto1HEX 

EFGH_HEX=$HEX

FCI_HEX_2=$EFGH_HEX$ABCD_HEX

export FCI_HEX_2

#	CPC

BIN=$CPC_2_IAM

conv4BINto1HEX

CPC_HEX_IAM=$HEX

export CPC_HEX_IAM

#	TMR

BIN=$TMR_1

conv4BINto1HEX

TMR_HEX_1=$HEX

BIN=$TMR_2

conv4BINto1HEX

TMR_HEX_2=$HEX

TMR_HEX=$TMR_HEX_1$TMR_HEX_2

export TMR_HEX
}

########################################################################################################
#		Формирование ISUP последовательностей CPC для CPG, ACM и других
########################################################################################################
#	Input variables:
#	CPC_IJKL
#	CPC_MNOP
#	Output variables:
#	CPC_HEX
########################################################################################################

CPC()
{
BIN=$CPC_IJKL

conv4BINto1HEX

CPC_HEX_IJKL=$HEX

BIN=$CPC_MNOP

conv4BINto1HEX 

CPC_HEX_MNOP=$HEX

CPC_HEX=$CPC_HEX_MNOP$CPC_HEX_IJKL

export CPC_HEX
}

########################################################################################################
#		Формирование полной IAM последовательности со стандартными NCI, FCI, CPC, TMN
########################################################################################################
#	Input variables:
#	NUM_CALLING
#	NUM_CALLED
#       NATURE_CALLING
#       NATURE_CALLED
#	Output variables:
#	FULL_SEQ_SIMPLE
########################################################################################################

Full_seq_simple()
{
IAM_primary

FULL_SEQ_SIMPLE='\x01\x00\x60\x00\x0a\x03\x02\x0'$POINTER'\x0'$LCALLED$NCALLED'\x10'$HEX_CALLED'\x0a\x0'$LCALLIN$NCALLING'\x13'$HEX_CALLING'\x00'

export FULL_SEQ_SIMPLE
}

########################################################################################################
#	Формирование полных последовательностей для IAM с конфигуриемыми NCI, FCI, CPC, TMN
########################################################################################################
#	Input variables:
#	NUM_CALLING
#	NUM_CALLED
#       NATURE_CALLING
#       NATURE_CALLED
#	NCI_ABCD
#	NCI_EFGH
#	FCI_ABCD_1
#	FCI_EFGH_1
#	FCI_ABCD_2
#	FCI_EFGH_2
#	CPC_2_IAM
#	TMR_1
#	TMR_2
#	Output variables:
#	FULL_SEQ
########################################################################################################

Full_seq()
{
IAM_primary

IAM_secondary

FULL_SEQ='\x01\x'$NCI_HEX'\x'$FCI_HEX_1'\x'$FCI_HEX_2'\x0'$CPC_HEX_IAM'\x'$TMR_HEX'\x02\x0'$POINTER'\x0'$LCALLED$NCALLED'\x10'$HEX_CALLED'\x0a\x0'$LCALLIN$NCALLING'\x13'$HEX_CALLING'\x00'

export FULL_SEQ
}

########################################################################################################
				#Конвертация 4 бит BIN в 1 элемент HEX
########################################################################################################
#	Input variables:
#	BIN
#	Output variables:
#	HEX
########################################################################################################

conv4BINto1HEX()
{

str=$BIN

  unset array[@]

  while [ -n "$str" ]; do			
	temp=${str#?}  
	char=${str%"$temp"}  	
	array+=($char) 
	str=$temp 
  done

  M=1
  N=3
  S=0

  while [ 4 -ge $M ]; do
  	array[$N]=$[${array[$N]}*2**S]
  	M=$[$M+1]
  	N=$[$N-1]
  	S=$[$S+1]
  done

  Conv=$[${array[0]}+${array[1]}+${array[2]}+${array[3]}]

  if [ $Conv -eq 10 ]; then
	hex=a
  elif [ $Conv -eq 11 ];then
	hex=b
  elif [ $Conv -eq 12 ];then
	hex=c
  elif [ $Conv -eq 13 ];then
	hex=d
  elif [ $Conv -eq 14 ];then
 	hex=e
  elif [ $Conv -eq 15 ];then
	hex=f
  else
  	hex=$Conv
  fi

  unset array[@]

HEX=$hex
export HEX
}

########################################################################################################
#       Формирование Redirect number and redirect info
########################################################################################################
#       Input variables:
#       NUM_REDIR
#       NATURE_REDIR
#       ORIG_RED
#       CUR_RED
#       COUNT_RED
#       Output variables:
#	HEX_REDIR
#	LREDIR
#	REDIR_INFO
#	NREDIR
########################################################################################################

IAM_redirect()
{
# Извлечение и преобразование номера переадресующего абонента 

# Формирование массива номера переадресующего абонента

str=$NUM_REDIR
NA=0

while [ -n "$str" ]; do
  temp=${str#?}                         # Все кроме первого символа
  char=${str%"$temp"}                   # Только первый символ
  arrayR+=($char)                       # добавление символа в массив
  str=$temp                             # восстановление строки без первого символа
  NA=$[$NA+1]
done
oddeven_red=($char)

# Создание Lredir: Parameter length for redirecting

if [ $NA -eq 3 ] || [ $NA -eq 5 ] || [ $NA -eq 7 ] || [ $NA -eq 9 ] || [ $NA -eq 11 ]; then 
  arrayR+=(0)
  oddeven_red=8   #1 in fact, but we dont use first three bits in nature
  NA=$[$NA+1]
  Lredir=$[2+$NA/2]
else
  oddeven_red=0
  Lredir=$[2+$NA/2]
fi

# Формирование инжекционной последовательности

M=1
binarR=''

while [ $NA -ge $M ]; do
  bi=${arrayR[$[$M]]}${arrayR[$[$M-1]]}
  M=$[$M+2]
  binarR=${binarR}'\'x${bi}
done

# Формирование redirect info

REDIR_INFO='\x'$ORIG_RED'3\x'$CUR_RED$COUNT_RED

# Заполнение глобальных переменных

HEX_REDIR=$binarR
LREDIR=$Lredir
NREDIR='\'x$oddeven_red$NATURE_REDIR

export HEX_REDIR
export LREDIR
export REDIR_INFO
export NREDIR
}

########################################################################################################
#       Формирование Origin num
########################################################################################################
#       Input variables:
#       NUM_ORIGIN
#       NATURE_ORIGIN
#       Output variables:
#       HEX_ORIGIN
#       LORIGIN
#       NORIGIN
########################################################################################################

IAM_origin()
{
# Извлечение и преобразование номера изначально вызываемого абонента 

# Формирование массива номера переадресующего абонента

str=$NUM_ORIGIN
NA=0

while [ -n "$str" ]; do
  temp=${str#?}                         # Все кроме первого символа
  char=${str%"$temp"}                   # Только первый символ
  arrayO+=($char)                       # добавление символа в массив
  str=$temp                             # восстановление строки без первого символа
  NA=$[$NA+1]
done

# Создание Lorigin: Parameter length for original

if [ $NA -eq 3 ] || [ $NA -eq 5 ] || [ $NA -eq 7 ] || [ $NA -eq 9 ] || [ $NA -eq 11 ]; then 
  arrayO+=(0)
  oddeven_or=8   #1 in fact, but we dont use first three bits in nature
  NA=$[$NA+1]
  Lorigin=$[2+$NA/2]
else
  oddeven_or=0
  Lorigin=$[2+$NA/2]
fi

# Формирование инжекционной последовательности

M=1
binarO=''

while [ $NA -ge $M ]; do
  bi=${arrayO[$[$M]]}${arrayO[$[$M-1]]}
  M=$[$M+2]
  binarO=${binarO}'\'x${bi}
done

# Заполнение глобальных переменных

HEX_ORIGIN=$binarO
LORIGIN=$Lorigin
NORIGIN='\'x$oddeven_or$NATURE_ORIGIN

export HEX_ORIGIN
export LORIGIN
export NORIGIN
}

########################################################################################################
#       Формирование полных последовательностей для IAM с конфигуриемыми NCI, FCI, CPC, TMN 
#       + Redirect, Original
########################################################################################################
#       Input variables:
#       NUM_CALLING
#       NUM_CALLED
#       NATURE_CALLING
#       NATURE_CALLED
#       NCI_ABCD
#       NCI_EFGH
#       FCI_ABCD_1
#       FCI_EFGH_1
#       FCI_ABCD_2
#       FCI_EFGH_2
#       CPC_2_IAM
#       TMR_1
#       TMR_2
#	NUM_REDIR
#	NUM_ORIGIN
#       NATURE_REDIR
#       NATURE_ORIGIN
#	ORIG_RED
#	CUR_RED
#	COUNT_RED
#       Output variables:
#       FULL_SEQ_REDIR
########################################################################################################

Full_seq_redir()
{
IAM_primary
IAM_secondary
IAM_redirect
IAM_origin
FULL_SEQ_REDIR='\x01\x'$NCI_HEX'\x'$FCI_HEX_1'\x'$FCI_HEX_2'\x0'$CPC_HEX_IAM'\x'$TMR_HEX'\x02\x0'$POINTER'\x0'$LCALLED$NCALLED'\x10'$HEX_CALLED'\x0a\x0'$LCALLIN$NCALLING'\x13'$HEX_CALLING'\x0b\x0'$LREDIR$NREDIR'\x13'$HEX_REDIR'\x13\x02'$REDIR_INFO'\x28\x0'$LORIGIN$NORIGIN'\x13'$HEX_ORIGIN'\x00'

export FULL_SEQ_REDIR
}


########################################################################################################
#       Формирование Generic num
########################################################################################################
#       Input variables:
#       NUM_GENERIC
#       NATURE_GENERIC
#	QUALIFIER
#       Output variables:
#       HEX_GENERIC
########################################################################################################

IAM_generic()
{
# Извлечение и преобразование номера

# Формирование массива номера

str=$NUM_GENERIC
NA=0

while [ -n "$str" ]; do
  temp=${str#?}                         # Все кроме первого символа
  char=${str%"$temp"}                   # Только первый символ
  arrayGen+=($char)                       # добавление символа в массив
  str=$temp                             # восстановление строки без первого символа
  NA=$[$NA+1]
done

# Создание Parameter length for number

if [ $NA -eq 3 ] || [ $NA -eq 5 ] || [ $NA -eq 7 ] || [ $NA -eq 9 ] || [ $NA -eq 11 ]; then 
  arrayGen+=(0)
  oddeven_gen=8   #1 in fact, but we dont use first three bits in nature
  NA=$[$NA+1]
  Lgen=$[3+$NA/2]
else
  oddeven_gen=0
  Lgen=$[3+$NA/2]
fi

# Формирование инжекционной последовательности

M=1
binarGen=''

while [ $NA -ge $M ]; do
  bi=${arrayGen[$[$M]]}${arrayGen[$[$M-1]]}
  M=$[$M+2]
  binarGen=${binarGen}'\'x${bi}
done

# Заполнение глобальных переменных

HEX_GENERIC='\xC0\x0'$Lgen'\x0'$QUALIFIER'\x'$oddeven_gen$NATURE_GENERIC'\x13'$binarGen

export HEX_GENERIC
}

########################################################################################################
#       Формирование полных последовательностей для IAM с конфигуриемыми NCI, FCI, CPC, TMN 
#       + Redirect, Original, Generic
########################################################################################################
#       Input variables:
#       NUM_CALLING
#       NUM_CALLED
#       NATURE_CALLING
#       NATURE_CALLED
#       NCI_ABCD
#       NCI_EFGH
#       FCI_ABCD_1
#       FCI_EFGH_1
#       FCI_ABCD_2
#       FCI_EFGH_2
#       CPC_2_IAM
#       TMR_1
#       TMR_2
#       NUM_REDIR
#       NUM_ORIGIN
#       NATURE_REDIR
#       NATURE_ORIGIN
#       ORIG_RED
#       CUR_RED
#       COUNT_RED
#       NUM_GENERIC
#       NATURE_GENERIC
#       QUALIFIER
#       Output variables:
#       FULL_SEQ_REDIR_GENERIC
########################################################################################################

Full_seq_redir_generic()
{
IAM_primary
IAM_secondary
IAM_redirect
IAM_origin
IAM_generic
FULL_SEQ_REDIR_GENERIC='\x01\x'$NCI_HEX'\x'$FCI_HEX_1'\x'$FCI_HEX_2'\x0'$CPC_HEX_IAM'\x'$TMR_HEX'\x02\x0'$POINTER'\x0'$LCALLED$NCALLED'\x10'$HEX_CALLED'\x0a\x0'$LCALLIN$NCALLING'\x13'$HEX_CALLING'\x0b\x0'$LREDIR$NREDIR'\x13'$HEX_REDIR'\x13\x02'$REDIR_INFO'\x28\x0'$LORIGIN$NORIGIN'\x13'$HEX_ORIGIN$HEX_GENERIC'\x00'

export FULL_SEQ_REDIR_GENERIC
}

########################################################################################################
#       Формирование полных последовательностей для IAM с конфигуриемыми NCI, FCI, CPC, TMN 
#       + Generic
########################################################################################################
#       Input variables:
#       NUM_CALLING
#       NUM_CALLED
#       NATURE_CALLING
#       NATURE_CALLED
#       NCI_ABCD
#       NCI_EFGH
#       FCI_ABCD_1
#       FCI_EFGH_1
#       FCI_ABCD_2
#       FCI_EFGH_2
#       CPC_2_IAM
#       TMR_1
#       TMR_2
#       NUM_GENERIC
#       NATURE_GENERIC
#       QUALIFIER
#       Output variables:
#       FULL_SEQ_GENERIC
########################################################################################################

Full_seq_generic()
{
IAM_primary
IAM_secondary
IAM_generic
FULL_SEQ_GENERIC='\x01\x'$NCI_HEX'\x'$FCI_HEX_1'\x'$FCI_HEX_2'\x0'$CPC_HEX_IAM'\x'$TMR_HEX'\x02\x0'$POINTER'\x0'$LCALLED$NCALLED'\x10'$HEX_CALLED'\x0a\x0'$LCALLIN$NCALLING'\x13'$HEX_CALLING$HEX_GENERIC'\x00'

export FULL_SEQ_GENERIC
}
