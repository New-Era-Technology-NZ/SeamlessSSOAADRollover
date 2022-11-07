<#

Automated AAD Kerberos decryption key Rollover
Date: 8/11/2022

Original:
https://www.shankuehn.io/post/automatically-roll-over-kerberos-decryption-key-with-aad-seamless-sign-on
https://github.com/sbkuehn/seamlessSsoAad/blob/main/schedRolloverKerbKeys.ps1
#>

[xml] $Settings = Get-Content -Path "$PSScriptRoot\config.xml" # Pull configuration from xml

$CloudUser = $Settings.AADKerberosRollover.CloudUsername.ToString()
$OnpremUser = $Settings.AADKerberosRollover.OnPremiseUsername.ToString()
[string[]]$UsersToEmail = $Settings.AADKerberosRollover.SMTP.To.Email
$MailFrom = $Settings.AADKerberosRollover.SMTP.From.ToString()
$SMTPServer = $Settings.AADKerberosRollover.SMTP.Server.ToString()

# Password Storage
$CloudEncrypted = Get-Content "$PSScriptRoot\SecureStorage\azureAd_Encrypted_Password.txt" | ConvertTo-SecureString
$OnpremEncrypted = Get-Content "$PSScriptRoot\SecureStorage\onPrem_Encrypted_Password.txt" | ConvertTo-SecureString

# Logging
$logPath = "$PSScriptRoot\Logs"
$LogFile = "$logPath\$(get-date -Format dd-MM-yy)-Error.log"
if(!(Test-Path $logPath)){New-Item -Path $logPath -ItemType Directory}

Function Log-ToFile {
    param($Message,$LogFile)

   $Message | Out-File -FilePath "$logFile" -Append
   Write-Host "" | Out-File -FilePath "$logFile" -Append
}

# Email Notification
Function Send-Mail{
    param($Server,$Log,$MailTo,$MailFrom)
    $Body = "AAD Kerberos decryption key Rollover has failed, please review the attached log file, which is also located on $Hostname $logFile"
    try{
        Send-MailMessage -From $MailFrom -To $MailTo -Subject 'Failed: AAD Kerberos decryption key Rollover' -SmtpServer $Server -Attachments $Log -Body $Body -Priority High
    }Catch{
        $Error = $_
        $StackTrace = $_.ScriptStackTrace
        $ErrorDetails = $_.ErrorDetails
        $Exception = $_.Exception

        Write-Host "Failed: Sending email Notification" | LogToFile -LogFile $LogFile
        Write-Host "See below for error, stacktrace, error details and exception" | LogToFile -LogFile $LogFile
        $Error | LogToFile -LogFile $LogFile
        $StackTrace | LogToFile -LogFile $LogFile
        $ErrorDetails | LogToFile -LogFile $LogFile
        $Exception | LogToFile -LogFile $LogFile
    }
}

# Create objects for authentication
try{
    $CloudCred = New-Object System.Management.Automation.PsCredential($CloudUser,$CloudEncrypted)
    $OnpremCred = New-Object System.Management.Automation.PsCredential($OnpremUser,$OnpremEncrypted)
}catch{
    $Error = $_
    $StackTrace = $_.ScriptStackTrace
    $ErrorDetails = $_.ErrorDetails
    $Exception = $_.Exception

    Write-Host "Failed: Sending email Notification" | LogToFile -LogFile $LogFile
    Write-Host "See below for error, stacktrace, error details and exception" | LogToFile -LogFile $LogFile
    $Error | LogToFile -LogFile $LogFile
    $StackTrace | LogToFile -LogFile $LogFile
    $ErrorDetails | LogToFile -LogFile $LogFile
    $Exception | LogToFile -LogFile $LogFile

}

 

# Checks CloudCred and OnpremCred are not null, break out of script if so
if($CloudCred = $Null -or $OnpremCred -eq $Null){

    Write-Host "Failed: Missing Credentials" | LogToFile -LogFile $LogFile
    
    ForEach($User in $UsersToEmail){
        Send-Mail -Server $SMTPServer -Log $LogFile -MailTo $User -MailFrom $MailFrom
    }
    Break # Force Exit the script
}

# Authenticate against azure ad & update Azure AD SSO Forest
try{
    Import-Module 'C:\Program Files\Microsoft Azure Active Directory Connect\AzureADSSO.psd1'
    New-AzureADSSOAuthenticationContext -CloudCredentials $CloudCred
    Update-AzureADSSOForest -OnPremCredentials $OnpremCred -PreserveCustomPermissionsOnDesktopSsoAccount
}catch{

    $Error = $_
    $StackTrace = $_.ScriptStackTrace
    $ErrorDetails = $_.ErrorDetails
    $Exception = $_.Exception

    Write-Host "Failed: AAD Kerberos decryption key Rollover" | LogToFile -LogFile $LogFile
    Write-Host "See below for error, stacktrace, error details and exception" | LogToFile -LogFile $LogFile
    $Error | LogToFile -LogFile $LogFile
    $StackTrace | LogToFile -LogFile $LogFile
    $ErrorDetails | LogToFile -LogFile $LogFile
    $Exception | LogToFile -LogFile $LogFile
    
    ForEach($User in $UsersToEmail){
        Send-Mail -Server $SMTPServer -Log $LogFile -MailTo $User -MailFrom $MailFrom
    }
}
 