#$vCenter = Read-Host -Prompt "Please enter your vCenter IP"
#$Username = Read-Host -Prompt "Please enter your Username"
#$Password = Read-Host -assecurestring "Please enter your Password"


$vCenter = "vc01.pso.lab"
$Username = "administrator@vsphere.local"
$Password = "VMware1!PSO"


Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false


#$server = Connect-VIServer -Server $vCenter -Protocol https -User $Username -Password ([Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)))
$server = Connect-VIServer -Server $vCenter -Protocol https -User $Username -Password $Password



function Export-Tag {
   [CmdletBinding()]
   Param (
      [Parameter(Mandatory = $True, Position = 1)]
      [VMware.VimAutomation.ViCore.Types.V1.VIServer]$server, 

      [Parameter(Mandatory = $False, Position = 2)]
      [string]$CustomAttribute

   )
   
    $ScriptRoot = ""

    Try
    {
        $ScriptRoot = Get-Variable -Name PSScriptRoot -ValueOnly -ErrorAction Stop
    }
    Catch
    {
        $ScriptRoot = Split-Path $script:MyInvocation.MyCommand.Path
    }

   # Calculate the file Path
    $filepath = $ScriptRoot+'\'+'attributelist.json'

   # chck if attributes exist
   $attrInList = Get-CustomAttribute | Select Name | Where-Object {$_.Name -eq $CustomAttribute }

   Write-Host "Cusotom attribute key = " $CustomAttribute

   if($attrInList){

           Write-Host "Find Attribute in vCente"
   
    } else{
           Write-Error "Faild to find input attribute in vCenter, please input correct attribute"
           return     
           
    }

   #(Get-VM -Name "test110").CustomFields.Item($CustomAttribute)

    $Report = @()

    Get-VM | foreach {

      #check if custom attrubite have value  
      if($_.CustomFields.Item($CustomAttribute)) {
         $Summary = "" | Select VMName

         $Summary.VMName = $_.Name
 
         Add-Member -InputObject $Summary -MemberType NoteProperty -Name $CustomAttribute  -Value $_.CustomFields.Item($CustomAttribute)

         $Report += $Summary
       }

    }

    $Report | Export-Csv -Path "$ScriptRoot\outputAttribute.csv" -NoTypeInformation -encoding UTF8
   
    $attributeValue = @()

    Foreach($item in  $Report ){
      
     $attr = New-Object PSObject
     Write-Host  "vmName=" $item.VMName  " ; attr value= " $item.$CustomAttribute
     $attr | add-member -type NoteProperty -Name attrKey -Value $CustomAttribute
     $attr | add-member -type NoteProperty -Name attrValue -Value $item.$CustomAttribute

     if($item.$CustomAttribute -in $attributeValue.attrValue){
         Write-Host "Custom attributr duplicate"  -ForegroundColor White -BackgroundColor Blue
         Write-Host $item.VMName  "  attr= " $item.$CustomAttribute  -ForegroundColor White -BackgroundColor Blue
     } else {
         $attributeValue += $attr
         #Write-Host "add attributr into json "
     }
    }



   # Store the tags and categories in a list to export them at once
   $jsondata = ConvertTo-Json $attributeValue 
   # Export the tags specified destination

   if (!(Test-Path $filepath))
  {
    New-Item -path $ScriptRoot -name 'attributelist.json' -type "file" -value $jsondata
    Write-Host "Created new file and text content added"
  }
  else
  {
    Set-Content -path $filepath -value $jsondata
    Write-Host "File already exists and new text content added"
  }

}

Export-Tag -Server $server -CustomAttribute "AP"

Disconnect-VIServer $server -Confirm:$false