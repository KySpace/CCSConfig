Param (
  [ValidateScript({
      if( -Not ($_ | Test-Path) ){throw "File or folder does not exist"}
      return $true
  })]
  [System.IO.FileInfo]$repopath
)

Import-Module -Name .\XMLHelpers.psm1

$target = "TM4C123GH6PM"

### Read the configuration files in XML
$configfile = Join-Path $repopath "targetConfigs" ("Tiva " + $target + ".ccxml")
$ccsstartupPath = Join-Path $repopath ($target.ToLower() + "_startup_ccs.c")
$ccsprojecPath      = Join-Path $repopath ".ccsproject" 
$cprojectPath       = Join-Path $repopath ".cproject"   
$projectPath        = Join-Path $repopath ".project"    
[xml]$ccsproject    = Get-Content -Path $ccsprojecPath 
[xml]$cproject      = Get-Content -Path $cprojectPath  
[xml]$project       = Get-Content -Path $projectPath  

### Validate whether this is a path for the desired target
# If (-Not (Test-Path $configfile)) {throw $target + ": required config file not found"}
If ($ccsproject.projectOptions.deviceVariant.value -ne ("Cortex M." + $target)) {throw $target + ": .ccsproject not set to target"}

### Variables (Set in CCS Preferences)
# C/C++ >> Build >> Build Variables
$includeroot = "`${TIVAWARE_DIR}"
# General >> Workspace >> Linked Resources >> Variables
$linkedresrcroot = "TIVAWARE_DIR"

### XML Manipulation

# [.cproject] CCS Build >> ARM Compiler >> Include Options >> Add dir to search path
[xml]$includeOption = @"
<listOptionValue builtIn="false" value="$includeroot"/>
"@
Add-UniqueSubNodeAt "//option[@valueType='includePath']" $includeOption $cproject

# [.cproject] CCS Build >> ARM Linker >> File Search Path >> Include library file or command file 
$linksearch = $includeroot + "/driverlib/ccs/Debug/driverlib.lib" 
[xml]$linkerSearchPath = @"
<listOptionValue builtIn="false" value="$linksearch"/>
"@
Add-UniqueSubNodeAt "//option[@valueType='libs']" $linkerSearchPath $cproject

### Operations

# Remove the ccs startup file
If(Test-Path $ccsstartupPath) {$ccsstartupPath | Resolve-Path | Remove-Item}

# Modify xml nodes and overwrite file
$cproject.Save($cprojectPath)

# Copy .gitignore
Copy-Item .\sample.gitignore -Destination (Join-Path $repopath ".gitignore")