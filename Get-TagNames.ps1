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
      [VMware.VimAutomation.ViCore.Types.V1.VIServer]$Server, 

      [Parameter(Mandatory = $False, Position = 2)]
      [string]$category

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
   $filepath = $ScriptRoot+'\'+'taglist1112.json'

   # Retrieve all tags of the category

   if($category){
        $tagList = Get-Tag -Server $Server -Category $category | Select Name, Category
    }
    else{
        $tagList = Get-Tag -Server $Server | Select Name, Category
    }
   
    $tags = @()

    Foreach($item in $tagList){

    $tag = New-Object PSObject

    $tag | add-member -type NoteProperty -Name tagName -Value $item.Name
    $tag | add-member -type NoteProperty -Name categoryName -Value $item.Category.Name

    $tags += $tag
    }



   # Store the tags and categories in a list to export them at once
   $jsondata = ConvertTo-Json $tags 
   # Export the tags specified destination

   if (!(Test-Path $filepath))
  {
    New-Item -path $ScriptRoot -name 'taglist1112.json' -type "file" -value $jsondata
    Write-Host "Created new file and text content added"
  }
  else
  {
    Set-Content -path $filepath -value $jsondata
    Write-Host "File already exists and new text content added"
  }
}
Export-Tag -Server $server