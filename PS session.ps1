# the command ps session is already secured by default (even on http 5985)
# but you can still encrypt passwork with the PS command below
# done 08 08 2019 for GIT & GITHUB testing

$SecurePassword = ConvertTo-SecureString -String "azerty" -AsPlainText -Force
$TechnicalUser = "contoso\soandso"


###########Test remote task
$Credentials = New-Object System.Management.Automation.PSCredential ($TechnicalUser,$SecurePassword)

try{$session = New-PSSession -ComputerName "soandsoSRV" -Credential $Credentials}
catch{write-warning "Connexion FAILED, please check logs; The script will either stop or go to next step, wait for task to be finished before continuing!!"
      write-host 
      Return}

Invoke-Command -Session $session -ScriptBlock {

$d = get-date -Format ddMMyyyy_HH:mm:ss
write-host "$d launching task on "soandsoSRV"" 
schtasks /run /tn "\Microsoft\TEST"
$start = (Get-Date) 
$task = (Get-ScheduledTask -TaskName 'TEST').State       
$pause = 0
$pause += 1
while ($task -eq "Running"){      
    #looping until end    
    $pause += 1
    #information periodically
    if($pause -match 0 -and $pause -gt 10 -and $pause % 20)
    {write-warning "task is still running, more than $pause seconds passed"}
    else{}
    #refreshing status
    $task = (Get-ScheduledTask -TaskName 'TEST').State
    #about 1sec lost to check status
    }
    $end = (Get-Date)
    $duration = ($end-$start).totalseconds
    write-host "Duration was précisely $duration seconds!"
}
 Remove-PSSession -Session $session
 $d = get-date -Format ddMMyyyy_HH:mm:ss
 write-host "$d task is finished!"
