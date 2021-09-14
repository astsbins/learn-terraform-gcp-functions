Write-Output "Comppressing python_code..."
Compress-Archive -Path "./python_code/*" -DestinationPath "./python_code.zip" -Force
Write-Output "Running terraform apply"
terraform apply
