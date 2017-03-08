#! /bin/bash -eu
#OPTIONS OLD_OPENSHIFT_USERNAME OLD_OPENSHIFT_PASSWORD OLD_OPENSHIFT_URL OLD_OPENSHIFT_PROJECT
#NEW_OPENSHIFT_USERNAME NEW_OPENSHIFT_PASSWORD NEW_OPENSHIFT_URL NEW_OPENSHIFT_PROJECT
# /bin/sh export.sh -opts=dc,is,build,svc,template -ou=old-user -opp=old-user -ourl=https://144.217.161.255:8443 
# -op=test -nu=new-user -npp=new-user -nurl=https://144.217.161.255:8443 -np=test


main(){
	readeParam "$@"
	executeExport
	
	#echo "Number files in SEARCH PATH with EXTENSION:" $(ls -1 "${SEARCHPATH}"/*."${EXTENSION}" | wc -l)
	#if [[ -n $1 ]]; then
	#	echo "Last line of file specified as non-opt/last argument:"
	#	tail -1 $1
	#fi

}
executeExport(){
	if [[ -z "${OPTIONS}" ]]
		OPTIONS=all
	fi
	cd $OPENSHIFT_OC_HOME && \
		/bin/oc login -u ${OLD_OPENSHIFT_USERNAME} -p ${OLD_OPENSHIFT_PASSWORD} ${OLD_OPENSHIFT_URL} && \
		/bin/oc project ${OLD_OPENSHIFT_PROJECT} && \
		/bin/oc export ${OPTIONS} -o json >> ${OLD_OPENSHIFT_PROJECT}.json && \
		/bin/oc logout && \
		/bin/oc login -u ${NEW_OPENSHIFT_USERNAME} -p ${NEW_OPENSHIFT_PASSWORD} ${NEW_OPENSHIFT_URL} && \
		/bin/oc delete project ${NEW_OPENSHIFT_PROJECT} && \
		/bin/oc new-project ${NEW_OPENSHIFT_PROJECT} && \
		/bin/oc create ${pwd}/${OLD_OPENSHIFT_PROJECT}.json -f -
	
}
println(){
	echo "FILE OPTIONS  = ${OPTIONS}"
	
	echo "FILE OLD_OPENSHIFT_USERNAME  = ${OLD_OPENSHIFT_USERNAME}"
	echo "SEARCH OLD_OPENSHIFT_PASSWORD     = ${OLD_OPENSHIFT_PASSWORD}"
	echo "LIBRARY OLD_OPENSHIFT_URL    = ${OLD_OPENSHIFT_URL}"
	echo "LIBRARY OLD_OPENSHIFT_PROJECT    = ${OLD_OPENSHIFT_PROJECT}"
	
	echo "LIBRARY NEW_OPENSHIFT_USERNAME    = ${NEW_OPENSHIFT_USERNAME}"
	echo "LIBRARY NEW_OPENSHIFT_PASSWORD    = ${NEW_OPENSHIFT_PASSWORD}"
	echo "LIBRARY NEW_OPENSHIFT_PASSWORD    = ${NEW_OPENSHIFT_URL}"
	echo "LIBRARY NEW_OPENSHIFT_PROJECT    = ${NEW_OPENSHIFT_PROJECT}"
}
readeParam(){
	for i in "$@"
	do
	case $i in
		-opts=*|--options=*)
		OPTIONS="${i#*=}"
		shift
		;;
		-ou=*|--old-username=*)
		OLD_OPENSHIFT_USERNAME="${i#*=}"
		shift
		;;
		-opp=*|--old-password=*)
		OLD_OPENSHIFT_PASSWORD="${i#*=}"
		shift
		;;
		-ourl=*|--old_URL=*)
		OLD_OPENSHIFT_URL="${i#*=}"
		shift
		;;
		-op=*|--old-project=*)
		OLD_OPENSHIFT_PROJECT="${i#*=}"
		shift
		;;
		
		-nu=*|--new-username=*)
		NEW_OPENSHIFT_USERNAME="${i#*=}"
		shift
		;;
		-npp=*|--new-password=*)
		NEW_OPENSHIFT_PASSWORD="${i#*=}"
		shift
		;;
		-nurl=*|--new-URL=*)
		NEW_OPENSHIFT_URL="${i#*=}"
		shift
		;;
		-np=*|--new-project=*)
		NEW_OPENSHIFT_PROJECT="${i#*=}"
		shift
		;;
		--default)
		DEFAULT=YES
		shift
		;;
		*)
		;;
	esac
	done
}
main "$@"