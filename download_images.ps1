Set-Location "c:\Users\Vladi\Dev\ArgentinaPlanner"
$base = ".\assets\images"
$logFile = ".\download_log.txt"
$errors = @()

# 960px is a valid Wikimedia thumbnail step — no rate limit issues
function Get-WikiThumbUrl($filename, $width=960) {
    $norm = $filename.Replace(' ', '_')
    $md5 = [System.Security.Cryptography.MD5]::Create()
    $hash = [System.BitConverter]::ToString($md5.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($norm))).Replace('-','').ToLower()
    $a  = $hash.Substring(0,1)
    $ab = $hash.Substring(0,2)
    $enc = [System.Uri]::EscapeDataString($norm)
    return "https://upload.wikimedia.org/wikipedia/commons/thumb/$a/$ab/$enc/${width}px-$enc"
}

function dl($url, $path, $label) {
    try {
        Invoke-WebRequest -Uri $url -OutFile $path -UseBasicParsing -TimeoutSec 60 -MaximumRedirection 10
        if (Test-Path $path) {
            $sz = (Get-Item $path).Length
            if ($sz -lt 5000) {
                $msg = "SMALL($sz)  $label"
                $script:errors += $msg
            } else {
                $msg = "OK($sz)  $label"
            }
        } else {
            $msg = "MISSING  $label"
            $script:errors += $msg
        }
    } catch {
        $msg = "FAILED  $label  [$_]"
        $script:errors += $msg
    }
    $msg | Tee-Object -FilePath $logFile -Append
}

function wdl($wikiFilename, $localPath, $label) {
    $url = Get-WikiThumbUrl $wikiFilename
    dl $url $localPath $label
}

# ── Buenos Aires ───────────────────────────────────────────────────────────
wdl "Skyline_Puerto_Madero.jpg"                 "$base\buenos-aires\skyline_puerto_madero.jpg"                "BA/skyline_puerto_madero"
wdl "Casa_Rosada,_Buenos_Aires,_Argentina.jpg"  "$base\buenos-aires\casa_rosada_buenos_aires_argentina.jpg"  "BA/casa_rosada"
# Unsplash direct:
dl  "https://images.unsplash.com/photo-1679417302656-9b5170584526?w=800&auto=format&fit=crop" "$base\buenos-aires\la_boca_caminito.jpg"  "BA/la_boca_caminito"
wdl "Tango_in_Buenos_Aires.jpg"                 "$base\buenos-aires\tango_in_buenos_aires.jpg"               "BA/tango_in_buenos_aires"
wdl "Recoleta_Cemetery,_Buenos_Aires.jpg"       "$base\buenos-aires\recoleta_cemetery_buenos_aires.jpg"      "BA/recoleta_cemetery"

# ── Iguazu ─────────────────────────────────────────────────────────────────
wdl "Iguazu_National_Park_Falls.jpg"                           "$base\iguazu\iguazu_national_park_falls.jpg"                         "IGU/national_park_falls"
wdl "CATARATAS_DEL_IGUAZU._GARGANTA_DEL_DIABLO.jpg"           "$base\iguazu\cataratas_del_iguazu_garganta_del_diablo.jpg"           "IGU/garganta_del_diablo"
wdl "00_1838_Iguazu_Falls_from_the_Brazilian_side.jpg"         "$base\iguazu\00_1838_iguazu_falls_from_the_brazilian_side.jpg"       "IGU/brazilian_side"
wdl "Cataratas_del_Iguazu_Vista_General.JPG"                   "$base\iguazu\cataratas_del_iguazu_vista_general.jpg"                 "IGU/vista_general"
wdl "Ramphastos_toco_Iguazu.JPG"                               "$base\iguazu\ramphastos_toco_iguazu.jpg"                             "IGU/toucan"

# ── Peninsula Valdes ───────────────────────────────────────────────────────
wdl "Halbinsel_Valdes_Pinguine.jpg"                                      "$base\peninsula-valdes\halbinsel_valdes_pinguine.jpg"                         "PV/penguins"
wdl "Mother_and_calf_-_Right_whale.jpg"                                   "$base\peninsula-valdes\mother_and_calf_right_whale.jpg"                        "PV/right_whale"
wdl "Elefantes_Marinos_en_Peninsula_Valdes_-_panoramio.jpg"               "$base\peninsula-valdes\elefantes_marinos_en_peninsula_valdes_panoramio.jpg"    "PV/elephant_seals"
wdl "Orcas_in_Punta_Norte_Valdes_Peninsula_-_panoramio.jpg"               "$base\peninsula-valdes\orcas_in_punta_norte_valdes_peninsula_panoramio.jpg"    "PV/orcas"
wdl "Chubut-PuntaTombo-P2220157b-small.jpg"                               "$base\peninsula-valdes\chubut-puntatomo-p2220157b-small.jpg"                   "PV/punta_tombo"

