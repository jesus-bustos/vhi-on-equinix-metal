Virtuozzo Hybrid Ingfrastructure deployment on Equinix Metal

1. Login to your Equinix Metal Portal and Select Deploy on Demand

![Screenshot 2024-09-24 at 16 34 14](https://github.com/user-attachments/assets/2ce83578-a314-43c2-be69-69e474c99bf5)

2. Choose the Metro (Location) 
 
![Screenshot 2024-09-24 at 16 34 27](https://github.com/user-attachments/assets/cc71572b-479b-4bf6-aed7-990c82f93b25)

3. Name the Baremetal Server type  m3.large.x86
![Screenshot 2024-09-24 at 16 34 37](https://github.com/user-attachments/assets/37e3cb97-d639-4017-b866-35d3a3bc85e6)

4. Choose desired Options for Network Default would work
![Screenshot 2024-09-24 at 16 34 46](https://github.com/user-attachments/assets/1cde0a91-c561-4472-9df7-fb51ff226574)

5. Populate the User Data Section with the parameters relevant to the deployment
![Screenshot 2024-09-24 at 16 35 24](https://github.com/user-attachments/assets/653f20c6-c8b2-45d8-8bf5-e4b2e6fe16e6)

Available parameters are:

password='YourPassword' #Password 
private_ip="192.168.30.100" #IP of the Management network IP of the Control Plane
cluster_name="EquinixMetal" #Name of the Storage Cluster
type="compute" #Type of deployment 
compute_addons="metering,k8saas,lbsaas" # this will deploy, Gnocchi, Kubernetes as a Service and LoadBalancer as a Service addon. 
