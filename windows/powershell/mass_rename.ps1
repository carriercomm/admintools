# os: windows
# version: 1.1
# purpose: renames files with particular extension using regular expressions, allows -whatif parameter for testing

$ext = $args[0];
$dir = $args[1];

$what = $args[2];
$with = $args[3];

$whatif = $args[4];

$count = 0;

if ($args.length -lt 4) {
    write-host "Invalid parameters" -fore red;
    ""
    write-host "   .\mass_rename.ps1 <ext> <dir> <what> <with> [-whatif]";
    ""
    write-host " Example (don't do any replacing, -whatif):";
    write-host "   .\mass_rename.ps1 .docx c:\Documents 'version 1\.1' 'version 1.2' -whatif";
    ""
    exit 1;
}

ls -recurse -path $dir | ?{ ($_.name.endswith($ext)) -and ($_.name -imatch $what) } | %{
    $to = ($_.name -ireplace $what,$with);
    $from = $_.fullname;

    if ($whatif -eq "-whatif") {
        write-host("whatif: '$from' -> '$to'");
    }
    else {
        mv -literalpath $from -destination ($_.directoryname + "\" + $to) -force;
        write-host "Renamed '$from' -> '$to'" -fore yellow;
        $count++;
    }
}

write-host "Done. Processed $count files." -fore green
