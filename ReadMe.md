# VcpkgManifest.psm1
A powershell module for manipulating vcpkg manifest files

## Commands
The details for using each command can be retrieved using Get-Help
- New-VcpkgManifest
- Update-VcpkgManifest
- Add-VcpkgDependency
- Remove-VcpkgDependency
- Update-VcpkgDependency
- Read-VcpkgManifest
- Write-VcpkgManifest

## Installation
To install clone the repository into a directory contained in your 
PSModulePath environment variable. 

For example:
```powershell
Set-Location $HOME\Documents\WindowsPowerShell\Modules
git clone https://github.com/Chemiseblanc/VcpkgManifest.git
```

## License
This module is available under the terms of the MIT Public License.
A copy of the license text can be found in the file LICENSE.txt
