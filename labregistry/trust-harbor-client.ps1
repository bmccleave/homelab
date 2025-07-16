# trust-harbor-client.ps1
# Run this as Administrator

$domain = "labregistry.local"
$caCertPath = ".\ca.cert.pem"  # Expecting CA cert in current directory

if (!(Test-Path $caCertPath)) {
    Write-Error "Missing ca.cert.pem. Copy it from the Harbor VM."
    exit 1
}

# Convert PEM to CRT (required by Windows)
$crtPath = "$PWD\myhomeCA.crt"
Get-Content $caCertPath | Set-Content -Encoding ascii $crtPath

Write-Host "📥 Installing CA certificate into Windows Root store..."
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
$cert.Import($crtPath)
$store = New-Object System.Security.Cryptography.X509Certificates.X509Store("Root", "LocalMachine")
$store.Open("ReadWrite")
$store.Add($cert)
$store.Close()

Write-Host "✅ CA root certificate installed in Trusted Root Certification Authorities"

# Docker Desktop trust directory
$dockerCertPath = "C:\ProgramData\Docker\certs.d\$domain"
if (!(Test-Path $dockerCertPath)) {
    New-Item -ItemType Directory -Path $dockerCertPath -Force | Out-Null
}
Copy-Item $crtPath "$dockerCertPath\ca.crt" -Force

Write-Host "🐳 Docker Desktop will trust $domain"

Write-Host "`n🎉 Done! Windows and Docker now trust https://$domain"
