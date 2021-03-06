#!/bin/sh

. ../common/procedures.sh

err=0
slow=0

eid=`imunes -b OSPF1.imn | tail -1 | cut -d' ' -f4`
startCheck "$eid"

sleep 60
pingCheck pc@$eid 10.0.4.10
if [ $? -eq 0 ]; then
    netDump router2@$eid eth2
    sleep 3
    echo ""
    echo "########## router2@$eid routes"

    himage router2@$eid vtysh << __END__
    show ip ospf route
    exit
__END__
    if [ $? -ne 0 ]; then
	err=1
    elif [ $slow -eq 1 ]; then
	stopNode router7@$eid
	if [ $? -eq 0 ]; then
	    sleep 45

	    echo ""
	    echo "########## router2@$eid routes after 45 seconds"

	    himage router2@$eid vtysh << __END__
	    show ip ospf route
	    exit
__END__

	    startNode router7@$eid
	    if [ $? -eq 0 ]; then
		sleep 5
		pingCheck pc@$eid 10.0.4.10
		err=$?
	    else
		err=1
	    fi
	else
	    err=1
	fi
    fi
else
    err=1
fi

readDump router2@$eid eth2
imunes -b -e $eid

thereWereErrors $err
