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
        [Parameter()][string] $Filter,
        #all
        [Parameter()][switch] $All
    )

    $notes = GetNotes -Filter $filter

    # Filter out files that are older than 30 days
    $ret = $All ? $notes : ($notes | Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-30) })

    return $ret.FullName

} Export-ModuleMember -Function Get-Notes -Alias "notes"

function GetNotes () {
    [CmdletBinding()]
    param(
        [Parameter()][string] $Filter
    )

    $filter = "*$Filter*.md"

    $notesPath = Resolve-NotesPath

    $notes = Get-ChildItem -Path $notesPath -filter $filter -Recurse

    return $notes

}