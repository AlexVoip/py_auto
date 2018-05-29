#!/usr/bin/env bash
# Скрипт Алексея Ершова для связи с Jenkins

#set -x

OPT=$1
LAST=$2
REDMINE=1
[ z"$OPT" = zr ] && REDMINE=1

smg_board()
{
    case $BOARD in
        smg1016m) BOARD=SMG1016M
    ;;
        smg2016) BOARD=SMG2016
    ;;
    esac
}

sbc_board()
{
    case $BOARD in
        smg1016m) BOARD=SBC
    ;;
        smg2016) BOARD=SBC2k
    ;;
    esac
}

sigtran_board()
{
    case $BOARD in
        smg1016m) BOARD=SMG1016M SIGTRAN
    ;;
        smg2016) BOARD=SMG2016 SIGTRAN
    ;;
    esac
}

sigtran_board()
{
    case $BOARD in
        smg1016m) BOARD=SMG1016M SORM
    ;;
        smg2016) BOARD=SMG2016 SORM
    ;;
    esac
}

PROJ=http://biser.eltex.loc/view/smg_projects/job/smg
[ ! $LAST ] && LAST=$(wget --header='Accept-Language: en-us' -q -O - $PROJ | grep -E -o "Last build \(\#([0-9])*\)" | grep -o "[0-9]*")
LINKS=$(wget --header='Accept-Language: en-us' -q -O - "$PROJ/$LAST/" | grep artifact | grep -E -o "artifact/[a-z0-9_.]+.bin" | uniq)
#"
for link in $LINKS; do
#artifact/smg1016m_firmware_sbc_1.5.1.14.bin
#artifact/smg2016_firmware_sbc_1.5.1.14.bin

    BOARD=`expr match $link 'artifact/\([a-z0-9]*\)'`
    SOFT=`expr match $link '.*_firmware_\([a-z]*\)'`
    VER=`expr match $link '.*_firmware_[a-z]*_*\([\.0-9]*\)\.bin'`

    if [ $REDMINE -eq 1 ]; then
        case $SOFT in
            "")        smg_board
        ;;
            "sbc")     sbc_board
        ;;
            "sigtran") sigtran_board
        ;;
            "sorm")    sorm_board
        ;;
        esac

        #VER=$(echo $link | grep -E -o "firmware_.*" | grep -E -o "[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,2}")
        #BUILD=$(echo $link | grep -E -o "firmware_.*" | grep -E -o "[0-9]{4}")

        #SOFT_INFO="\"$BOARD $VER\":"
    fi

#    echo "${SOFT_INFO}$PROJ/$LAST/$link"
    printf "%s %s %s %s\n" $LAST $BOARD $VER $PROJ/$LAST/$link

#    echo "PROJ: $PROJ"
#    echo "LAST: $LAST"
#    echo "LINK: $link"
done
