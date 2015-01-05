function Check-Port-Status {
    Param(
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true, HelpMessage="A servername or IP address must be specified")]
        [string]$srv,
        [Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true, HelpMessage="A port number must be specified")]
        [string]$port,
        [Parameter(Position=2)]
        [string]$timeout=1000
    )
 
    $ErrorActionPreference = "SilentlyContinue"
    $tcpclient = New-Object system.Net.Sockets.TcpClient
    $iar = $tcpclient.BeginConnect($srv, $port, $null, $null)
    $wait = $iar.AsyncWaitHandle.WaitOne($timeout, $false)
    
    if (!$wait) {
        $tcpclient.Close()
        Write-Host "Connection Timeout" -ForegroundColor DarkYellow
        $failed = $true
    } else {
        $Error.Clear()
        $tcpclient.EndConnect($iar) | Out-Null
        if ($Error[0]) {
            Write-Host $Error[0] -ForegroundColor DarkYellow
            $failed = $true
        }
        $tcpclient.Close()
    }
 
    if ($failed) {Write-Host "TCP Port $port on server $srv is closed!" -ForegroundColor DarkRed} else {Write-Host "TCP Port $port on server $srv is open!" -ForegroundColor DarkGreen}
}

