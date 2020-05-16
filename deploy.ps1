Deploy 'PSIPAddressing - Module Deployment' {

    By Filesystem {
        FromSource "src"
        To "$Home\Documents\WindowsPowerShell\Modules\PSIPAddressing"
        WithOptions @{
            Mirror = $True
        }
    }

    By Task RenamePs1FilesToPsm1 {
        Get-ChildItem "$Home\Documents\WindowsPowerShell\Modules\PSIPAddressing" -Filter "*.ps1" | Rename-Item -NewName {$_.BaseName + ".psm1"}
    }
}