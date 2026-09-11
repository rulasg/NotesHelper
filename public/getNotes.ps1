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
        [Parameter()][switch] $All,
        [Parameter()][switch] $Open,
        [Parameter()][switch] $Read
    )

    $DaysAgo = $DaysAgo -eq 0 ? 15 : $DaysAgo

    $notes = GetNotes -Filter $filter

    # Filter out files that are older than $DaysAgo unless $All is set
    $ret = $All ? $notes : ($notes | WhereNoteDateNewerThan -Days $DaysAgo )

    # Create a custom object with required properties
    $ret = $ret | ForEach-Object {
        [PSCustomObject]@{
            Name = $_ | Split-Path -LeafBase
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


    if ($Open) {
        $ret | ForEach-Object { Invoke-Item -Path $_.FullName }
    } 
    
    if($Read) {
        $ret | foreach-object { Get-Content -Path $_.FullName }
    } else {
        return $ret
    }


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

function WhereNoteDateNewerThan{
    param(
        [Parameter(Mandatory)][int32] $Days,
        [Parameter(Mandatory, ValueFromPipeline)][System.IO.FileInfo] $File
    )

    process{

        # $ret = $All ? $notes : ($notes | Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-$DaysAgo) })
        $datelimit = (Get-Date).AddDays(-$days)
        $fileDate = GetNoteDate($File)
        
        if ($fileDate -gt $datelimit) {
            return $File
        }
    }
}

function GetNoteDate{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline)][System.IO.FileInfo] $File
    )
    # read from the file name the date of the note.
    # return a DateTime object representing the date of the note.
    # The file date is encoded at the begining of the file name on a format YYMMDD

    process{

        $baseName = $File.Name
        
        if ($baseName -notmatch '^(?<year>\d{2})(?<month>\d{2})(?<day>\d{2})') {
            # if file has no date use fiel metafata
            $ret = $File.LastWriteTime
        } else {
            $year = [int]("20$($Matches.year)")
            $month = [int]$Matches.month
            $day = [int]$Matches.day
            $ret = [datetime]::new($year, $month, $day)
        }
        return $ret
    }
}