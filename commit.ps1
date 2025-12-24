# Get the list of untracked files
$untrackedFiles = (git ls-files --others --exclude-standard) -split '\r\n|\n|\r' | Where-Object { $_ -ne "" }

# Get the list of modified files (staged and unstaged)
$modifiedUnstaged = (git diff --name-only) -split '\r\n|\n|\r' | Where-Object { $_ -ne "" }
$modifiedStaged = (git diff --cached --name-only) -split '\r\n|\n|\r' | Where-Object { $_ -ne "" }
$modifiedFiles = ($modifiedUnstaged + $modifiedStaged) | Select-Object -Unique

# Combine all files to commit
$allFiles = ($untrackedFiles + $modifiedFiles) | Select-Object -Unique

# Comprehensive commit message for TipJar contract on Stacks blockchain
$commitMessage = "Updated TipJar smart contract on Stacks blockchain using Clarity 4, enabling decentralized tipping with personalized messages, transparent tracking, and secure STX transfers. Implements access controls, data persistence, and integration with Stacks ecosystem. Developed with Clarinet toolkit, includes comprehensive test suite with Vitest, and optimized for Stacks' blockchain efficiency."

# Commit each file individually
foreach ($file in $allFiles) {
    if ($file -ne "") {
        git add $file
        git commit --only $file -m "$commitMessage - $file"
    }
}

# All changes have been committed
Write-Host "All changes have been committed."