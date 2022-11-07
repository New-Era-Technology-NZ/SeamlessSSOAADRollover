<#

Automated Microsoft Deployment Toolkit Installer
Scripter: Rhys Jeffery
Email: Rhys.jeffery@neweratech.com
Date: 7/11/2022

Orginal:
https://www.shankuehn.io/post/automatically-roll-over-kerberos-decryption-key-with-aad-seamless-sign-on
https://github.com/sbkuehn/seamlessSsoAad/blob/main/schedRolloverKerbKeys.ps1
#>

$CloudUser = 'username@companyname.com'
$OnpremUser = 'DOMAIN\USERNAME'

# DO NOT EDIT BELOW

# Password Storage
$CloudEncrypted = Get-Content ".\SecureStorage\azureAd_Encrypted_Password.txt" | ConvertTo-SecureString
$OnpremEncrypted = Get-Content ".\SecureStorage\onPrem_Encrypted_Password.txt" | ConvertTo-SecureString

# Create objects for authencation
$CloudCred = New-Object System.Management.Automation.PsCredential($CloudUser,$CloudEncrypted)
$OnpremCred = New-Object System.Management.Automation.PsCredential($OnpremUser,$OnpremEncrypted)
 

# Authenticate against azure ad & update Azure AD SSO Forest
try{
    Import-Module 'C:\Program Files\Microsoft Azure Active Directory Connect\AzureADSSO.psd1'
    New-AzureADSSOAuthenticationContext -CloudCredentials $CloudCred
    Update-AzureADSSOForest -OnPremCredentials $OnpremCred
}catch(){


}
