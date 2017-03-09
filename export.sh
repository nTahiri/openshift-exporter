#! /bin/bash -eu
#OPTIONS OLD_OPENSHIFT_USERNAME OLD_OPENSHIFT_PASSWORD OLD_OPENSHIFT_URL OLD_OPENSHIFT_PROJECT
#NEW_OPENSHIFT_USERNAME NEW_OPENSHIFT_PASSWORD NEW_OPENSHIFT_URL NEW_OPENSHIFT_PROJECT
# /bin/sh export.sh -opts=dc,is,build,svc,template -ou=old-user -opp=old-user -ourl=https://144.217.161.255:8443
# -op=test -nu=new-user -npp=new-user -nurl=https://144.217.161.255:8443 -np=test


main(){
        readeParam "$@"
        #println
        executeExport

        #echo "Number files in SEARCH PATH with EXTENSION:" $(ls -1 "${SEARCHPATH}"/*."${EXTENSION}" | wc -l)
        #if [[ -n $1 ]]; then
        #       echo "Last line of file specified as non-opt/last argument:"
        #       tail -1 $1
        #fi

}
executeExport(){
        if [[ -z "${OPTIONS}" ]]; then
                OPTIONS=all
        fi
        [ -e ${OLD_OPENSHIFT_PROJECT}.json ] && rm ${OLD_OPENSHIFT_PROJECT}.json
#       cd $OPENSHIFT_OC_HOME && unset KUBECONFIG && \
                echo "===> login to ${OLD_OPENSHIFT_URL} " && \
                echo "====> oc login -u ${OLD_OPENSHIFT_USERNAME} -p ${OLD_OPENSHIFT_PASSWORD} ${OLD_OPENSHIFT_URL} --insecure-skip-tls-verify "
                ./oc login -u ${OLD_OPENSHIFT_USERNAME} -p ${OLD_OPENSHIFT_PASSWORD} ${OLD_OPENSHIFT_URL} --insecure-skip-tls-verify && \

                echo "===> connect to project ${OLD_OPENSHIFT_PROJECT}" && \
                #/bin/oc project ${OLD_OPENSHIFT_PROJECT} && \

                echo "===> export ${OPTIONS} " && \
                ./oc export ${OPTIONS} -o json >> ${OLD_OPENSHIFT_PROJECT}.json && \

                #################################
                jq '(. | select(.kind=="List") | .items[] | select(.kind=="Route") | .spec.host) = ""' ${OLD_OPENSHIFT_PROJECT}.json  > ${OLD_OPENSHIFT_PROJECT}-1.json
                mv -f ${OLD_OPENSHIFT_PROJECT}-1.json ${OLD_OPENSHIFT_PROJECT}.json

                jq '(. | select(.kind=="List") | .items[] | select(.kind=="Route") | .spec.status.ingress[0].host) = ""' ${OLD_OPENSHIFT_PROJECT}.json  > ${OLD_OPENSHIFT_PROJECT}-1.json
                mv -f ${OLD_OPENSHIFT_PROJECT}-1.json ${OLD_OPENSHIFT_PROJECT}.json




                jq --arg ns "$NEW_OPENSHIFT_PROJECT" '(. | select(.kind=="List") | .items[] | select(.kind=="BuildConfig") | .spec.strategy.sourceStrategy.from.namespace) = $ns' ${OLD_OPENSHIFT_PROJECT}.json  > ${OLD_OPENSHIFT_PROJECT}-1.json
                mv -f ${OLD_OPENSHIFT_PROJECT}-1.json ${OLD_OPENSHIFT_PROJECT}.json


                 jq --arg ns "$NEW_OPENSHIFT_PROJECT" '(. | select(.kind=="List") | .items[] | select(.kind=="DeploymentConfig") | .spec.triggers[] | select(.type=="ImageChange") | .imageChangeParams.from.namespace) = $ns' ${OLD_OPENSHIFT_PROJECT}.json  > ${OLD_OPENSHIFT_PROJECT}-1.json
                mv -f ${OLD_OPENSHIFT_PROJECT}-1.json ${OLD_OPENSHIFT_PROJECT}.json

                 jq --arg ns "$NEW_OPENSHIFT_PROJECT" '(. | select(.kind=="List") | .items[] | select(.kind=="Template") | .objects[] | select(.kind=="BuildConfig") | .spec.strategy.sourceStrategy.from.namespace) = $ns' ${OLD_OPENSHIFT_PROJECT}.json  > ${OLD_OPENSHIFT_PROJECT}-1.json
                mv -f ${OLD_OPENSHIFT_PROJECT}-1.json ${OLD_OPENSHIFT_PROJECT}.json

                #################################

                ls && \
                echo "===> logout ****" && \
                ./oc logout && \

                echo "===> login to ${NEW_OPENSHIFT_URL} " && \
                ./oc login -u ${NEW_OPENSHIFT_USERNAME} -p ${NEW_OPENSHIFT_PASSWORD} ${NEW_OPENSHIFT_URL} --insecure-skip-tls-verify && \

                ./oc new-project ${NEW_OPENSHIFT_PROJECT} && \

                #echo "===>  login to ${NEW_OPENSHIFT_URL} " && \
                #/bin/oc delete project ${NEW_OPENSHIFT_PROJECT} && \

                echo "===> connect to project ${NEW_OPENSHIFT_PROJECT} " && \
                ./oc project ${NEW_OPENSHIFT_PROJECT} && \

                echo "===> create $(pwd)/${OLD_OPENSHIFT_PROJECT}.json " && \
                ./oc create -f $(pwd)/${OLD_OPENSHIFT_PROJECT}.json

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
