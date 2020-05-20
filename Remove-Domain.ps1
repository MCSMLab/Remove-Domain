<#
.SYNOPSIS
This script removes a single email domian (domain.com) for all mailboxes in an Office 365 tenant.

.DESCRIPTION
Domain is a required parameter

.PARAMETER Domain
Required paramter. Domain to be removed from all mailboxes in tenant.

.NOTES
1.0 - 

Remove-Domain.ps1
v1.0
5/20/2020
By Nathan O'Bryan, MVP|MCSM
nathan@mcsmlab.com

.EXAMPLE
Remove-Domain -Domain domain.com

.LINK
https://www.mcsmlab.com/about
https://github.com/MCSMLab/
#>

#Command line parameter
[cmdletbinding()]
Param (
    [Parameter(Mandatory=$True)][String]$Domain
    )

Clear-Host

If ($exscripts)
{
    Write-Host 'Exchange Management Shell loaded'
}

Else
{   
    Write-Host 'Connecting to Exchange Online PowerShell'
    $UserCredential = Get-Credential
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
    Import-PSSession $Session -DisableNameChecking
}

$RemoveSMTPDomain = "smtp:*@$Domain"
 
$AllMailboxes = Get-Mailbox -ResultSize Unlimited | Where-Object {$_.EmailAddresses -clike $RemoveSMTPDomain}
 
ForEach ($Mailbox in $AllMailboxes)
{ 
   $i = $i+1
   Write-Progress -Activity "Removing $Domain from all mailboxes" -Status "For $Mailbox" -PercentComplete ($i/$AllMailboxes.count*100)
   $AllEmailAddress  = $Mailbox.EmailAddresses -cnotlike $RemoveSMTPDomain
   $RemovedEmailAddress = $Mailbox.EmailAddresses -clike $RemoveDomainsmtp
   $MailboxID = $Mailbox.PrimarySmtpAddress 
   $MailboxID | Set-Mailbox -EmailAddresses $AllEmailAddress #-whatif
 
   Write-Host "The follwoing E-mail address where removed $RemovedEmailAddress from $MailboxID Mailbox "
}

Write-Host "Done! Removing connection to Exchange Online"
Remove-PSSession $Session
