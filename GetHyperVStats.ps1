function Get-ComputerStats {
   param(
     [Parameter(Mandatory=$true, Position=0,
                ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
     [ValidateNotNull()]
     [string[]]$ComputerName
   )

   Write-Output "The script is starting..."
     foreach ($c in $ComputerName) {
         $avg = Get-WmiObject win32_processor -computername $c |
                    Measure-Object -property LoadPercentage -Average |
                    Foreach {$_.Average}
         $mem = Get-WmiObject win32_operatingsystem -ComputerName $c |
                    Foreach {"{0:N2}" -f ((($_.TotalVisibleMemorySize - $_.FreePhysicalMemory)*100)/ $_.TotalVisibleMemorySize)}
         $freeC = Get-WmiObject Win32_Volume -ComputerName $c -Filter "DriveLetter = 'C:'" |
                     Foreach {"{0:N2}" -f (($_.FreeSpace / $_.Capacity)*100)}
	 $freeH = Get-WmiObject Win32_Volume -ComputerName $c -Filter "DriveLetter = 'H:'" |
                     Foreach {"{0:N2}" -f (($_.FreeSpace / $_.Capacity)*100)}
          [pscustomobject] [ordered] @{
             ComputerName = $c
             AverageCpu = $avg
             MemoryUsage = $mem
	     PercentFreeOnH = $freeH
             PercentFreeOnC = $freeC
         }
     }

}

Get-ComputerStats -ComputerName FLOAPP-HPV01 | FT