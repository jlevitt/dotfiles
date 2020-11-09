
param(
    $path
)

$lines = gc $path
$foundImports = $false
$output = @()
    
foreach ($line in $lines)
{
    if ($foundImports)
    {
        if ([string]::IsNullOrWhiteSpace($line))
        {
            continue
        }
    }

    if ($line.Contains("import ("))
    {
        $foundImports = $true
    }

    if ($line.Contains(")"))
    {
        $foundImports = $false
    }

    $output += $line
}

$output | sc $path

goimports -local github.com/omnivore/giganto -w $path