
# Configurations 

# VCACVA OVF
VCACVA_OVA=VMware-vCAC-Appliance-6.0.0.0-1445145_OVF10.ova

# e.g. 172.30.0.141/24 
VCACVA_DISPLAY_NAME=lab-vcacva-script
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
	if [ ! -e ${VCACVA_OVA} ]; then
		cecho "Unable to locate \"${VCACVA_OVA}\"!" $red
		exit 1
	fi

	cecho "Would you like to deploy the following configuration for vCAC Identity Appliance?" $yellow
	cecho "\tVMware vCAC Identity Appliance: ${VCACVA_OVA}" $green
	cecho "\tVCACVA Display Name: ${VCACVA_DISPLAY_NAME}" $green
	cecho "\tVCACVA Hostname: ${VCACVA_HOSTNAME}" $green
	cecho "\tVCACVA IP Address: ${VCACVA_IPADDRESS}" $green
	cecho "\tVCACVA Netmask: ${VCACVA_NETMASK}" $green
	cecho "\tVCACVA Gateway: ${VCACVA_GATEWAY}" $green
	cecho "\tVCACVA DNS: ${VCACVA_DNS}" $green
	cecho "\tVCACVA Portgroup: ${VCACVA_PORTGROUP}" $green
	cecho "\tVCACVA Datastore: ${VCACVA_DATASTORE}" $green
	cecho "\tVCACVA Disk Type: ${VCACVA_DISK_TYPE}" $green
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

deployVCACVAOVA() {
	OVFTOOl_BIN=/usr/bin/ovftool

	if [ ! -e ${OVFTOOl_BIN} ]; then
		cecho "ovftool does not look like it's installed!" $red
		exit 1
	fi

	cecho "Deploying VMware vCAC Identity Appliance: ${VCACVA_DISPLAY_NAME} ..." $cyan
	${OVFTOOl_BIN}  --acceptAllEulas --ipAllocationPolicy=fixedPolicy --powerOn "--net:Network 1=${VCACVA_PORTGROUP}" --datastore=${VCACVA_DATASTORE} --diskMode=${VCACVA_DISK_TYPE} --name=${VCACVA_DISPLAY_NAME} --prop:varoot-password=${VCACVA_ROOTPASSWORD} --prop:vami.hostname=${VCACVA_HOSTNAME} --prop:vami.DNS.VMware_vCAC_Appliance=${VCACVA_DNS} --prop:vami.gateway.VMware_vCAC_Appliance=${VCACVA_GATEWAY} --prop:vami.ip0.VMware_vCAC_Appliance=${VCACVA_IPADDRESS} --prop:vami.netmask0.VMware_vCAC_Appliance=${VCACVA_NETMASK} ${VCACVA_OVA} vi://${VCENTER_USERNAME}:${VCENTER_PASSWORD}@${VCENTER_HOSTNAME}/?dns=${ESXI_HOSTNAME}
}

verify
deployVCACVAOVA
cecho "VMware vCAC Identity Appliance ${VCACVA_DISPLAY_NAME} has successfully been deployed!" $cyan
