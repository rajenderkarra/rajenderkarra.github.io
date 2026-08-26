param(
  [ValidateRange(1024, 65535)]
  [int]$Port = 8000
)

$siteDirectory = $PSScriptRoot
$server = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, $Port)
$contentTypes = @{
  '.css'  = 'text/css; charset=utf-8'
  '.html' = 'text/html; charset=utf-8'
  '.js'   = 'text/javascript; charset=utf-8'
  '.json' = 'application/json; charset=utf-8'
  '.svg'  = 'image/svg+xml'
  '.png'  = 'image/png'
  '.jpg'  = 'image/jpeg'
  '.jpeg' = 'image/jpeg'
  '.pdf'  = 'application/pdf'
}

$server.Start()
Write-Host "Serving $siteDirectory at http://localhost:$Port/"
Write-Host "Press Ctrl+C to stop the server."

try {
  while ($true) {
    $client = $server.AcceptTcpClient()
    try {
      $stream = $client.GetStream()
      $reader = [System.IO.StreamReader]::new($stream, [System.Text.Encoding]::ASCII, $false, 1024, $true)
      $requestLine = $reader.ReadLine()
      while ($reader.ReadLine()) { }

      $status = '200 OK'
      $requestPath = ''
      if ($requestLine -match '^GET\s+([^\s?]+)') {
        $requestPath = [Uri]::UnescapeDataString($matches[1].TrimStart('/'))
      } else {
        $status = '405 Method Not Allowed'
      }
      if ([string]::IsNullOrWhiteSpace($requestPath)) { $requestPath = 'index.html' }

      $candidatePath = [System.IO.Path]::GetFullPath((Join-Path $siteDirectory $requestPath))
      if ($status -eq '200 OK' -and
          ((-not $candidatePath.StartsWith($siteDirectory, [System.StringComparison]::OrdinalIgnoreCase)) -or
           -not (Test-Path -LiteralPath $candidatePath -PathType Leaf))) {
        $status = '404 Not Found'
      }

      $content = if ($status -eq '200 OK') { [System.IO.File]::ReadAllBytes($candidatePath) } else { [byte[]]@() }
      $extension = [System.IO.Path]::GetExtension($candidatePath).ToLowerInvariant()
      $contentType = $contentTypes[$extension]
      if (-not $contentType) { $contentType = 'application/octet-stream' }

      $header = "HTTP/1.1 $status`r`nContent-Type: $contentType`r`nContent-Length: $($content.Length)`r`nConnection: close`r`n`r`n"
      $headerBytes = [System.Text.Encoding]::ASCII.GetBytes($header)
      $stream.Write($headerBytes, 0, $headerBytes.Length)
      if ($content.Length) { $stream.Write($content, 0, $content.Length) }
    } finally {
      $client.Close()
    }
  }
} finally {
  $server.Stop()
}
