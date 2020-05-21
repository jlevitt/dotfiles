function hash($fileInfo)
{
    #$fileInfo.Name + "-" + $fileInfo.Length
    $fileInfo.Name.Replace("_converted", "")
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
        Write-Host "mv $($file.FullName) $($this.DiscardPath)\$($file.BaseName)_$rnd$($file.Extension)"
        $this.Files.RemoveAt($index)

    }
}

Update-FormatData -PrependPath DupeInfo.ps1xml

function addFiles($hashes, $files)
{
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
}

function Get-Dupes
{
param(
    [string]$Path,
    [string]$DiscardPath,
    [string]$Dest = $null
)
    $hashes = @{}


    $files = gci $Path -r |? { ! $_.PSIsContainer }
    Write-Host "Found $($files | measure | select -ExpandProperty Count) source file(s)..."
    addFiles $hashes $files
    Write-Host "Source file hashes added..."
    
    if ($dest)
    {
        $destFiles = gci $Dest -r |? { ! $_.PSIsContainer }
        Write-Host "Found $($destFiles | measure | select -ExpandProperty Count) dest file(s)..."
        addFiles $hashes $destFiles
        Write-Host "Dest file hashes added..."
    }

    $hashes.GetEnumerator() |? { $_.Value.Length -gt 1 } |% { [DupeInfo]::new($_.key, $_.Value, $DiscardPath) }
}

function Process-Dupes($dupes)
{
    foreach ($dupe in $dupes)
    {
        $dupe.Compare()
        $dupe
        "s - skip"
        "q - quit"

        $choice = Read-Host "Delete?"

        switch ($choice)
        {
            "s" { continue }
            "q" { return }
            default
            {
                $index = [int]$choice - 1
                $file = $dupe.Files[$index]
                "Deleting $($file.FullName)..."
                $dupe.rm([int]$choice)
            }
        }

    }
    "Done processing."
}


function Compare-Paths
{
param(
    [string]$Src,
    [string]$Dest,
    [switch]$Missing
)
    $hashes = @{}

    $destFiles = gci $Dest -r |? { ! $_.PSIsContainer }
    Write-Host "Found $($destFiles | measure | select -ExpandProperty Count) dest file(s)..."
    addFiles $hashes $destFiles
    Write-Host "Dest file hashes added..."


    $srcFiles = gci $Src -r |? { ! $_.PSIsContainer }
    Write-Host "Found $($srcFiles | measure | select -ExpandProperty Count) source file(s)..."
    $diff = $srcFiles |? {  if ($Missing) { ! $hashes.Contains($(hash $_)) } else { $hashes.Contains($(hash $_)) }}

    return $diff
}

