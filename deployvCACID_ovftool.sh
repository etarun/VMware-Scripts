
# Configurations 

# VCACID OVF
VCACID_OVA=VMware-Identity-Appliance-2.0.0.0-1445146_OVF10.ova

# e.g. 172.30.0.141/24 
VCACID_DISPLAY_NAME=lab-vcacid-script_install
VCO_HOSTNAME=lab_vco.ba.asd.com
VCO_PORTGROUP='v10-39-14-0'
VCO_DATASTORE=ds
VCO_DISK_TYPE=thin
VCO_IPADDRESS=IP
VCO_NETMASK=255.255.255.0
VCO_GATEWAY=gateway
VCO_DNS=DNS
VCO_IPPROTOCOL=IPv4

# vCenter or ESX(i)
VCENTER_HOSTNAME=vCS
VCENTER_USERNAME=root
VCENTER_PASSWORD=PASSWORD
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
	if [ ! -e ${VCACID_OVA} ]; then
		cecho "Unable to locate \"${VCACID_OVA}\"!" $red
		exit 1
	fi

	cecho "Would you like to deploy the following configuration for vCAC Identity Appliance?" $yellow
	cecho "\tVMware vCAC Identity Appliance: ${VCACID_OVA}" $green
	cecho "\tVCACID Display Name: ${VCACID_DISPLAY_NAME}" $green
	cecho "\tVCACID Hostname: ${VCACID_HOSTNAME}" $green
	cecho "\tVCACID IP Address: ${VCACID_IPADDRESS}" $green
	cecho "\tVCACID Netmask: ${VCACID_NETMASK}" $green
	cecho "\tVCACID Gateway: ${VCACID_GATEWAY}" $green
	cecho "\tVCACID DNS: ${VCACID_DNS}" $green
	cecho "\tVCACID Portgroup: ${VCACID_PORTGROUP}" $green
	cecho "\tVCACID Datastore: ${VCACID_DATASTORE}" $green
	cecho "\tVCACID Disk Type: ${VCACID_DISK_TYPE}" $green
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

deployVCACIDOVA() {
	OVFTOOl_BIN=/usr/bin/ovftool

	if [ ! -e ${OVFTOOl_BIN} ]; then
		cecho "ovftool does not look like it's installed!" $red
		exit 1
	fi

	cecho "Deploying VMware vCAC Identity Appliance: ${VCACID_DISPLAY_NAME} ..." $cyan
	${OVFTOOl_BIN}  --acceptAllEulas --ipAllocationPolicy=fixedPolicy --powerOn "--net:Network 1=${VCACID_PORTGROUP}" --datastore=${VCACID_DATASTORE} --diskMode=${VCACID_DISK_TYPE} --name=${VCACID_DISPLAY_NAME} --prop:varoot-password=${VCACID_ROOTPASSWORD} --prop:vami.hostname=${VCACID_HOSTNAME} --prop:vami.DNS.VMware_Identity_Appliance=${VCACID_DNS} --prop:vami.gateway.VMware_Identity_Appliance=${VCACID_GATEWAY} --prop:vami.ip0.VMware_Identity_Appliance=${VCACID_IPADDRESS} --prop:vami.netmask0.VMware_Identity_Appliance=${VCACID_NETMASK} ${VCACID_OVA} vi://${VCENTER_USERNAME}:${VCENTER_PASSWORD}@${VCENTER_HOSTNAME}/?dns=${ESXI_HOSTNAME}
}

verify
deployVCACIDOVA
cecho "VMware vCAC Identity Appliance ${VCACID_DISPLAY_NAME} has successfully been deployed!" $cyan
