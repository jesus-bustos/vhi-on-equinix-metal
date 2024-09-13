#!/bin/bash
log_msg() {
    message=$1
    echo "[DEBUG] $(date +'%Y-%m-%d %H:%M:%S,%3N') ${message}" >> "/tmp/deploy.log"
}

function retry {
  local retries=10
  local count=0
  until "$@"; do
    exit=$?
    wait=$((2 ** $count))
    count=$(($count + 1))
    if [ $count -lt $retries ]; then
      log_msg "Retry $count/$retries exited $exit, retrying in $wait seconds..."
      sleep $wait
    else
      log_msg "Retry $count/$retries exited $exit, no more retries left."
      return $exit
    fi
  done
  return 0
}

echo $password |passwd --stdin root
log_msg "changed password to $password"

echo `/usr/bin/openssl rand -hex 8` > /etc/vstorage/host_id
echo `/usr/bin/openssl rand -hex 16` > /etc/machine-id

log_msg "fixing up iscsi initiatorname"
hostid=$(cat /etc/vstorage/host_id | cut -c -12)
echo "InitiatorName=iqn.1994-05.com.redhat:$hostid" > /etc/iscsi/initiatorname.iscsi

systemctl restart systemd-journald  # restart journald after machine-id was changed
sed -i '/NODE_ID =/d' /etc/vstorage/vstorage-ui-agent.conf
echo "NODE_ID = '`/usr/bin/openssl rand -hex 16`'" >> /etc/vstorage/vstorage-ui-agent.conf

log_msg "generated new uuids for machine"

systemctl start vstorage-ui-agent
log_msg "started vstorage-ui-agent service"
# let backend initialize completely
# don't edit this delays without coordinated changes in master.sh
sleep 10

log_msg "getting token from Management Node to perform registration"

token=""

while [ -z "$token" ]; do
    log_msg "token is empty, retrying"
    sleep 10
    token=`retry sshpass -p $password ssh -o 'StrictHostKeyChecking=no' -o LogLevel=ERROR root@$mn_ip "echo $password | vinfra node token show -f json | jq -r '.token'"`
done

if [ -z "$token" ]; then
    log_msg "Unable to get registration token. Exiting..."
    exit 1
fi

log_msg "registering the node..."
retry /usr/libexec/vstorage-ui-agent/bin/register-storage-node.sh -m $mn_ip -t "${token}" -x bond0
log_msg "registering the node...done"

node_id=`sed -n 's/^NODE_ID =//p' /etc/vstorage/vstorage-ui-agent.conf`

if [ "$type" == "none" ]; then
    log_msg "Clean installation was requested, no clusters will be deployed."
    exit 0
fi

log_msg "joining the storage cluster..."
retry sshpass -p $password ssh -o 'StrictHostKeyChecking=no' -o LogLevel=ERROR root@$mn_ip "vinfra --vinfra-password $password node join ${node_id} --wait"
log_msg "joining the storage cluster...done"

log_msg "setting Public interface roles..."
retry sshpass -p $password ssh -o 'StrictHostKeyChecking=no' -o LogLevel=ERROR root@$mn_ip "vinfra --vinfra-password $password node iface set --wait --node ${node_id} --network Public bond0 --wait"
log_msg "setting Public interface roles...done"

log_msg "setting Private interface roles..."
retry sshpass -p $password ssh -o 'StrictHostKeyChecking=no' -o LogLevel=ERROR root@$mn_ip "vinfra --vinfra-password $password node iface set --wait --node ${node_id} --network Private bond1.502 --wait"
log_msg "setting Private interface roles...done"
if [ "$onboard" == "true" ]; then
    log_msg "joining the compute cluster..."
retry vinfra service compute node add --compute  $(hostname -s) --wait --vinfra-password $password
log_msg "joining the compute cluster...done"
    exit 0
fi
