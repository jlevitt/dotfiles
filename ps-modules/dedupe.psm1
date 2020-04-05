function hash($fileInfo)
{
    #$fileInfo.Name + "-" + $fileInfo.Length
    $fileInfo.Name
}

function New-DupeInfo($Filename, $Files)
{
    $compare = {
        foreach ($file in $Files)
        {
            & $file.FullName
        }
    }.GetNewClosure()

    New-Object -TypeName psobject -Property @{ Filename = $Filename; Files = $Files | select -ExpandProperty FullName; Compare = $compare }
}

function Get-Dupes
{
param(
    [string]$Path
)
    $hashes = @{}
    $files = gci $Path -r | where { ! $_.PSIsContainer }

    foreach ($file in $files)
    {
        $hash = hash($file)

        if ($hashes.Contains($hash))
        {
            $hashes[$hash] += $file
        }
        else
        {
            $hashes[$hash] =  @($file)
        }
    }

    $hashes.GetEnumerator() |? { $_.Value.Length -gt 1 } |% { New-DupeInfo $_.Key $_.Value }
}
#
# $hashes = New-Object System.Collections.Generic.HashSet[string]
# $dupes = @()
# $unique = @()
#
# gci $dest -r | where { ! $_.PSIsContainer } |% { $hashes.Add((hash($_))) | Out-Null }
#
# $srcFiles = gci $src -r | where { ! $_.PSIsContainer }
# foreach ($file in $srcFiles)
# {
#     $srcHash = hash($file)
#
#     if ($hashes.Contains($srcHash))
#     {
#         $dupes += $file
#         cp $($file.FullName) $grouped\dupes
#     }
#     else
#     {
#         $unique += $file
#         cp $($file.FullName) $grouped\unique
#     }
# }
#
# "Dupes ($($dupes.Length)):"
# $dupes
#
# "*********************************"
# "Unique ($($unique.Length)):"
# $unique

