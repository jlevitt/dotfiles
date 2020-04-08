function hash($fileInfo)
{
    #$fileInfo.Name + "-" + $fileInfo.Length
    $fileInfo.Name
}

class DupeInfo
{
    $Filename
    $Files
    $DiscardPath
    
    DupeInfo(
        [string]$filename,
        [System.Collections.Generic.List[System.IO.FileInfo]]$files,
        [string]$discardPath
    ){
        $this.Filename = $filename
        $this.Files = $files
        $this.DiscardPath = $discardPath
    }
    
    [void]Compare()
    {
        foreach ($file in $this.Files)
        {
            & $file.FullName
        }
    }

    [void]rm([int]$index)
    {
        $index--
        $file = $this.Files[$index]
        $rnd = [System.IO.Path]::GetRandomFileName()
        mv $file.FullName "$($this.DiscardPath)\$($file.BaseName)_$rnd$($file.Extension)"
        $this.Files.RemoveAt($index)

    }
}

Update-FormatData -PrependPath DupeInfo.ps1xml

function Get-Dupes
{
param(
    [string]$Path,
    [string]$DiscardPath
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

    $hashes.GetEnumerator() |? { $_.Value.Length -gt 1 } |% { [DupeInfo]::new($_.key, $_.Value, $DiscardPath) }
}

$dupes = Get-Dupes E:\media\pictures\family E:\discards
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

