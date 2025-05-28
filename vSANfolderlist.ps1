#---------------------------------------------------------------------------------------------------------
# The core logic that returns a list of folders for each datastore, is in the code shared by William Lam
# https://github.com/lamw/vmware-scripts/blob/master/powershell/List-VSANDatastoreFolders.ps1
#--------------------------------------------------------------------------------------------------------
<# Author: Abhilash GB 
With all due credit to the code shared by William Lam my intention here is to share the code that can be used to generate seperate a CSV for each vCenter in your environment . 
I hope this would save some time for anyone else with a similar requirement.
#>
#----------------------------------------------------------------
Disconnect-VIServer -Server * -Force -Confirm:$false
#List all in-session vCenter Connections
$global:DefaultVIServers
#Capturing Script Start Time
$startTime = Get-Date
# Capture the credentials for vCenter - assuming all vcenters use the same credentials
$vccreds = Get-Credential -Message "Enter vCenter Credentials"

#Store a list of all vCenters in the environment
$vcenters = @{'vc01','vc02','vc03'};
$vcenters.count 

#Setting a location for the output CSV the script will create
Set-Location -Path "C:\outputs\"

foreach ($vcenter in $vcenters) {
    Write-host "Connecting to vCenter: $vcenter"
    Connect-VIServer -Server $vcenter -Credential $vccreds -ErrorAction Stop
    $vSANDatastores = Get-Datastore | Where-Object {$_Type -eq "vsan"}
    
    #cycle through each vSAN datastore
    forach($datastore in $vSANDatastores) {
       $dsname = $datastore.Name
       # Call William Lam's function to get the folder list for the datastore
       $folderList = List-VSANDatastoreFolders $dsname
       $csv = "$($vcenter)_$($datastore.Name).csv"
       $folderList | Export-Csv -Path $csv -NoTypeInformation
    } #end for-loop for datastore
    Disconnect-VIServer -Server $vcenter".vdescribed.lab" -Confirm:$false
}
#Capturing Script End Time
$endTime = Get-Date
