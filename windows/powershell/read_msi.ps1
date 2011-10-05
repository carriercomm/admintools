# os: windows
# version: 1.0
# purpose:  loads an MSI and displays all entries in a particular table

$ErrorActionPreference = "Continue";

function get-msiproperties {
	param(
		[Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="MSI Database Filename",ValueFromPipeline=$true)]
		[Alias("Filename","Path","Database")]
		$msi,
		[Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="MSI Table",ValueFromPipeline=$false)]
		[Alias("Table","MsiTable","Select")]
		$msi_table
	)

	# A quick check to see if the file exist
	if(!(Test-Path $msi)) {
		throw "Could not find " + $msi
	}
	# Create an empty hashtable to store properties in
	$td = @{}
	# Creating WI object and load MSI database
	$wio = New-Object -com WindowsInstaller.Installer

	$widb = $wio.InvokeMethod("OpenDatabase", (Resolve-Path $msi).Path, 0)


	# Open the Property-view
	$view = $widb.InvokeMethod("OpenView", "SELECT * FROM $msi_table")
	$view.InvokeMethod("Execute")
	# Loop thru the table
	$row = $view.InvokeMethod("Fetch")
	while($row -ne $null) {
		#$row.gettype()|fc -dep 10;exit
		$td[$row.InvokeParamProperty("StringData",1)] = @();
		# Add property and value to hash table
		for ($x = 2; $x -lt 10;$x++) {
			if (!$row.InvokeParamProperty("StringData",$x)) { $_tmp_data = $null }
			else { $_tmp_data = $row.InvokeParamProperty("StringData",$x) }
			$td[$row.InvokeParamProperty("StringData",1)] += @($_tmp_data)
		}
		# Fetch the next row
		$row = $view.InvokeMethod("Fetch")
	}
	$view.InvokeMethod("Close")
	# Return the hash table
	return $td
}

if ($args.length -lt 2) {
    write-host "Usage: .\read_msi.ps1 <file.msi> <table>";
    ""
    exit 1;
}

 $args[0] | get-msiproperties -table $args[1]
