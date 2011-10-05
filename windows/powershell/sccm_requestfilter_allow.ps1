# os: windows
# version: 1.0
# purpose:  loads IIS applicationHost.config xml file and enables all extensions in requestFiltering node
#           useful for SCCM distribution points

$user = "domain\user_to_map_with"
$pass = "password"
$drive = "X:"
$servers_file = "servers.txt"

gc $servers_file | %{
	echo "Connecting to $_...";

	$path = "\\$_\c`$\Windows\System32\inetsrv\config"

	$net = New-Object -ComObject Wscript.Network
	if (Test-path $drive) { $net.RemoveNetworkDrive($drive,$true) }
	$net.MapNetworkDrive($drive,$path,$false,$user,$pass)

	copy -literalpath "$drive\applicationHost.config" -destination "$drive\applicationHost.config.bak" -Force
	gc "$drive\applicationHost.config" | %{$_ -replace "(add fileExtension.*) allowed=`"false`"","$1 allowed=`"true`""} | Set-Content "$drive\applicationHost.config.tmp"
    mv -literalpath "$drive\applicationHost.config.tmp" -destination "$drive\applicationHost.config"

	$net.RemoveNetworkDrive($drive,$true)

	echo "$_ applicationHost.config file updated successfully (.bak file was created)"
	Read-Host "Press enter to continue..."

}
