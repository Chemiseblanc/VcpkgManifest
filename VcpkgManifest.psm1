<#
    .Synopsis
    Creates a new vcpkg.json manifest in the current working directroy

    .Parameter Name

    .Parameter Version
#>
Function New-VcpkgManifest {
    Param(
        $Name = (Get-Location | Split-Path -Leaf),
        $Version = "0.1.0"
        )
    @{
        "name"= $Name
        "version" = $Version
        "dependencies" = @()
    } | Write-VcpkgManifest
}
Export-ModuleMember -Function New-VcpkgManifest

<#
    .Synopsis
    Updates the version string in a vcpkg manifest

    .Description
    Updates the version string in a vcpkg manifest. The manifest defaults
    to the vcpkg.json in the current directory but can also be given or piped
    to the function.

    .Parameter Manifest

    .Parameter Version

    .Parameter Dependencies
#>
Function Update-VcpkgManifest {
    Param(
        [Parameter(ValueFromPipeLine=$True)] $Manifest = (Read-VcpkgManifest),
        [string] $Name,
        [string] $Version,
        [PSObject[]] $Dependencies
        )
    if ($Name) {$Manifest.name = $Name}
    if ($Version) {$Manifest.version = $Version}
    if ($Dependencies) {Update-VcpkgDependency -Manifest $Manifest -Dependencies $Dependencies | Out-Null}
    $Manifest | Write-VcpkgManifest
    return $Manifest
}
Export-ModuleMember -Function Update-VcpkgManifest

<#
    .Synopsis
    Add a dependency to the manifest

    .Parameter Manifest

    .Parameter Dependencies
#>
Function Add-VcpkgDependency {
    Param(
        [Parameter(ValueFromPipeLine=$True)] $Manifest = (Read-VcpkgManifest),
        [Parameter(Mandatory=$True)][PSObject[]] $Dependencies
        )
    $Manifest.dependencies += $Dependencies
    $Manifest | Write-VcpkgManifest
    return $Manifest
}
Export-ModuleMember -Function Add-VcpkgDependency

<#
    .Synopsis
    Remove a dependency from the manifest

    .Parameter Manifest

    .Parameter Dependencies
#>
Function Remove-VcpkgDependency {
    Param(
        [Parameter(ValueFromPipeLine=$True)] $Manifest = (Read-VcpkgManifest),
        [Parameter(Mandatory=$True)][PSObject[]] $Dependencies
        )
    $depNamesToRemove = @()
    foreach($dep in $Dependencies) {
        if ($dep -is [string]) {
            $depNamesToRemove += $dep
        } else {
            $depNamesToRemove += $dep.name
        }
    }
    $filteredDeps = $Manifest.dependencies | Where-Object {
        if ($_ -is [string]) {
            $depName = $_
        } else {
            $depName = $_.name
        }
        return $depNamesToRemove -notcontains $depName
    }
    $Manifest.dependencies = [PSObject[]] $filteredDeps
    $Manifest | Write-VcpkgManifest
    return $Manifest
}
Export-ModuleMember -Function Remove-VcpkgDependency

<#
    .Synopsis
    Update an existing dependency in a vcpkg manifest or add it if it doesn't exist

    .Parameter Manifest

    .Parameter Dependencies
#>
Function Update-VcpkgDependency {
    Param(
        [Parameter(ValueFromPipeline=$True)] $Manifest = (Read-VcpkgManifest),
        [Parameter(Mandatory=$True)] [PSObject[]] $Dependencies
        )

    #Update existing dependencies
    $depsUpdated = @()
    :outer forEach($dep in $Manifest.dependencies) {
        forEach($depToUpdate in $Dependencies) {
            $depName = If ($dep -is [string]) {$dep} else {$dep.name}
            $depnameToUpdate = if ($depToUpdate -is [string]) {$depToUpdate} else {$depToUpdate.name}

            if ($depName -like $depNameToUpdate) {
                $dep = $depToUpdate
                $depsUpdated += $depName
                continue outer
            }
        }

    }
    
    # Add new dependencies
    $depsToAdd = @()
    forEach($dep in $Dependencies) {
        $depName = If ($dep -is [string]) {$dep} else {$dep.name}
        if ($depsUpdated -notcontains $depName) { $depsToAdd += $dep }
    }
    if ($depsToAdd.Length -gt 0) {
        Add-VcpkgDependency -Manifest $Manifest -Dependencies $depsToAdd | Out-Null
    } 

    $Manifest | Write-VcpkgManifest
    return $Manifest
}
Export-ModuleMember -Function Update-VcpkgDependency

<#
    .Synopsis
    Read a vcpkg manifest from file

    .Parameter Path
    Path to an existing vcpkg.json
#>
Function Read-VcpkgManifest {
    Param(
        [string] $Path = ".\vcpkg.json"
        )
    $Manifest = Get-Content -Raw -Path $Path -ErrorAction Stop | ConvertFrom-Json
    if ($Manifest.dependencies -eq $null) {$Manifest.dependencies = @()}
    return $Manifest
}
Export-ModuleMember -Function Read-VcpkgManifest


<#
    .Synopsis
	Write the manifest to disk
	
    .Parameter Manifest

    .Parameter Path
#>
Function Write-VcpkgManifest {
    Param(
        [Parameter(Mandatory=$True, ValueFromPipeLine=$True)] $Manifest,
        $Path = ".\vcpkg.json"
        )
    if ($Manifest.dependencies -eq $null) {$Manifest.dependencies = @()}
    ConvertTo-Json -InputObject $Manifest | Out-File -FilePath $Path
}
Export-ModuleMember -Function Write-VcpkgManifest