# ── Ushuaia ────────────────────────────────────────────────────────────────
wdl "2019-11-18_Ushuaia_Panorama.jpg"                           "$base\ushuaia\2019-11-18_ushuaia_panorama.jpg"                     "USH/panorama"
dl  "https://images.unsplash.com/photo-1712921674663-0bf5370a2ce7?w=800&auto=format&fit=crop" "$base\ushuaia\king_penguins_martillo_island.jpg" "USH/king_penguins"
dl  "https://images.unsplash.com/photo-1652743920679-e48cddffadff?w=800&auto=format&fit=crop" "$base\ushuaia\lapataia_bay.jpg"                  "USH/lapataia_bay"
wdl "Ushuaia_and_the_Beagle_Channel_(5525434752).jpg"           "$base\ushuaia\ushuaia_and_the_beagle_channel_5525434752.jpg"       "USH/beagle_channel"
wdl "Tren_del_Fin_del_Mundo.jpg"                                "$base\ushuaia\tren_del_fin_del_mundo.jpg"                          "USH/end_of_world_train"

# ── El Calafate ────────────────────────────────────────────────────────────
dl  "https://images.unsplash.com/photo-1552751753-0fc84ae5b6c8?w=800&auto=format&fit=crop"  "$base\el-calafate\perito_moreno_glacier.jpg"                          "CAL/perito_moreno"
dl  "https://images.unsplash.com/photo-1529414988992-52e2db9372b2?w=800&auto=format&fit=crop" "$base\el-calafate\ice_trekking_glacier.jpg"                        "CAL/ice_trekking"
wdl "Perito_Moreno_Glacier_Calving_Event.jpg"                              "$base\el-calafate\perito_moreno_glacier_calving_event.jpg"           "CAL/calving"
wdl "Patagonia_Lago_Argentino_Rainbow_Iceberg_30Jan2025.jpg"               "$base\el-calafate\patagonia_lago_argentino_rainbow_iceberg_30jan2025.jpg" "CAL/lago_argentino"
wdl "Spegazzini_Glacier.jpg"                                               "$base\el-calafate\spegazzini_glacier.jpg"                             "CAL/spegazzini"

# ── El Chalten ─────────────────────────────────────────────────────────────
wdl "Los_Glaciares_-_Fitz_Roy_006.jpg"                                     "$base\el-chalten\los_glaciares_fitz_roy_006.jpg"                      "CHT/fitz_roy"
dl  "https://images.unsplash.com/photo-1610680224983-f9759ce81c7a?w=800&auto=format&fit=crop" "$base\el-chalten\fitz_roy_golden_hour.jpg"       "CHT/fitz_roy_golden"
wdl "Cerro_Torre.jpg"                                                      "$base\el-chalten\cerro_torre.jpg"                                     "CHT/cerro_torre"
wdl "Laguna_de_los_Tres_color.jpg"                                         "$base\el-chalten\laguna_de_los_tres_color.jpg"                        "CHT/laguna_tres"
wdl "El_Chalten-Sendero_Salto_del_Chorrillo_(39264011012).jpg"             "$base\el-chalten\el_chalten_sendero_salto_del_chorrillo_39264011012.jpg" "CHT/chorrillo"

# ── Bariloche ──────────────────────────────────────────────────────────────
wdl "Nahuel_Huapi_Lake_captured_from_Cerro_Otto's_top_in_summer.jpg"       "$base\bariloche\nahuel_huapi_lake_cerro_otto.jpg"                     "BAR/nahuel_huapi"
wdl "Cerro_Campanario_Bariloche_Argentina_-_panoramio_(12).jpg"            "$base\bariloche\cerro_campanario_bariloche_argentina_panoramio_12.jpg" "BAR/campanario"
wdl "Hotel_Llao_Llao,_Bariloche,_Argentina.jpg"                            "$base\bariloche\hotel_llao_llao_bariloche_argentina.jpg"               "BAR/llao_llao"
dl  "https://images.unsplash.com/photo-1598162480222-b2c3d92548d5?w=800&auto=format&fit=crop" "$base\bariloche\nye_fireworks_bariloche.jpg"       "BAR/nye_fireworks"
wdl "Argentina_-_Bariloche_trekking_002_-_Ventisquero_negro_(Black_Glacier)_on_spills_and_breaks_down_Cerro_Tronador._(6797401723).jpg" "$base\bariloche\ventisquero_negro_cerro_tronador.jpg" "BAR/ventisquero"

