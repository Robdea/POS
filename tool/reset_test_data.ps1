# reset_test_data.ps1
# Re-sembra el entorno de prueba en Firestore usando SOLO el usuario admin (rol Jefe).
# No modifica reglas de seguridad ni requiere acceso de administrador de Firebase.
#
# Uso (Windows PowerShell 5.1+):
#   .\tool\reset_test_data.ps1 -Email admin@gmail.com -Password "xftyxcvb27"
#   $env:FIREBASE_TEST_PASS="xftyxcvb27"; .\tool\reset_test_data.ps1
#
# Requisitos: curl.exe (viene con Windows 10+).

param(
  [string]$Email = 'admin@gmail.com',
  [string]$Password = $env:FIREBASE_TEST_PASS
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($Password)) {
  Write-Host 'ERROR: No se indico la contrasena. Use -Password o la variable FIREBASE_TEST_PASS.' -ForegroundColor Red
  exit 1
}

$apiKey = 'AIzaSyAIhbMwXH_pG-6Nxv-1wnYedZPWLq3O4JU'
$project = 'proyecto1001-e7f1a'
$base = "https://firestore.googleapis.com/v1/projects/$project/databases/(default)/documents"
$enc = New-Object System.Text.UTF8Encoding($false)
$tmpBody = Join-Path $env:TEMP 'firebase_body.json'

Write-Host "Iniciando sesion como $Email ..."
$signIn = @{ email = $Email; password = $Password; returnSecureToken = $true } | ConvertTo-Json
try {
  $auth = Invoke-RestMethod -Method Post -Uri "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey" -ContentType 'application/json' -Body $signIn
} catch {
  Write-Host ('ERROR: No se pudo autenticar. Verifica credenciales. ' + $_.Exception.Message) -ForegroundColor Red
  exit 1
}
$uid = $auth.localId
$token = $auth.idToken
$hAuth = "Authorization: Bearer $token"
Write-Host ("Sesion OK (uid=$uid, role=Jefe)") -ForegroundColor Green

function Curl-Raw($argsList, $url) {
  $out = & curl.exe -s -o - @argsList $url 2>&1
  $code = $LASTEXITCODE
  return ,@($code, ($out -join "`n"))
}

function Invoke-Post($coll, $docId, $fields) {
  $json = @{ fields = $fields } | ConvertTo-Json -Depth 15
  [System.IO.File]::WriteAllText($tmpBody, $json, $enc)
  $r = Curl-Raw @('-X', 'POST', '-H', $hAuth, '-H', 'Content-Type: application/json', '-d', "@$tmpBody") "$base/$coll`?documentId=$docId"
  if ($r[0] -ne 0) { throw "curl fallo (codigo $($r[0])) al crear $coll/$docId" }
  if ($r[1] -match '"code": 409') { Write-Host ("SKIP  $coll/$docId (ya existe)") -ForegroundColor DarkYellow; return }
  if ($r[1] -match '"error"') { throw "Firestore rechazo $coll/$docId : $($r[1])" }
  Write-Host ("POST  $coll/$docId") -ForegroundColor Green
}

function Invoke-Delete($coll, $docId) {
  $r = Curl-Raw @('-X', 'DELETE', '-H', $hAuth) "$base/$coll/$docId"
  if ($r[0] -ne 0) { throw "curl fallo al borrar $coll/$docId" }
  if ($r[1] -match '"error"') { throw "Firestore rechazo DELETE $coll/$docId : $($r[1])" }
  Write-Host ("DEL   $coll/$docId") -ForegroundColor Yellow
}

function Get-DocIds($coll) {
  $r = Curl-Raw @('-H', $hAuth) "$base/$coll`?pageSize=300"
  if ($r[0] -ne 0 -or $r[1] -match '"error"') { return @() }
  $list = $r[1] | ConvertFrom-Json
  return @($list.documents | ForEach-Object { (($_.name -split '/documents/')[1] -split '/')[-1] })
}

function Add-Str($f, $k, $v) { $f[$k] = @{ stringValue = $v } }
function Add-Ts($f, $k, $v) { $f[$k] = @{ timestampValue = $v } }
function Add-Int($f, $k, $v) { $f[$k] = @{ integerValue = $v } }
function Add-Dbl($f, $k, $v) { $f[$k] = @{ doubleValue = [double]$v } }

# ---- Datos de prueba (acentos construidos con [char] para evitar problemas de codificacion) ----
$ac = 0x00E1; $eo = 0x00F3; $ie = 0x00ED   # a/ o/ i acentuadas
$nLacteos   = 'L' + [char]$ac + 'cteos'

