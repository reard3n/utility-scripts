# 2018-10-02 // David Gibbons // david.c.gibbons@gmail.com
# this script will grab the virtual machine details from each hyper-v server matching the given name pattern
# it will then output the data about each VM and the server it resides on to a .csv file

# create an array to store our output so that we can consolidate all servers into one CSV
$vms = @()

# in this example we are filtering for computers called “HYPERV” and then filtering out the virtual name of a failover cluster
Get-ADComputer -Filter {Name -like “HYPERV*” -and Name -notlike “HYPERVCLUST*” } | Foreach-Object {
	$server = $_.Name
	$currentVMs = Get-Vm -ComputerName $server | Select-Object Name,State,MemoryAssigned
	Foreach($vm in $currentVMs){
		# add the Server column so we know which host this VM is on
		$vm | Add-Member "Server" "$server"
	}

	# push this info onto the master stack
	$vms+=$currentVMs
}

echo $vms | export-csv c:\Scripts\inventory.csv
