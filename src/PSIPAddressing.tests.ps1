. "$PSScriptRoot\PSIPAddressing.ps1"

Describe 'Unit Tests' {
    Context 'Logic Validation' {

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

    }
}
