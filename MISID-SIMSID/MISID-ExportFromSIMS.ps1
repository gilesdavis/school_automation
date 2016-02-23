# This script runs the Capita SIMS CommandReporter to run a report of SIMS ID number to External ID Number for various people
# The resulting XML is called later by the MISID-Import script to assign MIS IDs to Active Directory users
# Giles Davis - 30/11/2015

$SIMSReporter="C:\Program Files (x86)\SIMS\SIMS .net\CommandReporter.exe" # Path to the SIMS command reporter
$SIMSReport="SIMS ID To External ID","SIMS ID to External ID - Staff","SIMS ID To External ID - Contacts" # List of the SIMS Reports to run
$SIMSReportBasePath="D:\MISID-SIMSID\" # Base path to output the resulting XML to

foreach ($report in $SIMSReport)
{
	& "$SIMSReporter" /TRUSTED /REPORT:$report /OUTPUT:$SIMSReportBasePath\$report.xml
}

