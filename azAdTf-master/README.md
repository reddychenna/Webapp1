#Create a user in Active Directory
#Save the intial password
#Go to the resource group in which The reosurces are created.
#Add role (Virtual Machine Administrator Login)  for the newly created user for this reosurce group.
# Then the VMs created in this resource group should allow login trhoug AD Credentials.


######## How to change change AZURE subscription 
Change the subscription

  az account set -s  <<subscription id>>

confirm the change in subscription with the below command 

  az account show

Create a Service Principal
    az ad sp create-for-rbac --name ServicePrincipalName3

#######

#Adding capability to inlcude Ad users to the resources
For this we need to install "az vm extension set" and "az role assignment create"  
    1. "az vm extension set"      to enable AD users login to your Reosurces
    2. "az role assignment create" to Create role assginment to the user you wanted 


#added    asdf a commnet for build #######
New line added 


# Azure Dev Ops Pipeline with Terraform.
To use this code, you need to export the required variable in the .bash_profile of the machine from where you want to execute this code.

----------------------------Steps to login to Auzre through terrafrom -----------------

1. Create a Service profile after you login to azure with with 'az login' command'
          az ad sp create-for-rbac --name ServicePrincipalName
2. Above command would give you output like:
          {
  "appId": "11111111-0000-0000-0000-000000000000",
  "displayName": "azure-cli-2017-06-05-10-41-15",
  "name": "http://azure-cli-2017-06-05-10-41-15",
  "password": "ASDF-0000-0000-0000-000000000000",
  "tenant": "22222222-0000-0000-0000-000000000000"
  }
 These values map to the Terraform variables like so:
    appId is the client_id defined above.
    password is the client_secret defined above.
    tenant is the tenant_id defined above.
3. Create your own repo in github .. say yourRepo. 
4. Copy the code in my repo (azvmssPLWithTerraform) to your repo yourRepo. 
5. Update prodiver.tf with the your credentials you have creted for your azure account in step #2.
6. Create a azure devops pipeline. Source code for this repo should be pointing to yourRepo.
7. You are all set to use this repo. 

#
# one more comment to trigger the build
# comment #
