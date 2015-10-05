
# Configurations 

# vCO OVF
VCO_OVA=VMware-vCenter-Server-Appliance-5.5.0.5100-1312297_OVF10.ova

# e.g. 172.30.0.141/24 
VCO_DISPLAY_NAME=vcs
VCO_HOSTNAME=lab-vcs1.ba.asd.com
VCO_PORTGROUP='v10-39-14-0'
VCO_DATASTORE=datastore
VCO_DISK_TYPE=thin
VCO_IPADDRESS=IP
VCO_NETMASK=255.255.255.0
VCO_GATEWAY=GW
VCO_DNS=DNS
VCO_IPPROTOCOL=IPv4

#ESX(i)
VCENTER_USERNAME=root
VCENTER_PASSWORD=xxxxxxxxxxx
ESXI_HOSTNAME=ESXHOST

############## DO NOT EDIT BEYOND HERE #################


cyan='\E[36;40m'
green='\E[32;40m'
red='\E[31;40m'
yellow='\E[33;40m'

cecho() {
        local default_msg="No message passed."
        message=${1:-$default_msg}
        color=${2:-$green}
        echo -e "$color"
        echo -e "$message"
        tput sgr0

        return
}

verify() {
	if [ ! -e ${VCO_OVA} ]; then
		cecho "Unable to locate \"${VCO_OVA}\"!" $red
		exit 1
	fi

	cecho "Would you like to deploy the following configuration for vCenter Orchestrator?" $yellow
	cecho "\tVMware vCenter Orchestrator Virtual Appliance: ${VCO_OVA}" $green
	cecho "\tvCO Display Name: ${VCO_DISPLAY_NAME}" $green
	cecho "\tvCO Hostname: ${VCO_HOSTNAME}" $green
	cecho "\tvCO IP Address: ${VCO_IPADDRESS}" $green
	cecho "\tvCO Netmask: ${VCO_NETMASK}" $green
	cecho "\tvCO Gateway: ${VCO_GATEWAY}" $green
	cecho "\tvCO DNS: ${VCO_DNS}" $green
	cecho "\tvCO Portgroup: ${VCO_PORTGROUP}" $green
	cecho "\tvCO Datastore: ${VCO_DATASTORE}" $green
	cecho "\tvCO Disk Type: ${VCO_DISK_TYPE}" $green
	cecho "\tvCenter Server: ${VCENTER_HOSTNAME}" $green
	cecho "\tTarget ESX(i) host: ${ESXI_HOSTNAME}" $green

	cecho "\ny|n?" $yellow

	read RESPONSE
        case "$RESPONSE" in [yY]|yes|YES|Yes)
                ;;
                *) cecho "Quiting installation!" $red
                exit 1
                ;;
        esac
}

deployvCOOVA() {
	OVFTOOl_BIN=/usr/bin/ovftool

	if [ ! -e ${OVFTOOl_BIN} ]; then
		cecho "ovftool does not look like it's installed!" $red
		exit 1
	fi

	cecho "Deploying VMware vCenter Orchestrator Virtual Appliance: ${VCO_DISPLAY_NAME} ..." $cyan
	${OVFTOOl_BIN}  --acceptAllEulas --ipAllocationPolicy=fixedPolicy --powerOn "--net:Network 1=${VCO_PORTGROUP}" --datastore=${VCO_DATASTORE} --diskMode=${VCO_DISK_TYPE} --name=${VCO_DISPLAY_NAME} --prop:vami.hostname=${VCO_HOSTNAME} --prop:vami.DNS.VMware_vCenter_Server_Appliance=${VCO_DNS} --prop:vami.gateway.VMware_vCenter_Server_Appliance=${VCO_GATEWAY} --prop:vami.ip0.VMware_vCenter_Server_Appliance=${VCO_IPADDRESS} --prop:vami.netmask0.VMware_vCenter_Server_Appliance=${VCO_NETMASK} ${VCO_OVA} vi://${VCENTER_USERNAME}:${VCENTER_PASSWORD}@${ESXI_HOSTNAME}
}

verify
deployvCOOVA
cecho "VMware vCenter Orchestrator Virtual Appliance ${VCO_DISPLAY_NAME} has successfully been deployed!" $cyan
