# New Era Technology Custmonization - Seamless SSO Azure Active Directory

View Orginial Below:
<br>[Automatically Roll Over Kerberos Decryption Key with Azure Active Directory Seamless SSO](https://www.shankuehn.io/post/automatically-roll-over-kerberos-decryption-key-with-aad-seamless-sign-on)


## What does this do?
* Automates the rollover of Kerberos decyption keys for Azure AD Seamless SSO / Passthrough Authencation

## Features
* Simple to configure via XML
* Provides logging and email notifications on failure
* Securely stores used passwords 


## XML

* <CloudUsername> This is the username of the account which is used to connect to AzureAD
* <OnPremiseUsername> This is the username of the acount which is used to connect to the Forest
* <Server> This is the address of the SMTP server you wish to use, auth is not currently supported.
* <From> This is the email address you wish email notifications to come from
* <Email> This is the email address you wish to send email notifcations to, you can add / remove these but there minimum of 1 required
```
<?xml version = "1.0" encoding = "UTF-8" ?>

<AADKerberosRollover>
	<CloudUsername>example@example.school.nz</CloudUsername>
	<OnPremiseUsername>Example\ExampleUsername</OnPremiseUsername>
<SMTP>
	<Server>relay.n4l.co.nz</Server>
	<From>noreply@example.school.nz</From>
	<To>
		<Email>schoolalerts@newerait.co.nz</Email>
		<Email>ict@example.school.nz</Email>
	</To>
</SMTP>
</AADKerberosRollover>
```
