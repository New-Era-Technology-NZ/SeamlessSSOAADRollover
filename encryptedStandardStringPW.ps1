<#

Automated AAD Kerberos decryption key Rollover
Date: 8/11/2022

Original:
https://www.shankuehn.io/post/automatically-roll-over-kerberos-decryption-key-with-aad-seamless-sign-on
https://github.com/sbkuehn/seamlessSsoAad/blob/main/encryptedStandardStringPW.ps1
#>

[xml] $Settings = Get-Content -Path "$PSScriptRoot\config.xml" # Pull configuration from xml

$CloudUser = $Settings.AADKerberosRollover.CloudUsername.ToString()
$OnpremUser = $Settings.AADKerberosRollover.OnPremiseUsername.ToString()

$onPremCredential = Get-Credential -UserName $OnpremUser -Message "Please enter in your username & password for your on premise user"
$onPremCredential.Password | ConvertFrom-SecureString | Set-Content "$PSScriptRoot\SecureStorage\onPrem_Encrypted_Password.txt"

$azureAdCredential = Get-Credential -UserName $CloudUser -Message "Please enter in your username & password for your on cloud user"
$azureAdCredential.Password | ConvertFrom-SecureString | Set-Content "$PSScriptRoot\SecureStorage\azureAd_Encrypted_Password.txt"
