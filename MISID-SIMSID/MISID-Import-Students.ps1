# This script sets an Active Directory attribute to the Capita SIMS 'User ID' field value for users 
# that have been provisioned with the Capita Active Directory Provisioning Service
# It requires a SIMS XML report with values for 'ID' and 'External ID' for all users to parse and match users
# Giles Davis - 30/11/2015

# STUDENT VERSION

Import-Module ActiveDirectory

$SearchLDAPBase="OU=SOME,OU=BASE,DC=LDAP,DC=PATH" # Base LDAP path
$ADAttribute="hwcsSimsId" # The custom AD atrribute we want to set
$SIMSReportPath="D:\MISID-SIMSID\SIMS ID To External ID.xml" # Path to SIMS XML
$ErrorLogPath="D:\MISID-SIMSID\error.log" # Error log to output to

$matchedcount=0
$unmatchedcount=0
$cantmatchcount=0
$totalcount=0
$alreadymatchedcount=0
$now = Get-Date

"Script Started: " + $now | Out-File $ErrorLogPath 

[xml]$SIMSReport = Get-Content $SimsReportPath

$accountlist = (Get-ADUser -SearchBase $SearchLDAPBase -Properties displayName,capitachildrensservicesClientEntityGuids,$ADAttribute -Filter *)

if ($accountlist -ne $null)
{
	forEach ($account in $accountlist)
	{
		$totalcount++
		if ($account.capitachildrensservicesClientEntityGuids -ne $null -and $account.$ADAttribute -eq $null)
		{
			$accountExternalID=$account.capitachildrensservicesClientEntityGuids.Split("|")
			$xmlposition=[array]::indexof($simsreport.superstarreport.record.external_x0020_id,$accountExternalID[1])
			if ($xmlposition -ge 0)
			{
				write-host $account.samaccountname [ $account.displayName ] Matched - SIMS ID is $simsreport.superstarreport.record.ID[$xmlposition]
				"INFO: " + $account.samaccountname + " [ " + $account.displayName + " ] Matched to SIMS ID " + $simsreport.superstarreport.record.ID[$xmlposition] | Out-File $ErrorLogPath -append 
				Set-AdUser -Identity $account -replace @{$ADAttribute=$simsreport.superstarreport.record.ID[$xmlposition]}
				$matchedcount++
			}
			else
			{
				write-host $account.samaccountname [ $account.displayName ] No XML Match
				"ERROR: " + $account.samaccountname + " [ " + $account.displayName + " ] No XML Match" | Out-File $ErrorLogPath -append
				$unmatchedcount++
			}
		}
		else
		{
			if ($account.$ADAttribute -eq $null)
			{
				#write-host $account.samaccountname [ $account.displayName ] No Capita GUID [ Account not touched by ADPS? ]
				"ERROR: " + $account.samaccountname + " [ " + $account.displayName + " ] No Capita GUID [ Account not touched by ADPS? ]" | Out-File $ErrorLogPath -append
				$cantmatchcount++
			}
			else
			{
				$alreadymatchedcount++
			}
		}
	}
}
write-host Matched Accounts: $matchedcount
"Matched Accounts: " + $matchedcount | Out-File $ErrorLogPath -append
write-host Unmatched Accounts: $unmatchedcount
"Unmatched Accounts: " + $unmatchedcount | Out-File $ErrorLogPath -append
write-host Already Matched Accounts: $alreadymatchedcount
"Already Matched Accounts: " + $alreadymatchedcount | Out-File $ErrorLogPath -append
write-host Impossible to match Accounts: $cantmatchcount
"Imposible to Match Accounts: " + $cantmatchcount | Out-File $ErrorLogPath -append
write-host Total Accounts: $totalcount
"Total Accounts: " + $totalcount | Out-File $ErrorLogPath -append