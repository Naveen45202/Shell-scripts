newip=${newip}
desc="${BUILD_USER_FIRST_NAME}"
profile=${profile}
#secgid=""
ports="1433 1521 3389"


function modify_ip()
{
c=0
for port in $ports
do
    rules=$(aws ec2 describe-security-groups --profile "$profile" --filters Name=ip-permission.to-port,Values="$port" Name=ip-permission.from-port,Values="$port" Name=ip-permission.protocol,Values=tcp --group-ids "$secgid" --output text --query 'SecurityGroups[*].{IP:IpPermissions[?ToPort==`'"$port"'`].IpRanges}' | sed 's/IP//g' | grep "$desc" | awk '{print $1}')
for ip in $rules
do
if [[ $ip != 'null' ]]
then
    c=$((c+1))
    aws ec2 revoke-security-group-ingress --profile "$profile" --group-id "$secgid" --protocol tcp --port "$port" --cidr "$ip" &>/dev/null
fi
done
if [[ $c != 0 ]]
then
    aws ec2 authorize-security-group-ingress --profile "$profile" --group-id "$secgid"  --ip-permissions IpProtocol=tcp,FromPort="$port",ToPort="$port",IpRanges='[{CidrIp="'"${newip}"'",Description="'"$desc"'"}]' &>/dev/null
fi
c=0
done
}
if [ "$profile" = "citiqa" ]; then
	secgid="sg-00874ce8f1b44fe11"
	eval=${secgid}
    modify_ip
fi

if [ "$profile" = "scbqa" ]; then
	secgid="sg-0ba1f2a96a1af0f2d"
	eval=${secgid}
    modify_ip
fi

if [ "$profile" = "v2lab_Jboss" ]; then
	secgid="sg-0c029cc3fc63f9fcd"
	eval=${secgid}
    modify_ip
fi

if [ "$profile" = "v5lab_Jboss" ]; then
	secgid="sg-020729fbf41cea131"
	eval=${secgid}
    modify_ip
fi

if [ "$profile" = "v5lab_tomcat" ]; then
	secgid="sg-0da4a9e875b50260f"
	eval=${secgid}
    modify_ip
fi
