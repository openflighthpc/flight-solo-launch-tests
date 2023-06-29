#!/bin/bash

LARGE_INSTANCES=$(aws ec2 describe-instance-types --filters 'Name=processor-info.supported-architecture,Values=x86_64' --query 'InstanceTypes[*].InstanceType' --output yaml |awk '{print $2}' |grep '\.large' |sort)

# Meta
AMI="ami-05e583debc06bfa95" # Located via public image search for Flight Solo to get the marketplace AMI ID for region
SG="sg-024669f290995f546" # FlightSoloSG

AMI_NAME=$(aws ec2 describe-images --image-ids $AMI --query 'Images[*].Name' --output text)

SSH="ssh -q -o StrictHostKeyChecking=no -o PasswordAuthentication=no -o ConnectTimeout=10"

# Launch
function test_type() {
    local name="ImageLaunchTest-$type"
    echo "Launching '$AMI_NAME' on '$type'"
    local launch=$(aws ec2 run-instances --image-id $AMI --count 1 --instance-type $type --key-name openflight_aws_default --security-group-ids $SG --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$name}]")
    local id=$(echo "$launch" |grep InstanceId |sed 's/.*: "//g;s/".*//g')
    if [[ -z ${id} ]] ; then 
        echo "  Instance Launch: FAIL"
        echo "FAIL: Instance type '$type'" 
        return 1
    fi
    echo "  Instance Launch: OK ($id - $name)"
    wait=$(aws ec2 wait instance-status-ok --instance-ids $id --no-paginate 2>/dev/null)
    if [ $? -ne 0 ] ; then
        echo "  Instance Status: FAIL ($wait)"
        echo "FAIL: Instance type '$type'" 
        local kill=$(aws ec2 terminate-instances --instance-ids $id)
        return 1
    fi
    echo "  Instance Status: OK"
    local count=1
    local countmax=30
    local IP=$(aws ec2 describe-instances --instance-id $id --query 'Reservations[*].Instances[*].PublicIpAddress' --output text)
    until $SSH flight@$IP exit  </dev/null 2>/dev/null ; do
        sleep 5 
        local count=$((count + 1))
        if [[ $count == $countmax ]] ; then
            echo "  SSH Status: FAIL"
            echo "FAIL: Instance type '$type'" 
            local kill=$(aws ec2 terminate-instances --instance-ids $id)
            return 1
        fi
    done
    echo "  SSH Status: OK"
    echo "SUCCESS: Instance type '$type'"
    local kill=$(aws ec2 terminate-instances --instance-ids $id)
}

for type in $LARGE_INSTANCES ; do 
    echo "Launching '$AMI_NAME' on '$type'"
    test_type $type > logs/$type.log &
    sleep 10 # Space out AWS calls so no API rate limiting occurs (fingers crossed) 
done

echo
echo "Waiting for all tests to complete..."
wait
echo

echo "##### SUCCESSES #####"
grep '^SUCCESS' logs/*.log
echo
echo "##### FAILURES #####"
grep '^FAIL' logs/*.log
echo
