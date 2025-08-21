param(
  [Parameter(Mandatory = $true)][string]$SubscriptionId,
  [Parameter(Mandatory = $true)][string]$Location
)

Connect-AzAccount -Subscription $SubscriptionId | Out-Null

$apiVersion = "2023-12-30"
$uri = "/subscriptions/$SubscriptionId/providers/Microsoft.DBforMySQL/locations/$Location/capabilitySets?api-version=$apiVersion"

# Log request details
Write-Host "INFO: Calling API - GET $uri" -ForegroundColor Cyan

try {
    $response = Invoke-AzRestMethod -Method GET -Path $uri -ErrorAction Stop
    Write-Host "INFO: API call succeeded" -ForegroundColor Green
}
catch {
    Write-Host " ** REST API call failed **" -ForegroundColor Red
    Write-Host "Error Message: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        # Attempt to extract HTTP status if available
        $status = $_.Exception.Response.StatusCode.value__ 2>$null
        if ($status) { Write-Host "Status Code: $status" }
    }
    return
}

$data = $response.Content | ConvertFrom-Json
# Check if 'value' exists and has at least one item
if (-not $data.value -or $data.value.Count -eq 0) {
    Write-Warning "No capabilitySets returned in the response. You may not have access in region '$Location'. Consider filing a support request."
    return
}

$capability = $data.value[0]

# Supported server versions
$supportedVersions = $capability.properties.supportedServerVersions | Select-Object -ExpandProperty name
Write-Host "`nSupported MySQL server versions in '$Location':"
if ($supportedVersions) {
    $supportedVersions | ForEach-Object { Write-Host "- $_" }
} else {
    Write-Warning "No supported server versions available; your subscription may lack access in this region. Consider filing a support request."
}

# Flexible Server editions & HA modes
Write-Host "`nAvailable Flexible Server editions and HA modes:"
$editions = $capability.properties.supportedFlexibleServerEditions
if ($editions) {
    foreach ($edition in $editions) {
        Write-Host "`nEdition: $($edition.name)"
        foreach ($sku in $edition.supportedSkus) {
            $haModes = $sku.supportedHAMode -join ", "
            Write-Host "  SKU Name: $($sku.name); HA Modes: $haModes"
        }
    }
} else {
    Write-Warning "No server editions available; your subscription may lack access in this region. Consider filing a support request."
}