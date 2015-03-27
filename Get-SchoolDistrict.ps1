<#
	.DESCRIPTION
	The Get-SchoolDistrict function returns, as a string, the name of the school district in which the supplied address resides.  The function leverages the Census.gov Geocoding API documented here:  http://geocoding.geo.census.gov/geocoder/Geocoding_Services_API.pdf
	
	.PARAMETER Address
	The street address for which to return the name of a school district
	
	.PARAMETER City
	The city of the given street address
	
	.PARAMETER State
	The city of the given city.  If no state is supplied, PA will be used.
	
	.EXAMPLE
	Get the school district of the Benjamin Franklin House
	Get-SchoolDistrict -Address "834 Chestnut St" -City "Philadelphia"
	
	.EXAMPLE 
	Get the School District of The Empire State Building
	Get-SchoolDistrict -Address "350 5th Ave" -City "New York" -State "NY" 
	
	.EXAMPLE 
	Get the School District of an address from the pipeline
	"233 S Wacker Dr, Chicago, IL" | .\Get-SchoolDistrict
	
	.EXAMPLE
	Get the School District from a one-line address
	Get-SchoolDistrict "1401 John F Kennedy Blvd, Philadelphia, PA"
	
	.NOTES
	Written by Charles Crossan.



#>
[CmdletBinding()]
Param(
[Parameter(ValueFromPipeline=$true,Mandatory=$True,Position=1)]
[String]$Address,
[Parameter(Mandatory=$False,Position=2)]
[String]$City,
[Parameter(Mandatory=$False,Position=3)]
[String]$State
)
if (($City -eq "") -or ($State -eq ""))
{
	#Write-Host "Parsing one line address"
	$URI = "http://geocoding.geo.census.gov/geocoder/locations/onelineaddress?address=$Address&benchmark=Public_AR_Current&vintage=ACS2014_Current&format=json"
	$result = Invoke-RESTMethod $URI
	$Address = $($result.result.addressMatches.matchedaddress -split ",")[0]
	$City = $result.result.addressMatches.addresscomponents.City
	$STATE = $result.result.addressMatches.addresscomponents.State
}
$URI = "http://geocoding.geo.census.gov/geocoder/geographies/address?street=$Address&city=$City&state=$State&benchmark=Public_AR_Current&vintage=ACS2014_Current&layers=Unified School Districts&format=json"

#Write-host $URI
$result = Invoke-RESTMethod $URI
return $result.result.addressMatches[0].geographies.'Unified School Districts'.name