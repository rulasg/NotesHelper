
function New-Note{
    # Add Force parameter to support creation of client folder if it doesn't exist
    [CmdletBinding()]
    [alias("note")]
    param(
        [Parameter(Mandatory,Position = 0)][string] $Category,
        [Parameter(Mandatory,Position = 1)][string] $Title,
        [Parameter()][string] $Date,
        [Parameter()][string] $Section,
        [Parameter()][string] $Notes,
        [Parameter()][string] $IssueUrl,
        [Parameter()][string] [ValidateSet("none","meetingmini")] $Template = "none",
        [Parameter()][switch] $NoOpen,
        [Parameter()][switch] $AddNoteFolder,
        [Parameter()][switch] $Force,
        [Parameter()][string] $RootPath,
        [Parameter()][switch] $DateToday

    )

    # FILENAME

    $folder = Get-NoteFolder -RootPath $RootPath -Category $Category -Section $Section -Force:$Force

    if(-Not $folder) {
        Write-Error "Failed to create the folder for the note. Try -Force."
        return
    }

    if(-Not (Test-Path -Path $folder)) {
        Write-Error "Base folder for note does not exist '$folder'. Try -Force."
        return
    }

    # Replace date with today if specified
    if($DateToday) {
        $Date = Get-Date -Format "yyMMdd"
    }

    if([string]::IsNullOrWhiteSpace($Date)) {
        Write-Error "Date is empty. Consider using -DateToday or -Date to specify a date for the note."
        return
    }

    $fileName = getFileName -Category $Category -Section $Section -Title $Title -Date $Date

    # Create the note base folder
    if($AddNoteFolder){
        # Create full path for the note file
        $noteFolder = Join-Path -Path $folder -ChildPath $fileName
        
        if (-not (Test-Path -Path $noteFolder)) {
            New-Item -Path $noteFolder -ItemType Directory -Force | Out-Null
            Write-Verbose "Created note folder: $noteFolder"
        }
        
        $fullPath =$noteFolder | Join-Path -ChildPath "$fileName.md"
    } else {
        # use folder as the parent folder of the note
        $fullPath = Join-Path -Path $folder -ChildPath "$fileName.md"
    }
    
    # Check if file already exists
    if (-Not (Test-Path -Path $fullPath)) {

        $header = [string]::IsNullOrWhiteSpace($Section) ? $Category : $Section

        $content = getFileContent $Template $Title $header -Notes $Notes -IssueUrl $IssueUrl -Date $Date

        # If $Force check that the folders of $fullPath exists and if not create it
        if ($Force) {
            $parentFolder = Split-Path -Path $fullPath -Parent
            if (-Not (Test-Path -Path $parentFolder)) {
                New-Item -Path $parentFolder -ItemType Directory -Force | Out-Null
                Write-Verbose "Created folder: $parentFolder"
            }
        }

        # Create the file with content
        Set-Content -Path $fullPath -Value $content -Force
    }
    
    if( -not $NoOpen) {
        # Open file in VS Code with cursor at the end
        $gotocmd = "{0}{1}" -f $fullPath, ":9999"
        code --goto $gotocmd 
    }

    # Return file just created
    return $fullPath

} Export-ModuleMember -Function New-Note -Alias "note"

function getFileName{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string] $Category,
        [Parameter(Mandatory)][string] $Title,
        [Parameter()][string] $Section,
        [Parameter()][string] $Date
    )
    
    # Create FullTitle using folder name and title, replacing spaces with underscores

    $header = [string]::IsNullOrWhiteSpace($Section) ? $Category : $Section

    if([string]::IsNullOrWhiteSpace($Date)) {
        $fullTitle = "{0}-{1}" -f $header, $Title
    } else{
        $fullTitle = "{0}-{1}-{2}" -f $Date, $header, $Title
    }

    # Normilize fullTitle by removing special characters and replacing spaces with underscores
    $fullTitle = $fullTitle -replace '\s+', '_'

    return $fullTitle
}

function getFileContent{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position = 0)][string] $Template,
        [Parameter(Mandatory,Position = 1)][string] $Title,
        [Parameter(Mandatory,Position = 2)][string] $header,
        [Parameter(Position = 3)][string] $Date,
        [Parameter()][string] $Notes,
        [Parameter()][string] $IssueUrl
    )

    # Get template content
    $content = Get-TemplatePath $Template | Get-FileContent
    
    # Replace placeholders in the template with actual values
    $content = $content -replace '{title}'       , $Title
    $content = $content -replace '{header}'      , $header

    $content = $content -replace '{date}'        , ([string]::IsNullOrWhiteSpace($Date) ? 'NoDate' : "$Date")
    $content = $content -replace '{notes}'       , ([string]::IsNullOrWhiteSpace($Notes)       ? '-' : $Notes)
    $content = $content -replace '{issueurl}'    , ([string]::IsNullOrWhiteSpace($IssueUrl)    ? '<IssueUrl>' : $IssueUrl)

    return $content
}

function New-NoteToday{
    # Add Force parameter to support creation of client folder if it doesn't exist
    [CmdletBinding()]
    [alias("note")]
    param(
        [Parameter(Mandatory,Position = 0)][string] $Category,
        [Parameter(Mandatory,Position = 1)][string] $Title,
        [Parameter()][string] $Section,
        [Parameter()][string] $Notes,
        [Parameter()][string] $IssueUrl,
        [Parameter()][string] [ValidateSet("none","meetingmini")] $Template = "none",
        [Parameter()][switch] $NoOpen,
        [Parameter()][switch] $AddNoteFolder,
        [Parameter()][switch] $Force,
        [Parameter()][string] $RootPath
    )
    $params = @{
        Category      = $Category
        Section       = $Section
        Title         = $Title
        Date          = ""
        Notes         = $Notes
        IssueUrl      = $IssueUrl
        Template      = "none"
        NoOpen        = $NoOpen
        AddNoteFolder = $AddNoteFolder
        Force         = $Force
        RootPath      = $RootPath
        DateToday     = $true
        
    }

    $ret = New-Note @params

    return $ret

} Export-ModuleMember -Function New-NoteToday -Alias "note"

