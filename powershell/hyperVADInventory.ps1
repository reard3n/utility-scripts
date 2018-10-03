# 2018-10-02 // David Gibbons // david.c.gibbons@gmail.com
# this script will grab the virtual machine details from each hyper-v server matching the given name pattern
# it will then output the data about each VM and the server it resides on to a .csv file

# create an array to store our output so that we can consolidate all servers into one CSV
$vms = @()
$hvservers = @()


# this command will ask AD which machines have the hyper-v role installed so we do not have to do kludge-y filtering by name
# add all of the hyper-v servers in this domain to an array so we can process them and ask them which vms they are hosting
Get-ADObject -Filter 'ObjectClass -eq "serviceConnectionPoint" -and Name -eq "Microsoft Hyper-V"' | foreach-object {
	$bits = $_.DistinguishedName.Split(",");
	$namebits = $bits[1].split("=");
	$hvservers += $namebits[1];
}

# iterate over the servers we found in the previous command
Foreach($server in $hvservers){
	$currentVMs = Get-Vm -ComputerName $server | Select-Object Name,State,MemoryAssigned
	Foreach($vm in $currentVMs){
		# add the Server column so we know which host this VM is on
		$vm | Add-Member "Server" "$server"
	}

	# push this info onto the master stack
	$vms+=$currentVMs
}

# dump the information into a csv so that we can massage it in excel
echo $vms | export-csv c:\Scripts\inventory.csv
