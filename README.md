# PSIPAddressing

PSIPAddressing is a PowerShell module that makes dealing with IP addresses easy. 

Given an IP address and subnet mask or CIDR prefix, it returns a list of all IPs inside the subnet, the Network Id, Broadcast, First and Last Usable IPs, and Wildcard Mask. 

## Why

What do you do when you need a generate a list of all IPs for a network? This is what most of us have been doing:

```powershell
$IPs = @()
$Subnet = "10.1.1"
1..254 | % {$IPs += "$Subnet.$_"}
```

However, this isn't great. Validation for` $Subnet` is difficult, working with anything other than a `/24` also requires a lot of work which makes it impractical to cleanly integrate into modules. 

With `PSIPAddressing`, the above code becomes:

```powershell
$IPs = (Get-IPNetwork -IPAddress 10.1.1.0 -PrefixLength 24 -ReturnAllIPs).AllIPs
```

## Usage

### Get-IPNetwork

`Get-IPNetwork -IPAddress <String> -SubnetMask <String> [-ReturnAllIPs]`
`Get-IPNetwork -IPAddress <String> -PrefixLength <Int> [-ReturnAllIPs]`

#### Parameters

`-IPAddress`

Specifies the IP or network address. 

```yaml
Type: String
Required: True
Example: 10.250.1.100
Example: 192.168.1.1
Example: 46.250.1.66
```

`-SubnetMask`

Specifies the Subnet Mask in dotted decimal notation

```yaml
Type: String
Required: False
Example: 255.255.255.0
Example: 255.255.255.252
Example: 255.255.128.0
```


`-PrefixLength`

Specifies the PrefixLength in slash notation

```yaml
Type: Int
Required: False
Example: 24
Example: 30
Example: 16
```

`-ReturnAllIPs`

If set, returns a populated array property called `AllIPs` that contains all usable IP addresses within the specified subnet. This has been set as an optional switch as large networks can return millioons if not billions of usable IPs, which can consume significant time, CPU, and memory. 

```yaml
Type: SwitchParameter
Required: False
```

## Examples

```powershell
PS C:\> Get-IPNetwork -IPAddress 10.250.1.100 -SubnetMask 255.255.255.0


NetworkId    : 10.250.1.0
Broadcast    : 10.250.1.255
SubnetMask   : 255.255.255.0
SubnetLength : 24
WildcardMask : 0.0.0.255
FirstIP      : 10.250.1.1
LastIP       : 10.250.1.254
TotalIPs     : 256
UsableIPs    : 254
```


```powershell
PS C:\> Get-IPNetwork -IPAddress 10.250.1.100 -PrefixLength 24


NetworkId    : 10.250.1.0
Broadcast    : 10.250.1.255
SubnetMask   : 255.255.255.0
PrefixLength : 24
WildcardMask : 0.0.0.255
FirstIP      : 10.250.1.1
LastIP       : 10.250.1.254
TotalIPs     : 256
UsableIPs    : 254
AllIPs       : {}
```

```powershell
PS C:\> Get-IPNetwork -IPAddress 10.1.1.1 -PrefixLength 30 -ReturnAllIPs


NetworkId    : 10.1.1.0
Broadcast    : 10.1.1.3
SubnetMask   : 255.255.255.252
PrefixLength : 30
WildcardMask : 0.0.0.3
FirstIP      : 10.1.1.1
LastIP       : 10.1.1.2
TotalIPs     : 4
UsableIPs    : 2
AllIPs       : {10.1.1.1, 10.1.1.2}
```

```powershell
PS C:\> Get-IPNetwork -IPAddress 45.122.250.67 -SubnetMask 255.255.255.128 -ReturnAllIPs


NetworkId    : 45.122.250.0
Broadcast    : 45.122.250.127
SubnetMask   : 255.255.255.128
PrefixLength : 25
WildcardMask : 0.0.0.127
FirstIP      : 45.122.250.1
LastIP       : 45.122.250.126
TotalIPs     : 128
UsableIPs    : 126
AllIPs       : {45.122.250.1, 45.122.250.2, 45.122.250.3, 45.122.250.4...}
```

## Installation

### Via Git

Clone the repository and run `.\build.ps1 deploy`.

This will install several modules if you do not already have them, see `build.ps1` for details. These are only required for the build process and are not otherwise used by `PSIPAddressing`.

### Manually

Copy the files from src to `$Home\Documents\WindowsPowerShell\Modules\PSIPAddressing` and rename the `.ps1` file to `.psm1`.

