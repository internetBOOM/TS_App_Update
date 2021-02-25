## The below function and code is only an exmaple of utilization, and is presented only to offer a suggested direction.#
## The logic of this function assumes that you standardize the name of your application steps. ##
## This script will not function as is unless you are connected to the CMPshProvider. For ease of access, copy your sites connection from the ISE window below ##

## Logging ##
$log = "TS_3rd_Party_Update"
$date = (Get-Date -Format MM-dd-yyyy)
$file = "$log" + "$date" + ".log"
function Write-Log {
    Param([string]$Data)
     $d = (Get-Date -Format MM-dd-yyyy-HH:mm)
     Write-Output "$($d): $Data"
}

## COPY SITE CONFIGURATION HERE OR COPY SCRIPT DIRECTLY INTO ALREADY CONNECTED Psh WINDOW ##

## Your default logging path could be anywhere, and could be stored in a variable is desired. For simplicity, this is stored in a Logs collection folder here that exists on my test devices. ##
Start-Transcript -Path "C:\Logs\$file" -Append -Force

## Set the TaskSequenceID to a variable, or a read Host call like this for variability ##
$ts = Read-Host -Prompt "Task Sequence Package ID"
$tsname = ((Get-CMTSStepInstallApplication -TaskSequenceId $ts).Name)

function Update-App {
    Param(
        [Parameter(Mandatory=$true)][String]$appName,
        [Parameter(Mandatory=$true)][String]$stepName
        )
            try{
                $tsStep = $tsname | select-string -pattern "$stepName"
                $finalName = (Get-CMTSStepInstallApplication -TaskSequenceId $ts -StepName "$tsStep").ApplicationName
                $appModel = (Get-CMApplication -Name "$appFinal").ModelName
                if ($finalName -eq $appModel){
                    Write-Log "$appFinal is the current application in the $tsStep step..."
                }else{
                    Write-Log "$appFinal is not the current step application. Updating..."
                    $readApp = Get-CMApplication -Name $appFinal
                    Write-Log "Updating $tsStep step..."
                    Set-CMTSStepInstallApplication -Application $readApp -TaskSequenceId $ts -StepName $tsStep -Verbose
                    $finalName = (Get-CMTSStepInstallApplication -TaskSequenceId $ts -StepName "$tsStep").ApplicationName
                    if ($finalName -eq $appModel){
                        Write-Log "$tsStep Update complete!"
                    }else{
                        throw
                    }
                }
            }catch{
                Write-Log "Error updating step $tsStep to $finalName"
                Stop-Transcript
                Exit 1
            }
}

## This is an example call of this function. This method insinuates that you've already ingested your application data stored in XAML/CSV/TXT and are itterating over it. ##
Write-Log "Beginning Adobe Reader DC evaluation..."
$eval = $final | select-string -pattern "Reader DC"
if ($eval -eq $null){
    Write-Log "Reader DC application not updated this month..."
}else{
    Update-App -AppName "Reader DC" -StepName "Reader DC"
}

Stop-Transcript