$docs = @()

# users (admin / Jefe) - solo crear si no existe
$f = @{}; Add-Str $f 'name' 'Admin'; Add-Str $f 'email' $Email; Add-Str $f 'role' 'Jefe'; Add-Ts $f 'createdAt' '2026-09-10T01:20:00Z'; Add-Ts $f 'updatedAt' '2026-09-10T01:20:00Z'
$docs += ,@{ coll='users'; docId=$uid; fields=$f }

# categories
$f = @{}; Add-Str $f 'name' 'Abarrotes'; Add-Str $f 'description' ('Productos b' + [char]$ac + 'sicos de despensa'); Add-Ts $f 'createdAt' '2026-09-10T01:20:00Z'; Add-Ts $f 'updatedAt' '2026-09-10T01:20:00Z'
$docs += ,@{ coll='categories'; docId='cat-ab'; fields=$f }

$f = @{}; Add-Str $f 'name' $nLacteos; Add-Str $f 'description' 'Leche, quesos y derivados'; Add-Ts $f 'createdAt' '2026-09-10T01:20:00Z'; Add-Ts $f 'updatedAt' '2026-09-10T01:20:00Z'
$docs += ,@{ coll='categories'; docId='cat-la'; fields=$f }

$f = @{}; Add-Str $f 'name' 'Bebidas'; Add-Str $f 'description' 'Refrescos, jugos y agua'; Add-Ts $f 'createdAt' '2026-09-10T01:20:00Z'; Add-Ts $f 'updatedAt' '2026-09-10T01:20:00Z'
$docs += ,@{ coll='categories'; docId='cat-be'; fields=$f }

# products
$f = @{}; Add-Str $f 'name' 'Arroz 1kg'; Add-Str $f 'description' 'Arroz blanco de grano largo'; Add-Str $f 'categoryId' 'cat-ab'; Add-Ts $f 'entryDate' '2026-08-01T00:00:00Z'; Add-Ts $f 'expirationDate' '2027-08-01T00:00:00Z'; Add-Int $f 'currentStock' '40'; Add-Dbl $f 'purchaseCost' 22.5; Add-Ts $f 'createdAt' '2026-09-10T01:20:00Z'; Add-Ts $f 'updatedAt' '2026-09-10T01:20:00Z'
$docs += ,@{ coll='products'; docId='prod-001'; fields=$f }

$f = @{}; Add-Str $f 'name' 'Frijol 1kg'; Add-Str $f 'description' 'Frijol negro'; Add-Str $f 'categoryId' 'cat-ab'; Add-Ts $f 'entryDate' '2026-08-10T00:00:00Z'; Add-Int $f 'currentStock' '15'; Add-Dbl $f 'purchaseCost' 28.0; Add-Ts $f 'createdAt' '2026-09-10T01:20:00Z'; Add-Ts $f 'updatedAt' '2026-09-10T01:20:00Z'
$docs += ,@{ coll='products'; docId='prod-002'; fields=$f }

$f = @{}; Add-Str $f 'name' 'Leche entera 1L'; Add-Str $f 'description' 'Leche ultrapasteurizada'; Add-Str $f 'categoryId' 'cat-la'; Add-Ts $f 'entryDate' '2026-09-01T00:00:00Z'; Add-Ts $f 'expirationDate' '2026-10-01T00:00:00Z'; Add-Int $f 'currentStock' '24'; Add-Dbl $f 'purchaseCost' 26.9; Add-Ts $f 'createdAt' '2026-09-10T01:20:00Z'; Add-Ts $f 'updatedAt' '2026-09-10T01:20:00Z'
$docs += ,@{ coll='products'; docId='prod-003'; fields=$f }

$f = @{}; Add-Str $f 'name' 'Yogur natural 500g'; Add-Str $f 'description' 'Yogur de vainilla'; Add-Str $f 'categoryId' 'cat-la'; Add-Ts $f 'entryDate' '2026-09-01T00:00:00Z'; Add-Ts $f 'expirationDate' '2026-09-15T00:00:00Z'; Add-Int $f 'currentStock' '3'; Add-Dbl $f 'purchaseCost' 18.0; Add-Ts $f 'createdAt' '2026-09-10T01:20:00Z'; Add-Ts $f 'updatedAt' '2026-09-10T01:20:00Z'
$docs += ,@{ coll='products'; docId='prod-004'; fields=$f }

