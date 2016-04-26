Function Global:Get-UpTime {
<#
.NOTES
    Author: Robert D. Biddle (email: robertdbiddle+powershell@gmail.com )
.SYNOPSIS
    PowerShell function to calculate computer uptime
.DESCRIPTION
    PowerShell function to calculate computer uptime for either the localhost or remote computers.  
    Multiple Remote computers can be entered as a list of strings, and pipeline input is supported.
.EXAMPLE 
    Get-UpTime 
        - This example writes the local computer uptime to the console
    
    Get-Uptime -OutputDateTimeObject
        - This example outputs the local computer uptime as a DateTime object

    Get-Uptime -ComputerName abc.xyz.com
        - This example writes the uptime for computer abc.xyz.com to the console.  You will be prompted for credentials.

    Get-Uptime -ComputerName "computer1","computer2" -Credential $cred
        - This example writes the uptime for computer abc.xyz.com to the console and supplies credentials in the form of a PSCredential object stored in variable $cred
    
    "computer1","computer2" | Get-Uptime -Credential $cred
        - This example passes a list of computers into Get-Uptime via the pipeline and supplies credentials in the form of a PSCredential object stored in variable $cred

#>
    [CmdletBinding(DefaultParameterSetName="localhost")]
    Param(
        [OutputType([DateTime])]
        [switch]$OutputDateTimeObject,

        [parameter(ParameterSetName="remote",Mandatory=$False,Position=0,ValueFromPipeline=$True)]
        [string[]]$ComputerName,

        [parameter(ParameterSetName="remote",Mandatory=$False,Position=1)]
        [PSCredential]
        $Credential
        )
    Begin 
    {

    }
    Process 
    {       
        switch ($psCmdlet.ParameterSetName)
        {
        "localhost"
            {
                $ComputerName = $env:COMPUTERNAME
                $ComputerData = Get-WmiObject -Class Win32_OperatingSystem -Computer $ComputerName
                $Uptime = New-TimeSpan -Start $ComputerData.ConvertToDateTime($ComputerData.LastBootUpTime) -End (Get-Date)
                if($OutputDateTimeObject){Write-Output $Uptime}
                Else{Write-Host "Uptime for $ComputerName is: $($Uptime.days) days $($Uptime.hours) hours $($Uptime.minutes) minutes $($Uptime.seconds) seconds"}
            }
        "remote"
            {
                foreach($c in $ComputerName)
                # Foreach is not necessary for pipeline input because the Process block does this implicitly, e.g. "computer1","computer2" | Get-Uptime -Credential $cred
                # However it is neeeded to support passing an array directly into the -ComputerName parameter, e.g.  Get-Uptime -ComputerName "computer1","computer2"
                {
                    $ComputerData = Get-WmiObject -Class Win32_OperatingSystem -Computer $c -Credential $Credential
                    $Uptime = New-TimeSpan -Start $ComputerData.ConvertToDateTime($ComputerData.LastBootUpTime) -End (Get-Date)
                    if($OutputDateTimeObject){Write-Output $Uptime}
                    Else{Write-Host "Uptime for $c is: $($Uptime.days) days $($Uptime.hours) hours $($Uptime.minutes) minutes $($Uptime.seconds) seconds"}   
                }
            }
        }
    }
    End
    {     
    }
}
