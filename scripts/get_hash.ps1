param(
  [Parameter(Mandatory=$true)][string]$Path
)
if (-not (Test-Path $Path)) {
  Write-Error "Arquivo não encontrado: $Path"
  exit 1
}
$h = Get-FileHash -Algorithm SHA256 -Path $Path
Write-Output ("SHA256: " + $h.Hash)
