
Set-MyInvokeCommandAlias -Alias GetNotesRoot 'Invoke-NotesHelperNotesRoot'

function Resolve-NotesPath {
    [CmdletBinding()]
    param(
        [Parameter()] [string] $Path
    )

    # Check if path is provided
    if (-Not [string]::IsNullOrWhiteSpace($Path)) {
        $resolvedPath = $Path
    } else{
        $resolvedPath = Invoke-MyCommand -Command GetNotesRoot
    }

    if([string]::IsNullOrWhiteSpace($resolvedPath)) {
        throw "Notes root path is not set. Please set the NOTES_ROOT."
    }

    return $resolvedPath
} export-ModuleMember -Function Resolve-NotesPath

function Get-NoteFolder{
    [CmdletBinding()]
    param(
        [Parameter()][string] $Category,
        [Parameter()][string] $Section,
        [Parameter()][switch] $Force
    )
    
    $notesPath = Resolve-NotesPath

    # Add the category if needed
    if(-Not [string]::IsNullOrWhiteSpace($Category)) {
        $notesPath = $notesPath | Join-Path -ChildPath $Category
    }

    if(-Not [string]::IsNullOrWhiteSpace($Section)) {
        $notesPath = $notesPath | Join-Path -ChildPath $Section
    }

    $folder = New-FolderIfNotExists -Path $notesPath -Force:$Force

    return $folder
} Export-ModuleMember -Function Get-NoteFolder

function New-FolderIfNotExists{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)][string] $Path,
        [Parameter()][switch] $Force
    )

       # Check if client folder exists
    if (-not (Test-Path -Path $Path)) {
        if ($Force) {
            # Create folder if Force is specified
            New-Item -Path $Path -ItemType Directory -Force | Out-Null
            Write-Verbose "Created folder: $Path"
        }
        else {
            # Fail gracefully if folder doesn't exist and Force is not specified
            Write-Error  "Folder does not exist: $Path"
            return $null
        }
    }

    return $Path
}

function Invoke-NotesHelperNotesRoot{
    [CmdletBinding()]
    param()

    $config = Get-NotesHelperConfig
    return $config.NotesRoot
} Export-ModuleMember -Function Invoke-NotesHelperNotesRoot