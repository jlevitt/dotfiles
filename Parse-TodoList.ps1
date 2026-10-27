param(
    [string]$FilePath = "To-do_list.csv",
    [switch]$KeepFile
)

# Check if file exists
if (-not (Test-Path $FilePath)) {
    Write-Error "File not found: $FilePath"
    exit 1
}

# Import the CSV file
try {
    $todos = Import-Csv -Path $FilePath
} catch {
    Write-Error "Failed to parse CSV file: $_"
    exit 1
}

# Initialize counters
$notStarted = 0
$blocked = 0
$inProgress = 0
$done = 0

foreach ($todo in $todos) {
    if ($todo.Completed -eq "true") {
        continue
    }

    switch ($todo.Status) {
        "Not Started" { $notStarted++ }
        "Blocked" { $blocked++ }
        "In Progress" { $inProgress++ }
        "Done" { $done++ }
    }
}

# Output the results
Write-Output "$notStarted,$blocked,$inProgress,$done"
"$notStarted,$blocked,$inProgress,$done" | clip

# Delete the file unless KeepFile is specified
if (-not $KeepFile) {
    Remove-Item -Path $FilePath -Force
}
