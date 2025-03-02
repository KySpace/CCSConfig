# Clean the selected path to keep only .c source files.
# Do this after deleting the project in CCS 
Param (
  [ValidateScript({
  if( -Not ($_ | Test-Path) ){throw "File or folder does not exist"}
      return $true
  })]
  [System.IO.FileInfo]$repopath
)
$currpath = $pwd
Set-Location $repopath 
"git clean -fxd" | Invoke-Expression
Set-Location $currpath