# ── Mendoza ────────────────────────────────────────────────────────────────
wdl "Vignoble_Mendoza_Argentine.jpg"                                       "$base\mendoza\vignoble_mendoza_argentine.jpg"                          "MZA/vignoble"
wdl "ALTURA_Argentina_Wine_Tourism_-_Bodega_Catena_Zapata_-_panoramio.jpg" "$base\mendoza\altura_argentina_wine_tourism_bodega_catena_zapata_panoramio.jpg" "MZA/catena_zapata"
wdl "Wine-touring_on_bikes.jpg"                                            "$base\mendoza\wine-touring_on_bikes.jpg"                               "MZA/wine_bikes"
wdl "La_Boca_Malbec.jpg"                                                   "$base\mendoza\la_boca_malbec.jpg"                                      "MZA/malbec"
wdl "Aconcagua_13.JPG"                                                     "$base\mendoza\aconcagua_13.jpg"                                        "MZA/aconcagua"

# ── Static Maps ────────────────────────────────────────────────────────────
dl "https://staticmap.openstreetmap.de/staticmap.php?center=-38,-65&zoom=4&size=800x500&markers=-34.6037,-58.3816,red-pushpin|-25.5996,-54.5795,red-pushpin|-42.7714,-65.0264,red-pushpin|-54.8019,-68.3030,red-pushpin|-50.3388,-72.2688,red-pushpin|-49.3310,-72.8855,red-pushpin|-41.1335,-71.3103,red-pushpin|-32.8908,-68.8272,red-pushpin" "$base\maps\map_overview.png" "MAP/overview"
dl "https://staticmap.openstreetmap.de/staticmap.php?center=-34.6037,-58.3816&zoom=12&size=800x400&markers=-34.6037,-58.3816,red-pushpin" "$base\maps\map_buenos_aires.png" "MAP/buenos_aires"
dl "https://staticmap.openstreetmap.de/staticmap.php?center=-25.69,-54.44&zoom=11&size=800x400&markers=-25.5996,-54.5795,red-pushpin|-25.6953,-54.4367,red-pushpin" "$base\maps\map_iguazu.png" "MAP/iguazu"
dl "https://staticmap.openstreetmap.de/staticmap.php?center=-42.4,-64.0&zoom=8&size=800x400&markers=-42.7714,-65.0264,red-pushpin|-42.5196,-64.2328,red-pushpin|-44.0219,-65.4347,red-pushpin" "$base\maps\map_peninsula_valdes.png" "MAP/peninsula_valdes"
dl "https://staticmap.openstreetmap.de/staticmap.php?center=-54.75,-68.35&zoom=10&size=800x400&markers=-54.8019,-68.3030,red-pushpin" "$base\maps\map_ushuaia.png" "MAP/ushuaia"
dl "https://staticmap.openstreetmap.de/staticmap.php?center=-50.34,-72.6&zoom=10&size=800x400&markers=-50.3388,-72.2688,red-pushpin|-50.4934,-73.0479,red-pushpin" "$base\maps\map_el_calafate.png" "MAP/el_calafate"
dl "https://staticmap.openstreetmap.de/staticmap.php?center=-49.33,-72.89&zoom=11&size=800x400&markers=-49.3310,-72.8855,red-pushpin|-49.2761,-72.9625,red-pushpin" "$base\maps\map_el_chalten.png" "MAP/el_chalten"
dl "https://staticmap.openstreetmap.de/staticmap.php?center=-41.13,-71.31&zoom=10&size=800x400&markers=-41.1335,-71.3103,red-pushpin" "$base\maps\map_bariloche.png" "MAP/bariloche"
dl "https://staticmap.openstreetmap.de/staticmap.php?center=-33.0,-68.85&zoom=9&size=800x400&markers=-32.8908,-68.8272,red-pushpin|-33.0478,-68.8917,red-pushpin|-33.5292,-69.0614,red-pushpin" "$base\maps\map_mendoza.png" "MAP/mendoza"

# ── Summary ────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "========== DOWNLOAD COMPLETE =========="
$allFiles = Get-ChildItem "$base" -Recurse -File
Write-Host "Total files: $($allFiles.Count)"
if ($errors.Count -gt 0) {
    Write-Host "ERRORS ($($errors.Count)):"
    $errors | ForEach-Object { Write-Host "  $_" }
} else {
    Write-Host "No errors!"
}
