# Navigate to the root of the repository
$repoRoot = git rev-parse --show-toplevel
Set-Location $repoRoot

# Ensure submodules are initialized and updated
git submodule update --init --recursive

# Get the list of submodule paths
$submodules = git config --file .gitmodules --get-regexp path | ForEach-Object {
    $_ -split '\s+' | Select-Object -Last 1
}

foreach ($submodule in $submodules) {
    Write-Host "Updating submodule '$submodule'..."

    Set-Location "$repoRoot\$submodule"

    # Try to checkout and pull the main branch
    try {
        git checkout main 2>&1 | Out-Null
        git pull origin main
    } catch {
        Write-Warning "Failed to update submodule '$submodule': $_"
    }
}

# Return to the root repo and stage changes
Set-Location $repoRoot
git add .

# Automatically commit and push
$commitMessage = "Update submodules to latest on main"
git commit -m $commitMessage
git push