$f = @{}; Add-Str $f 'name' 'Refresco cola 600ml'; Add-Str $f 'description' 'Refresco de cola'; Add-Str $f 'categoryId' 'cat-be'; Add-Ts $f 'entryDate' '2026-09-05T00:00:00Z'; Add-Ts $f 'expirationDate' '2026-12-05T00:00:00Z'; Add-Int $f 'currentStock' '5'; Add-Dbl $f 'purchaseCost' 15.0; Add-Ts $f 'createdAt' '2026-09-10T01:20:00Z'; Add-Ts $f 'updatedAt' '2026-09-10T01:20:00Z'
$docs += ,@{ coll='products'; docId='prod-005'; fields=$f }

$f = @{}; Add-Str $f 'name' 'Agua 1L'; Add-Str $f 'description' 'Agua purificada'; Add-Str $f 'categoryId' 'cat-be'; Add-Ts $f 'entryDate' '2026-09-01T00:00:00Z'; Add-Int $f 'currentStock' '60'; Add-Dbl $f 'purchaseCost' 8.5; Add-Ts $f 'createdAt' '2026-09-10T01:20:00Z'; Add-Ts $f 'updatedAt' '2026-09-10T01:20:00Z'
$docs += ,@{ coll='products'; docId='prod-006'; fields=$f }

$f = @{}; Add-Str $f 'name' 'Sal 1kg'; Add-Str $f 'description' 'Sal de mesa'; Add-Str $f 'categoryId' 'cat-ab'; Add-Ts $f 'entryDate' '2026-08-15T00:00:00Z'; Add-Ts $f 'expirationDate' '2030-08-15T00:00:00Z'; Add-Int $f 'currentStock' '0'; Add-Dbl $f 'purchaseCost' 7.0; Add-Ts $f 'createdAt' '2026-09-10T01:20:00Z'; Add-Ts $f 'updatedAt' '2026-09-10T01:20:00Z'
$docs += ,@{ coll='products'; docId='prod-007'; fields=$f }

# audit_logs (solo se crean si no existen; no se borran por reglas)
function New-Audit($docId, $action, $entityType, $entityId, $desc) {
  $g = @{}; Add-Str $g 'userId' $uid; Add-Str $g 'userName' 'Admin'; Add-Str $g 'action' $action; Add-Str $g 'entityType' $entityType; Add-Str $g 'entityId' $entityId; Add-Str $g 'description' $desc; Add-Ts $g 'createdAt' '2026-09-10T01:20:00Z'
  $script:docs += ,@{ coll='audit_logs'; docId=$docId; fields=$g }
}
New-Audit 'log-001' 'LOGIN'           'user'     $uid        ('Inicio de sesi' + [char]$eo + 'n')
New-Audit 'log-002' 'CREATE_CATEGORY' 'category' 'cat-ab'    ('Se cre' + [char]$eo + ' la categor' + [char]$ie + 'a Abarrotes')
New-Audit 'log-003' 'CREATE_CATEGORY' 'category' 'cat-la'    ('Se cre' + [char]$eo + ' la categor' + [char]$ie + 'a L' + [char]$ac + 'cteos')
New-Audit 'log-004' 'CREATE_CATEGORY' 'category' 'cat-be'    ('Se cre' + [char]$eo + ' la categor' + [char]$ie + 'a Bebidas')
New-Audit 'log-005' 'CREATE_PRODUCT'  'product'  'prod-001'  ('Se cre' + [char]$eo + ' el producto Arroz 1kg')
New-Audit 'log-006' 'UPDATE_STOCK'    'product'  'prod-004'  ('Se actualiz' + [char]$eo + ' stock a 3')

# ---- Reseteo de catalogo (borra y recrea categories/products; users/audit se conservan) ----
Write-Host "`n=== Reseteando catalogo (categories, products) ===" -ForegroundColor Cyan
foreach ($target in @('categories', 'products')) {
  foreach ($path in Get-DocIds $target) { Invoke-Delete $target $path }
}

Write-Host "`n=== Creando documentos ===" -ForegroundColor Cyan
foreach ($d in $docs) { Invoke-Post $d.coll $d.docId $d.fields }

Write-Host "`n=== Resumen ===" -ForegroundColor Cyan
foreach ($target in @('users', 'categories', 'products', 'audit_logs')) {
  $ids = Get-DocIds $target
  Write-Host ("  " + $target + ": " + $ids.Count + " doc(s)")
}

Write-Host "`nListo. Datos sembrados para probar la app con $Email." -ForegroundColor Green