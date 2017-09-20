function Get-ComputerStats {
   param(
     [Parameter(Mandatory=$true, Position=0,
                ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
     [ValidateNotNull()]
     [string[]]$ComputerName
   )

$creds = Get-AutomationPSCredential -Name 'OnPrem Admin Account'

   Write-Output "The script is starting..."
     foreach ($c in $ComputerName) {
         $avg = Get-WmiObject win32_processor -computername $c -Credential $creds |
                    Measure-Object -property LoadPercentage -Average |
                    Foreach {$_.Average}
         $mem = Get-WmiObject win32_operatingsystem -ComputerName $c -Credential $creds |
                    Foreach {"{0:N2}" -f ((($_.TotalVisibleMemorySize - $_.FreePhysicalMemory)*100)/ $_.TotalVisibleMemorySize)}
         $freeC = Get-WmiObject Win32_Volume -ComputerName $c -Filter "DriveLetter = 'C:'" -Credential $creds |
                     Foreach {"{0:N2}" -f (($_.FreeSpace / $_.Capacity)*100)}
	 $freeH = Get-WmiObject Win32_Volume -ComputerName $c -Filter "DriveLetter = 'H:'" -Credential $creds |
                     Foreach {"{0:N2}" -f (($_.FreeSpace / $_.Capacity)*100)}
          [pscustomobject] [ordered] @{
             ComputerName = $c
             AverageCpu = $avg
             MemoryUsage = $mem
	     PercentFreeOnH = $freeH
             PercentFreeOnC = $freeC
         }
     }

     Write-Output "The script is finished..."

}

$hpvHost = Get-AutomationVariable -Name 'HyperV-Hosts'
Get-ComputerStats -ComputerName FLOAPP-HPV01 | FT