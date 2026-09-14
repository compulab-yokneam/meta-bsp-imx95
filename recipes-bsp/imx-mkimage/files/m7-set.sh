#!/bin/bash

select_string="$(ls  ../mcore-demos/*m7_TCM*.bin)"
select_string+=" << "
PS3="m7 image: your choice > "

select i in $select_string
do
case $i in
	"<<")
	exit
	break
	;;
	Quit)
	exit
	break
	;;
	*)
	export M7_FILE=${i}
	break
	;;
	esac
done

ln -sf ${M7_FILE} m7_image.bin
