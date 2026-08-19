# Monitor Active Directory for newly-created users
# and send their information to an n8n production webhook.
#
# Usage:
#   $env:N8N_WEBHOOK_URL = "http://<N8N_PRIVATE_IP>:5678/webhook/iam-new-user"
#   .\Monitor-NewUsers.ps1
#
# Or:
#   .\Monitor-NewUsers.ps1 -WebhookUrl "http://<N8N_PRIVATE_IP>:5678/webhook/iam-new-user"

param(
    [string]$WebhookUrl = $env:N8N_WEBHOOK_URL,
    [int]$CheckInterval = 30
)

if ([string]::IsNullOrWhiteSpace($WebhookUrl)) {
    throw "Webhook URL not configured. Set N8N_WEBHOOK_URL or use -WebhookUrl."
}

Import-Module ActiveDirectory

$lastCheck = Get-Date

Write-Host "Monitoring Active Directory for new users..." -ForegroundColor Cyan
Write-Host "n8n Webhook: $WebhookUrl" -ForegroundColor DarkGray

while ($true) {

    $currentCheck = Get-Date

    $newUsers = Get-ADUser `
        -Filter { whenCreated -ge $lastCheck } `
        -Properties whenCreated, Title, Department, EmailAddress, Manager, UserPrincipalName

    foreach ($user in $newUsers) {

        $payload = @{
            samAccountName = $user.SamAccountName
            displayName    = $user.Name
            email          = $user.UserPrincipalName
            title          = $user.Title
            department     = $user.Department
            createdAt      = $user.whenCreated.ToString("o")
        } | ConvertTo-Json

        try {
            Invoke-RestMethod `
                -Uri $WebhookUrl `
                -Method POST `
                -Body $payload `
                -ContentType "application/json" `
                -ErrorAction Stop

            Write-Host "Sent new user to n8n: $($user.Name)" -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to send user to n8n: $($user.Name)" -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor DarkRed
        }
    }

    $lastCheck = $currentCheck

    Start-Sleep -Seconds $CheckInterval
}