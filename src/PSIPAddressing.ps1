function Get-IPNetwork {
    [CmdletBinding()]

    Param(
        [Parameter(Mandatory)]
        [ValidateScript({$_ -eq ([IPAddress]$_).IPAddressToString})]
        [string]$IPAddress,

        [Parameter(Mandatory, ParameterSetName="SubnetMask")]
        [ValidateScript({$_ -eq ([IPAddress]$_).IPAddressToString})]
        [ValidateScript({
            $SMReversed = [IPAddress]$_
            $SMReversed = $SMReversed.GetAddressBytes()
            [array]::Reverse($SMReversed)
            [IPAddress]$SMReversed = $SMReversed
            [convert]::ToString($SMReversed.Address,2) -match "^[1]*0{0,}$"
        })]
        [string]$SubnetMask,

        [Parameter(Mandatory, ParameterSetName="CIDRNotation")]
        [ValidateRange(1,32)]
        [int]$PrefixLength,

        [switch]$ReturnAllIPs
    )

    [IPAddress]$IPAddress = $IPAddress

    if ($PrefixLength) {
        [IPAddress]$SubnetMask = ([Math]::Pow(2,$PrefixLength) -1) * [Math]::Pow(2, (32 - $PrefixLength))
    } 
    else {
        [IPAddress]$SubnetMask = $SubnetMask
        $SMReversed = $SubnetMask.GetAddressBytes()
        [array]::Reverse($SMReversed)
        [IPAddress]$SMReversed = $SMReversed

        [int]$PrefixLength = [convert]::ToString($SMReversed.Address,2).replace(0,'').length
    }

    
    $FullMask = [UInt32]'0xffffffff'
    $WildcardMask = [IPAddress]($SubnetMask.Address -bxor $FullMask)
    $NetworkId = [IPAddress]($IPAddress.Address -band $SubnetMask.Address)
    $Broadcast = [IPAddress](($FullMask - $NetworkId.Address) -bxor $SubnetMask.Address)

    # Used for determining first usable IP Address
    $FirstIPByteArray = $NetworkId.GetAddressBytes()
    [Array]::Reverse($FirstIPByteArray)

    # Used for determining last usable IP Address
    $LastIPByteArray = $Broadcast.GetAddressBytes()
    [Array]::Reverse($LastIPByteArray)

    # Handler for /31, /30 CIDR prefix values, and default for all others.  
    switch ($PrefixLength) {
        31 {
            $TotalIPs = 2
            $UsableIPs = 2
            $FirstIP = $NetworkId
            $LastIP = $Broadcast
            $FirstIPInt = ([IPAddress]$FirstIPByteArray).Address
            $LastIPInt = ([IPAddress]$LastIPByteArray).Address
            break;
        }

        32 {
            $TotalIPs = 1
            $UsableIPs = 1
            $FirstIP = $IPAddress
            $LastIP = $IPAddress
            $FirstIPInt = ([IPAddress]$FirstIPByteArray).Address
            $LastIPInt = ([IPAddress]$LastIPByteArray).Address
            break;
        }

        default {

            # Usable Address Space
            $TotalIPs = [Math]::pow(2,(32 - $PrefixLength))
            $UsableIPs = $TotalIPs - 2

            # First usable IP
            $FirstIPInt = ([IPAddress]$FirstIPByteArray).Address + 1
            $FirstIP = [IPAddress]$FirstIPInt
            $FirstIP = ($FirstIP).GetAddressBytes()
            [Array]::Reverse($FirstIP)
            $FirstIP = [IPAddress]$FirstIP

            # Last usable IP
            $LastIPInt = ([IPAddress]$LastIPByteArray).Address - 1
            $LastIP = [IPAddress]$LastIPInt
            $LastIP = ($LastIP).GetAddressBytes()
            [Array]::Reverse($LastIP)
            $LastIP = [IPAddress]$LastIP
        }
    }

    $AllIPs = [System.Collections.ArrayList]@()
    if ($ReturnAllIPs) {

        if ($UsableIPs -ge 500000) {
            Write-Warning ('ReturnAllIPs: Generating an array containing {0:N0} IPs, this may take a little while' -f $UsableIPs)
        }

        $CurrentIPInt = $FirstIPInt

        Do {
            $IP = [IPAddress]$CurrentIPInt
            $IP = ($IP).GetAddressBytes()
            [Array]::Reverse($IP)
            $IP = ([IPAddress]$IP).IPAddressToString
            [void]$AllIPs.Add($IP)

            $CurrentIPInt++

        } While ($CurrentIPInt -le $LastIPInt)
    }


    $obj = New-Object -TypeName psobject -Property @{
        SubnetMask = ($SubnetMask).IPAddressToString
        PrefixLength = $PrefixLength
        WildcardMask = ($WildcardMask).IPAddressToString
        NetworkId = ($NetworkId).IPAddressToString
        Broadcast = ($Broadcast).IPAddressToString
        FirstIP = ($FirstIP).IPAddressToString
        LastIP = ($LastIP).IPAddressToString
        TotalIPs = $TotalIPs
        UsableIPs = $UsableIPs
        AllIPs = $AllIPs
    }

    Write-Output $obj | Select-Object NetworkId, Broadcast, SubnetMask, PrefixLength, WildcardMask, FirstIP, LastIP, TotalIPs, UsableIPs, AllIPs
}