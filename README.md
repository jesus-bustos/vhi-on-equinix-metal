# Virtuozzo Hybrid Ingfrastructure deployment on Equinix Metal

## Prerequisites:

0. You need a VM which acts as the Kickstart server providing access to the rpms and to the Kickstart files
1. Ensure This is reflected on your iPXE configuration file


## Installation: 

0. Login to your Equinix Metal Portal and Select Deploy on Demand

![Screenshot 2024-09-24 at 16 34 14](https://github.com/user-attachments/assets/2ce83578-a314-43c2-be69-69e474c99bf5)


1. Choose the Metro (Location) and pass the URL for the iPXE configuration the first node will be the control plane use this URL https://raw.githubusercontent.com/jesus-bustos/vhi-on-equinix-metal/refs/heads/main/ipxe-install-master-0
 
![Screenshot 2024-09-24 at 16 34 27](https://github.com/user-attachments/assets/cc71572b-479b-4bf6-aed7-990c82f93b25)

For subsequent deployments of nodes, use the relevant iPXE file as an example:
 - for node02 https://raw.githubusercontent.com/jesus-bustos/vhi-on-equinix-metal/refs/heads/main/ipxe-compute-1
 - for node03 https://raw.githubusercontent.com/jesus-bustos/vhi-on-equinix-metal/refs/heads/main/ipxe.compute-2

2. Name the Baremetal Server type  m3.large.x86 
![Screenshot 2024-09-24 at 16 34 37](https://github.com/user-attachments/assets/37e3cb97-d639-4017-b866-35d3a3bc85e6)

3. Choose desired Options for Network Default would work
![Screenshot 2024-09-24 at 16 34 46](https://github.com/user-attachments/assets/1cde0a91-c561-4472-9df7-fb51ff226574)

4. Populate the User Data Section with the parameters relevant to the deployment
![Screenshot 2024-09-24 at 16 35 24](https://github.com/user-attachments/assets/653f20c6-c8b2-45d8-8bf5-e4b2e6fe16e6)

Available parameters for Control Node Deployment are:

password='YourPassword' #Password 
private_ip="192.168.30.100" #IP of the Management network IP of the Control Plane
cluster_name="EquinixMetal" #Name of the Storage Cluster
type="compute" #Type of deployment 
compute_addons="metering,k8saas,lbsaas" # this will deploy, Gnocchi, Kubernetes as a Service and LoadBalancer as a Service addon. 

Available parameters for Compute node Deployment are:

#Configuration variables for deployment script
password="Your Password#"
mn_ip="192.168.30.100"  # Management Node IP Address
type="compute"  # Operational mode, can be 'storage', 'compute', 'ha', 'hacompute', or 'none'
onboard="true"

To deploy subsequent nodes follow instructions 0 to 4.
