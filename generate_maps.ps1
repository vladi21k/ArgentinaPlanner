# Generate static map PNG from OpenStreetMap tiles
Set-Location "c:\Users\Vladi\Dev\ArgentinaPlanner"
Add-Type -AssemblyName System.Drawing

function Get-TileCoords($lat, $lon, $zoom) {
    $n = [Math]::Pow(2, $zoom)
    $xf = ($lon + 180) / 360 * $n
    $yf = (1 - [Math]::Log([Math]::Tan($lat * [Math]::PI / 180) + 1 / [Math]::Cos($lat * [Math]::PI / 180)) / [Math]::PI) / 2 * $n
    return @{ X=$xf; Y=$yf; TileX=[int][Math]::Floor($xf); TileY=[int][Math]::Floor($yf); PixX=($xf % 1)*256; PixY=($yf % 1)*256 }
}

function New-StaticMap($lat, $lon, $zoom, $width, $height, $markers, $outFile) {
    $center = Get-TileCoords $lat $lon $zoom
    $halfW = $width / 2; $halfH = $height / 2
    $tilesWide = [int][Math]::Ceiling($width / 256) + 2
    $tilesHigh = [int][Math]::Ceiling($height / 256) + 2
    $startTileX = $center.TileX - [int][Math]::Floor($tilesWide / 2)
    $startTileY = $center.TileY - [int][Math]::Floor($tilesHigh / 2)
    $bmp = New-Object System.Drawing.Bitmap($width, $height)
    $g   = [System.Drawing.Graphics]::FromImage($bmp)
    $g.Clear([System.Drawing.Color]::LightGray)
    $wc = New-Object System.Net.WebClient
    $wc.Headers.Add("User-Agent", "Mozilla/5.0 (compatible; ArgentinaPlanner/1.0)")
    for ($ty = 0; $ty -lt $tilesHigh; $ty++) {
        for ($tx = 0; $tx -lt $tilesWide; $tx++) {
            $curX = $startTileX + $tx; $curY = $startTileY + $ty
            # ESRI World Street Map uses z/y/x order
            $url = "https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/$zoom/$curY/$curX"
            try {
                $data = $wc.DownloadData($url)
                $stream = New-Object System.IO.MemoryStream(,$data)
                $tile = [System.Drawing.Bitmap]::FromStream($stream)
                $destX = [int]($tx * 256 - $center.PixX - ([Math]::Floor($tilesWide/2)) * 256 + $halfW)
                $destY = [int]($ty * 256 - $center.PixY - ([Math]::Floor($tilesHigh/2)) * 256 + $halfH)
                $g.DrawImage($tile, $destX, $destY, 256, 256); $tile.Dispose(); $stream.Dispose()
            } catch { Write-Host "  tile $curX/$curY failed" }
            Start-Sleep -Milliseconds 120
        }
    }
    $pinBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(220,0,0))
    $pinPen   = New-Object System.Drawing.Pen([System.Drawing.Color]::White, 2)
    foreach ($m in $markers) {
        $mc = Get-TileCoords $m[0] $m[1] $zoom
        $px = [int](($mc.X - $startTileX) * 256 - $center.PixX - ([Math]::Floor($tilesWide/2)) * 256 + $halfW)
        $py = [int](($mc.Y - $startTileY) * 256 - $center.PixY - ([Math]::Floor($tilesHigh/2)) * 256 + $halfH)
        $g.FillEllipse($pinBrush, $px-9, $py-9, 18, 18); $g.DrawEllipse($pinPen, $px-9, $py-9, 18, 18)
    }
    $font    = New-Object System.Drawing.Font("Arial", 9)
    $brush   = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(180, 0, 0, 0))
    $bgBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(170, 255, 255, 255))
    $attrib  = "Esri, HERE, Garmin, (c) OpenStreetMap contributors"
    $tsz     = $g.MeasureString($attrib, $font)
    $g.FillRectangle($bgBrush, $width - $tsz.Width - 8, $height - $tsz.Height - 6, $tsz.Width + 6, $tsz.Height + 4)
    $g.DrawString($attrib, $font, $brush, $width - $tsz.Width - 6, $height - $tsz.Height - 4)
    $g.Dispose(); $bmp.Save($outFile, [System.Drawing.Imaging.ImageFormat]::Png); $bmp.Dispose()
    Write-Host "Done: $([System.IO.Path]::GetFileName($outFile))"
}

$md = ".\assets\images\maps"
New-Item -ItemType Directory -Force -Path $md | Out-Null
Write-Host "Generating maps..."

New-StaticMap (-37.0) (-65.0) 3 800 500 @(@(-34.6037,-58.3816),@(-25.5996,-54.5795),@(-42.7714,-65.0264),@(-54.8019,-68.3030),@(-50.3388,-72.2688),@(-49.3310,-72.8855),@(-41.1335,-71.3103),@(-32.8908,-68.8272)) "$md\map_overview.png"
New-StaticMap (-34.6037) (-58.3816) 12 800 400 @(@(-34.6037,-58.3816)) "$md\map_buenos_aires.png"
New-StaticMap (-25.69) (-54.44) 11 800 400 @(@(-25.5996,-54.5795),@(-25.6953,-54.4367)) "$md\map_iguazu.png"
New-StaticMap (-42.4) (-64.0) 8 800 400 @(@(-42.7714,-65.0264),@(-42.5196,-64.2328),@(-44.0219,-65.4347)) "$md\map_peninsula_valdes.png"
New-StaticMap (-54.75) (-68.35) 10 800 400 @(@(-54.8019,-68.3030)) "$md\map_ushuaia.png"
New-StaticMap (-50.34) (-72.6) 10 800 400 @(@(-50.3388,-72.2688),@(-50.4934,-73.0479)) "$md\map_el_calafate.png"
New-StaticMap (-49.33) (-72.89) 11 800 400 @(@(-49.3310,-72.8855),@(-49.2761,-72.9625)) "$md\map_el_chalten.png"
New-StaticMap (-41.13) (-71.31) 10 800 400 @(@(-41.1335,-71.3103)) "$md\map_bariloche.png"
New-StaticMap (-33.0) (-68.85) 9 800 400 @(@(-32.8908,-68.8272),@(-33.0478,-68.8917),@(-33.5292,-69.0614)) "$md\map_mendoza.png"

Write-Host "Done."
Get-ChildItem $md | Select-Object Name, @{N='KB';E={[math]::Round($_.Length/1KB,0)}}