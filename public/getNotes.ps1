function Get-NotesToday {
    # Get-NotesToday
    [CmdletBinding()]
    param()

    GetNotes | Show-Today | fn
} Export-ModuleMember -Function Get-NotesToday

#Get-NotesYesterday
function Get-NotesYesterday {
    [CmdletBinding()]
    param()

    return GetNotes | Show-Yesterday | fn

} Export-ModuleMember -Function Get-NotesYesterday

# Get-Notes
function Get-Notes () {
    [CmdletBinding()]
    [Alias("notes")]
    param(
        [Parameter(Position=0)][string] $Filter,
        [Parameter()][int32] $DaysAgo,
        #all
        [Parameter()][switch] $All
    )

    $DaysAgo = $DaysAgo -eq 0 ? 15 : $DaysAgo

    $notes = GetNotes -Filter $filter

    # Filter out files that are older than 30 days
    $ret = $All ? $notes : ($notes | Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-$DaysAgo) })

    # Create a custom object with required properties
    $ret = $ret | ForEach-Object {
        [PSCustomObject]@{
            Name = $_ | Split-Path -Leaf
            Category = $_ | GetNotesCategory
            FullName = $_.FullName
        }
    }

    # Sort by Parent name
    $ret = $ret | Sort-Object -Property Name -Descending

    #if $ret is empty and $all is not set write a message sugesting to use -All
    if (-not $All -and $ret.Count -eq 0) {
        Write-Host "No notes found in the last 30 days. Use -All to see all notes." -ForegroundColor Yellow
    }

    return $ret

} Export-ModuleMember -Function Get-Notes -Alias "notes"

function GetNotes () {
    [CmdletBinding()]
    param(
        [Parameter()][string] $Filter
    )

    $filter = "*$Filter*.md"

    $notesPath = Resolve-NotesPath

    $notes = Get-ChildItem -Path $notesPath -filter $filter -Recurse -File

    return $notes

}

function GetNotesCategory {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline)][object]$Path
    )

    process{
        $ret = (($Path | Split-Path -Leaf) -split '-|\.')[1]
        return $ret
    }

   

}