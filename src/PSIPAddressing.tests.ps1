. "$PSScriptRoot\PSIPAddressing.ps1"

Describe 'Unit Tests' {

    Context 'Parameter Tests' {
        It 'Throws exception for invalid IP address' {
            {Get-IPNetwork -IPAddress 100.2.3 -SubnetLength 24} | Should Throw "Cannot validate argument on parameter 'IPAddress'"
            {Get-IPNetwork -IPAddress 1 -SubnetLength 24} | Should Throw "Cannot validate argument on parameter 'IPAddress'"
            {Get-IPNetwork -IPAddress "abcd" -SubnetLength 24} | Should Throw "Cannot validate argument on parameter 'IPAddress'"
        }

        It 'Throws exception for invalid subnet mask' {
            {Get-IPNetwork -IPAddress 10.1.1.1 -SubnetMask 255.255.255.} | Should Throw #"Cannot validate argument on parameter 'SubnetMask'"
            {Get-IPNetwork -IPAddress 10.1.1.1 -SubnetMask 255.255.255} | Should Throw #"Cannot validate argument on parameter 'SubnetMask'"
            {Get-IPNetwork -IPAddress 10.1.1.1 -SubnetMask 255.255.0.255} | Should Throw #"Cannot validate argument on parameter 'SubnetMask'"
            {Get-IPNetwork -IPAddress 10.1.1.1 -SubnetMask 128.255.255.0} | Should Throw #"Cannot validate argument on parameter 'SubnetMask'"
            {Get-IPNetwork -IPAddress 10.1.1.1 -SubnetMask "abcd"} | Should Throw #"Cannot validate argument on parameter 'SubnetMask'"
        }

        It 'Throws exception if both SubnetMask and SubnetLength are specified' {
            {Get-IPNetwork -IPAddress 10.1.1.1 -SubnetMask 255.255.255.255 -SubnetLength 24} | Should Throw "Parameter set cannot be resolved using the specified named parameters"
        }

    }

    Context 'Logic Validation' {

        It 'Checks /1 Network Space Using CIDR Notation (lower range)' {
            $Network = Get-IPNetwork -IPAddress 100.2.3.4 -SubnetLength 1
            
            $Network.NetworkId | Should -Be '0.0.0.0'
            $Network.Broadcast | Should -Be '127.255.255.255'
            $Network.SubnetMask | Should -Be '128.0.0.0'
            $Network.SubnetLength | Should -Be 1
            $Network.WildcardMask | Should -Be '127.255.255.255'

            $Network.FirstIP | Should -Be '0.0.0.1'
            $Network.LastIP | Should -Be '127.255.255.254'

            $Network.TotalIPs | Should -Be 2147483648
            $Network.UsableIPs | Should -Be 2147483646
        }

        It 'Checks /1 Network Space Using Subnet Mask Notation  (lower range)' {
            $Network = Get-IPNetwork -IPAddress 100.2.3.4 -SubnetMask 128.0.0.0
            
            $Network.NetworkId | Should -Be '0.0.0.0'
            $Network.Broadcast | Should -Be '127.255.255.255'
            $Network.SubnetMask | Should -Be '128.0.0.0'
            $Network.SubnetLength | Should -Be 1
            $Network.WildcardMask | Should -Be '127.255.255.255'

            $Network.FirstIP | Should -Be '0.0.0.1'
            $Network.LastIP | Should -Be '127.255.255.254'

            $Network.TotalIPs | Should -Be 2147483648
            $Network.UsableIPs | Should -Be 2147483646
        }

        It 'Checks /1 Network Space Using CIDR Notation (upper range)' {
            $Network = Get-IPNetwork -IPAddress 200.2.3.4 -SubnetLength 1
            
            $Network.NetworkId | Should -Be '128.0.0.0'
            $Network.Broadcast | Should -Be '255.255.255.255'
            $Network.SubnetMask | Should -Be '128.0.0.0'
            $Network.SubnetLength | Should -Be 1
            $Network.WildcardMask | Should -Be '127.255.255.255'

            $Network.FirstIP | Should -Be '128.0.0.1'
            $Network.LastIP | Should -Be '255.255.255.254'

            $Network.TotalIPs | Should -Be 2147483648
            $Network.UsableIPs | Should -Be 2147483646
        }

        It 'Checks /1 Network Space Using Subnet Mask Notation  (upper range)' {
            $Network = Get-IPNetwork -IPAddress 200.2.3.4 -SubnetMask 128.0.0.0
            
            $Network.NetworkId | Should -Be '128.0.0.0'
            $Network.Broadcast | Should -Be '255.255.255.255'
            $Network.SubnetMask | Should -Be '128.0.0.0'
            $Network.SubnetLength | Should -Be 1
            $Network.WildcardMask | Should -Be '127.255.255.255'

            $Network.FirstIP | Should -Be '128.0.0.1'
            $Network.LastIP | Should -Be '255.255.255.254'

            $Network.TotalIPs | Should -Be 2147483648
            $Network.UsableIPs | Should -Be 2147483646
        }

        It 'Checks /8 Network Space Using CIDR Notation' {
            $Network = Get-IPNetwork -IPAddress 10.250.1.100 -SubnetLength 8
            
            $Network.NetworkId | Should -Be '10.0.0.0'
            $Network.Broadcast | Should -Be '10.255.255.255'
            $Network.SubnetMask | Should -Be '255.0.0.0'
            $Network.SubnetLength | Should -Be 8
            $Network.WildcardMask | Should -Be '0.255.255.255'

            $Network.FirstIP | Should -Be '10.0.0.1'
            $Network.LastIP | Should -Be '10.255.255.254'

            $Network.TotalIPs | Should -Be 16777216
            $Network.UsableIPs | Should -Be 16777214
        }

        It 'Checks /8 Network Space Using Subnet Mask Notation' {
            $Network = Get-IPNetwork -IPAddress 10.250.1.100 -SubnetMask 255.0.0.0
            
            $Network.NetworkId | Should -Be '10.0.0.0'
            $Network.Broadcast | Should -Be '10.255.255.255'
            $Network.SubnetMask | Should -Be '255.0.0.0'
            $Network.SubnetLength | Should -Be 8
            $Network.WildcardMask | Should -Be '0.255.255.255'

            $Network.FirstIP | Should -Be '10.0.0.1'
            $Network.LastIP | Should -Be '10.255.255.254'

            $Network.TotalIPs | Should -Be 16777216
            $Network.UsableIPs | Should -Be 16777214
        }

        It 'Checks /16 Network Space Using CIDR Notation' {
            $Network = Get-IPNetwork -IPAddress 10.250.1.100 -SubnetLength 16
            
            $Network.NetworkId | Should -Be '10.250.0.0'
            $Network.Broadcast | Should -Be '10.250.255.255'
            $Network.SubnetMask | Should -Be '255.255.0.0'
            $Network.SubnetLength | Should -Be 16
            $Network.WildcardMask | Should -Be '0.0.255.255'

            $Network.FirstIP | Should -Be '10.250.0.1'
            $Network.LastIP | Should -Be '10.250.255.254'

            $Network.TotalIPs | Should -Be 65536
            $Network.UsableIPs | Should -Be 65534
        }

        It 'Checks /16 Network Space Using Subnet Mask Notation' {
            $Network = Get-IPNetwork -IPAddress 10.250.1.100 -SubnetMask 255.255.0.0
            
            $Network.NetworkId | Should -Be '10.250.0.0'
            $Network.Broadcast | Should -Be '10.250.255.255'
            $Network.SubnetMask | Should -Be '255.255.0.0'
            $Network.SubnetLength | Should -Be 16
            $Network.WildcardMask | Should -Be '0.0.255.255'

            $Network.FirstIP | Should -Be '10.250.0.1'
            $Network.LastIP | Should -Be '10.250.255.254'

            $Network.TotalIPs | Should -Be 65536
            $Network.UsableIPs | Should -Be 65534
        }

        
        It 'Checks /24 Network Space Using CIDR Notation' {
            $Network = Get-IPNetwork -IPAddress 10.250.1.100 -SubnetLength 24 -ReturnAllIPs
            
            $Network.NetworkId | Should -Be '10.250.1.0'
            $Network.Broadcast | Should -Be '10.250.1.255'
            $Network.SubnetMask | Should -Be '255.255.255.0'
            $Network.SubnetLength | Should -Be 24
            $Network.WildcardMask | Should -Be '0.0.0.255'

            $Network.FirstIP | Should -Be '10.250.1.1'
            $Network.LastIP | Should -Be '10.250.1.254'

            $Network.TotalIPs | Should -Be 256
            $Network.UsableIPs | Should -Be 254

            $Network.AllIPs.count | Should -Be 254
            $Network.AllIPs[0] | Should -Be '10.250.1.1'
            $Network.AllIPs[-1] | Should -Be '10.250.1.254'
        }

        It 'Checks /24 Network Space Using Subnet Mask Notation' {
            $Network = Get-IPNetwork -IPAddress 10.250.1.100 -SubnetMask 255.255.255.0 -ReturnAllIPs
            
            $Network.NetworkId | Should -Be '10.250.1.0'
            $Network.Broadcast | Should -Be '10.250.1.255'
            $Network.SubnetMask | Should -Be '255.255.255.0'
            $Network.SubnetLength | Should -Be 24
            $Network.WildcardMask | Should -Be '0.0.0.255'

            $Network.FirstIP | Should -Be '10.250.1.1'
            $Network.LastIP | Should -Be '10.250.1.254'

            $Network.TotalIPs | Should -Be 256
            $Network.UsableIPs | Should -Be 254

            $Network.AllIPs.count | Should -Be 254
            $Network.AllIPs[0] | Should -Be '10.250.1.1'
            $Network.AllIPs[-1] | Should -Be '10.250.1.254'
        }

        It 'Checks /30 Network Space Using CIDR Notation' {
            $Network = Get-IPNetwork -IPAddress 10.1.1.1 -SubnetLength 30 -ReturnAllIPs
            
            $Network.NetworkId | Should -Be '10.1.1.0'
            $Network.Broadcast | Should -Be '10.1.1.3'
            $Network.SubnetMask | Should -Be '255.255.255.252'
            $Network.SubnetLength | Should -Be 30
            $Network.WildcardMask | Should -Be '0.0.0.3'

            $Network.FirstIP | Should -Be '10.1.1.1'
            $Network.LastIP | Should -Be '10.1.1.2'

            $Network.TotalIPs | Should -Be 4
            $Network.UsableIPs | Should -Be 2

            $Network.AllIPs.count | Should -Be 2
            $Network.AllIPs[0] | Should -Be '10.1.1.1'
            $Network.AllIPs[-1] | Should -Be '10.1.1.2'
        }

        It 'Checks /30 Network Space Using Subnet Mask Notation ' {
            $Network = Get-IPNetwork -IPAddress 10.1.1.1 -SubnetMask 255.255.255.252 -ReturnAllIPs
            
            $Network.NetworkId | Should -Be '10.1.1.0'
            $Network.Broadcast | Should -Be '10.1.1.3'
            $Network.SubnetMask | Should -Be '255.255.255.252'
            $Network.SubnetLength | Should -Be 30
            $Network.WildcardMask | Should -Be '0.0.0.3'

            $Network.FirstIP | Should -Be '10.1.1.1'
            $Network.LastIP | Should -Be '10.1.1.2'

            $Network.TotalIPs | Should -Be 4
            $Network.UsableIPs | Should -Be 2

            $Network.AllIPs.count | Should -Be 2
            $Network.AllIPs[0] | Should -Be '10.1.1.1'
            $Network.AllIPs[-1] | Should -Be '10.1.1.2'
        }

        It 'Checks /31 Network Space Using CIDR Notation' {
            $Network = Get-IPNetwork -IPAddress 10.1.1.1 -SubnetLength 31 -ReturnAllIPs
            
            $Network.NetworkId | Should -Be '10.1.1.0'
            $Network.Broadcast | Should -Be '10.1.1.1'
            $Network.SubnetMask | Should -Be '255.255.255.254'
            $Network.SubnetLength | Should -Be 31
            $Network.WildcardMask | Should -Be '0.0.0.1'

            $Network.FirstIP | Should -Be '10.1.1.0'
            $Network.LastIP | Should -Be '10.1.1.1'

            $Network.TotalIPs | Should -Be 2
            $Network.UsableIPs | Should -Be 2

            $Network.AllIPs.count | Should -Be 2
            $Network.AllIPs[0] | Should -Be '10.1.1.0'
            $Network.AllIPs[-1] | Should -Be '10.1.1.1'
        }

        It 'Checks /31 Network Space Using Subnet Mask Notation ' {
            $Network = Get-IPNetwork -IPAddress 10.1.1.1 -SubnetMask 255.255.255.254 -ReturnAllIPs
            
            $Network.NetworkId | Should -Be '10.1.1.0'
            $Network.Broadcast | Should -Be '10.1.1.1'
            $Network.SubnetMask | Should -Be '255.255.255.254'
            $Network.SubnetLength | Should -Be 31
            $Network.WildcardMask | Should -Be '0.0.0.1'

            $Network.FirstIP | Should -Be '10.1.1.0'
            $Network.LastIP | Should -Be '10.1.1.1'

            $Network.TotalIPs | Should -Be 2
            $Network.UsableIPs | Should -Be 2

            $Network.AllIPs.count | Should -Be 2
            $Network.AllIPs[0] | Should -Be '10.1.1.0'
            $Network.AllIPs[-1] | Should -Be '10.1.1.1'
        }

        It 'Checks /32 Network Space Using CIDR Notation' {
            $Network = Get-IPNetwork -IPAddress 10.1.1.1 -SubnetLength 32 -ReturnAllIPs
            
            $Network.NetworkId | Should -Be '10.1.1.1'
            $Network.Broadcast | Should -Be '10.1.1.1'
            $Network.SubnetMask | Should -Be '255.255.255.255'
            $Network.SubnetLength | Should -Be 32
            $Network.WildcardMask | Should -Be '0.0.0.0'

            $Network.FirstIP | Should -Be '10.1.1.1'
            $Network.LastIP | Should -Be '10.1.1.1'

            $Network.TotalIPs | Should -Be 1
            $Network.UsableIPs | Should -Be 1

            $Network.AllIPs.count | Should -Be 1
            $Network.AllIPs[0] | Should -Be '10.1.1.1'
            $Network.AllIPs[-1] | Should -Be '10.1.1.1'
        }

        It 'Checks /32 Network Space Using Subnet Mask Notation ' {
            $Network = Get-IPNetwork -IPAddress 10.1.1.1 -SubnetMask 255.255.255.255 -ReturnAllIPs
            
            $Network.NetworkId | Should -Be '10.1.1.1'
            $Network.Broadcast | Should -Be '10.1.1.1'
            $Network.SubnetMask | Should -Be '255.255.255.255'
            $Network.SubnetLength | Should -Be 32
            $Network.WildcardMask | Should -Be '0.0.0.0'

            $Network.FirstIP | Should -Be '10.1.1.1'
            $Network.LastIP | Should -Be '10.1.1.1'

            $Network.TotalIPs | Should -Be 1
            $Network.UsableIPs | Should -Be 1

            $Network.AllIPs.count | Should -Be 1
            $Network.AllIPs[0] | Should -Be '10.1.1.1'
            $Network.AllIPs[-1] | Should -Be '10.1.1.1'
        }
    }
}
