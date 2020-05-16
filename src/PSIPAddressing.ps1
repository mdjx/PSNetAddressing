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
        [ValidateRange(0,32)]
        [int]$SubnetLength,

        [switch]$ReturnAllIPs
    )

    [IPAddress]$IPAddress = $IPAddress

    if ($SubnetLength) {
        [IPAddress]$SubnetMask = ([Math]::Pow(2,$SubnetLength) -1) * [Math]::Pow(2, (32 - $SubnetLength))
    } 
    else {
        [IPAddress]$SubnetMask = $SubnetMask
        $SMReversed = $SubnetMask.GetAddressBytes()
        [array]::Reverse($SMReversed)
        [IPAddress]$SMReversed = $SMReversed

        [int]$SubnetLength = [convert]::ToString($SMReversed.Address,2).replace(0,'').length
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
    switch ($SubnetLength) {
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
            $TotalIPs = [Math]::pow(2,(32 - $SubnetLength))
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
        SubnetLength = $SubnetLength
        WildcardMask = ($WildcardMask).IPAddressToString
        NetworkId = ($NetworkId).IPAddressToString
        Broadcast = ($Broadcast).IPAddressToString
        FirstIP = ($FirstIP).IPAddressToString
        LastIP = ($LastIP).IPAddressToString
        TotalIPs = $TotalIPs
        UsableIPs = $UsableIPs
        AllIPs = $AllIPs
    }

    Write-Output $obj | Select-Object NetworkId, Broadcast, SubnetMask, SubnetLength, WildcardMask, FirstIP, LastIP, TotalIPs, UsableIPs, AllIPs

    <#

        Tests
        Get-IPDetails -IPAddress 10.250.1.100 -SubnetLength 24
        Get-IPDetails -IPAddress 10.0.0.255 -SubnetLength 8
        Get-IPDetails -IPAddress 192.168.1.129 -SubnetLength 16
        Get-IPDetails -IPAddress 10.255.255.255 -SubnetLength 32
        Get-IPDetails -IPAddress 10.1.1.1 -SubnetLength 30

        Required Input
        - IP address
        - Subnet mask or prefix

        Desired output
        [done] - Start IP (network id)
        [done] - End IP (broadcast)
        [done] - Array of all IPs (?)
        [done] - CIDR notation prefix
        [done]  - Subnet mask
        [done] - Number of hosts
        - Is RFC1918
        [done] - Wildcard
        - fix /32 first last etc 
        - testing (lol)
        - binary output?
    #>

    <# Notes

    Converting an IP to an intiger, 10.250.1.100 example

    $x = ([IPAddress]((10*256*256*256)+(250*256*256)+(1*256)+(100)))
    $x


    Address            : 184156516
    AddressFamily      : InterNetwork
    ScopeId            :
    IsIPv6Multicast    : False
    IsIPv6LinkLocal    : False
    IsIPv6SiteLocal    : False
    IsIPv6Teredo       : False
    IsIPv4MappedToIPv6 : False
    IPAddressToString  : 100.1.250.10

    Note that the order is reversed, so we need to fix that

    $z = $x.GetAddressBytes()
    [array]::Reverse($z)
    $z = [IPAddress]$z


    Address            : 1677851146
    AddressFamily      : InterNetwork
    ScopeId            :
    IsIPv6Multicast    : False
    IsIPv6LinkLocal    : False
    IsIPv6SiteLocal    : False
    IsIPv6Teredo       : False
    IsIPv4MappedToIPv6 : False
    IPAddressToString  : 10.250.1.100
    #>

    
}