function New-NoteTodayClient{
    [CmdletBinding()]
    [alias("cnote")]
    param(
        [Parameter(Mandatory,Position = 0)][string] $Name,
        [Parameter(Mandatory,Position = 1)][string] $Title,
        [Parameter(Position = 2)][string] $Notes,
        [Parameter(ValueFromPipeline)][string] $IssueUrl,
        [Parameter()][switch] $NoOpen,
        [Parameter()][switch] $Force,
        [Parameter()][string] $RootPath

    )

    $params = @{
        Category      = "Clients"
        Section       = $Name
        Title         = $Title
        Date          = ""
        Notes         = $Notes
        IssueUrl      = $IssueUrl
        Template      = "meetingmini"
        NoOpen        = $NoOpen
        Force         = $Force
        RootPath      = $RootPath
        AddNoteFolder = $false
        DateToday     = $true
    }

    $ret = New-Note @params

    return $ret

} Export-ModuleMember -Function New-NoteTodayClient -Alias cnote

function New-NoteTodayMeeting{
    [CmdletBinding()]
    [alias("mnote")]
    param(
        [Parameter(Mandatory,Position = 0)][string] $Name,
        [Parameter(Mandatory,Position = 1)][string] $Title,
        [Parameter(Position = 2)][string] $Notes,
        [Parameter()][string] $IssueUrl,
        [Parameter()][switch] $NoOpen,
        [Parameter()][switch] $Force,
        [Parameter()][string] $RootPath
    )

    $params = @{
        Category      = "meetings"
        Section       = $Name
        Title         = $Title
        Date          = ""
        Notes         = $Notes
        IssueUrl      = $IssueUrl
        Template      = "meetingmini"
        NoOpen        = $NoOpen
        Force         = $Force
        RootPath      = $RootPath
        AddNoteFolder = $false
        DateToday     = $true
    }

    $ret = New-Note @params

    return $ret

} Export-ModuleMember -Function New-NoteTodayMeeting -Alias mnote

function New-NoteMeetingNext{
    [CmdletBinding()]
    [alias("mnoten")]
    param(
        [Parameter(Mandatory,Position = 0)][string] $Name,
        [Parameter(Position = 1)][string] $Notes,
        [Parameter()][string] $IssueUrl,
        [Parameter()][switch] $NoOpen,
        [Parameter()][switch] $Force,
        [Parameter()][string] $RootPath
    )

    $params = @{
        Category      = "meetings"
        Section       = $Name
        Title         = "Next Meeting Notes"
        Date          = ""
        Notes         = $Notes
        IssueUrl      = $IssueUrl
        Template      = "meetingmini"
        NoOpen        = $NoOpen
        Force         = $Force
        RootPath      = $RootPath
        AddNoteFolder = $false
        DateToday     = $true
    }

    $ret = New-Note @params

    return $ret

} Export-ModuleMember -Function New-NoteMeetingNext -Alias mnoten

function New-NoteQuestion{
    [CmdletBinding()]
    [alias("qnote")]
    param(
        [Parameter(Mandatory,Position = 0)][string] $Name,
        [Parameter(Position = 1)][string] $Title,
        [Parameter(Position = 2)][string] $Notes,
        [Parameter(ValueFromPipeline)][string] $IssueUrl,
        [Parameter()][switch] $NoOpen,
        [Parameter()][switch] $Force,
        [Parameter()][string] $RootPath
    )

    $params = @{
        Category      = "meetings"
        Section       = $Name
        Title         = [string]::IsNullOrWhiteSpace($Title) ? "Question" : "Question - $Title"
        Date          = ""
        Notes         = $Notes
        IssueUrl      = $IssueUrl
        Template      = "meetingmini"
        NoOpen        = $NoOpen
        Force         = $Force
        RootPath      = $RootPath
        AddNoteFolder = $false
        DateToday     = $true
    }

    $ret = New-Note @params

    return $ret

} Export-ModuleMember -Function New-NoteQuestion -Alias qnote

function New-NoteTemp{
    [CmdletBinding()]
    [alias("tnote")]
    param(
        [Parameter(Position = 0)][string] $Name,
        [Parameter(Position = 1)][string] $Title,
        [Parameter(Position = 2)][string] $Notes,
        [Parameter(ValueFromPipeline)][string] $IssueUrl,
        [Parameter()][switch] $NoOpen,
        [Parameter()][switch] $Force,
        [Parameter()][string] $RootPath
    )

    $params = @{
        Category      = "temp"
        Section       = $Name
        Title         = [string]::IsNullOrWhiteSpace($Title) ? "Notes" : "$Title"
        Date          = ""
        Notes         = $Notes
        IssueUrl      = $IssueUrl
        Template      = "none"
        NoOpen        = $NoOpen
        Force         = $Force
        RootPath      = $RootPath
        AddNoteFolder = $false
        DateToday     = $true
    }

    $ret = New-Note @params

    return $ret
} Export-ModuleMember -Function New-NoteTemp -Alias tnote