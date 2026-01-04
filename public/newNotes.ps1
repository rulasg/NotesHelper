
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
        [Parameter()][switch] $AvoidChildFolder,
        [Parameter()][switch] $Force,
        [Parameter()][string] $RootPath

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

    $fullTitle = getFullTitle -Category $Category -Section $Section -Title $Title -Date $Date

    # Create the note base folder
    if($AvoidChildFolder){
        # use folder as the parent folder of the note
        $fullPath = Join-Path -Path $folder -ChildPath "$fullTitle.md"
    } else {
        # Create full path for the note file
        $noteFolder = Join-Path -Path $folder -ChildPath $fullTitle
        
        if (-not (Test-Path -Path $noteFolder)) {
            New-Item -Path $noteFolder -ItemType Directory -Force | Out-Null
            Write-Verbose "Created note folder: $noteFolder"
        }

        $fullPath =$noteFolder | Join-Path -ChildPath "$fullTitle.md"
    }
    
    # Check if file already exists
    if (-Not (Test-Path -Path $fullPath)) {

        $header = [string]::IsNullOrWhiteSpace($Section) ? $Category : $Section

        $content = getFileContent $Template $Title $header -Notes $Notes -IssueUrl $IssueUrl

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

function getFullTitle{
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
    $content = $content -replace '{date}'        , $Date
    $content = $content -replace '{notes}'       , ([string]::IsNullOrWhiteSpace($Notes)       ? '-' : $Notes)
    $content = $content -replace '{issueurl}'    , ([string]::IsNullOrWhiteSpace($IssueUrl)    ? '<IssueUrl>' : $IssueUrl)

    return $content
}

function New-NoteToday{
    # Add Force parameter to support creation of client folder if it doesn't exist
    [CmdletBinding()]
    [alias("note")]
    param(
        [Parameter(Mandatory,Position = 0)][string] $Title,
        [Parameter()][string] $Category = "Notes",
        [Parameter()][string] $Section,
        [Parameter()][string] $Notes,
        [Parameter()][string] $IssueUrl,
        [Parameter()][string] [ValidateSet("none","meetingmini")] $Template = "none",
        [Parameter()][switch] $NoOpen,
        [Parameter()][switch] $AvoidChildFolder,
        [Parameter()][switch] $Force,
        [Parameter()][string] $RootPath
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

    # Extract just the folder name from the path
    $today = Get-Date -Format "yyMMdd"

    $header = [string]::IsNullOrWhiteSpace($Section) ? $Category : $Section
    
    # Create FullTitle using folder name and title, replacing spaces with underscores
    $fullTitle = "{0}-{1}-{2}" -f $today, $header, $Title

    # Normilize fullTitle by removing special characters and replacing spaces with underscores
    $fullTitle = $fullTitle -replace '\s+', '_'

    # Create the note base folder

    if($AvoidChildFolder){
        # use folder as the parent folder of the note
        $fullPath = Join-Path -Path $folder -ChildPath "$fullTitle.md"
    } else {
        # Create full path for the note file
        $noteFolder = Join-Path -Path $folder -ChildPath $fullTitle
        
        if (-not (Test-Path -Path $noteFolder)) {
            New-Item -Path $noteFolder -ItemType Directory -Force | Out-Null
            Write-Verbose "Created note folder: $noteFolder"
        }

        $fullPath =$noteFolder | Join-Path -ChildPath "$fullTitle.md"
    }
    
    # Check if file already exists
    if (-Not (Test-Path -Path $fullPath)) {
        
        # Get template content
        $content = Get-TemplatePath $Template | Get-FileContent
        
        # Replace placeholders in the template with actual values
        $content = $content -replace '{title}'       , $Title
        $content = $content -replace '{header}'      , $header
        $content = $content -replace '{date}'        , $today
        $content = $content -replace '{notes}'       , ([string]::IsNullOrWhiteSpace($Notes)       ? '-' : $Notes)
        $content = $content -replace '{issueurl}'    , ([string]::IsNullOrWhiteSpace($IssueUrl)    ? '<IssueUrl>' : $IssueUrl)


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
        [Parameter()][switch] $Force
    )

    begin {
        $category = "Clients"
        $section = $Name
    }

    process{

        $folder = Get-NoteFolder -Category $category -Section $section -Force:$Force

        if (-not $folder) {
            Write-Error "Client folder for '$section' does not exist and Force was not specified."
            return
        }

        New-NoteToday `
            -Category $category `
            -Section $section `
            -Title $Title `
            -Notes $Notes `
            -IssueUrl $IssueUrl `
            -Template "meetingmini" `
            -NoOpen:$NoOpen `
            -AvoidChildFolder # Add all the notes in the same client folder
    }

} Export-ModuleMember -Function New-NoteTodayClient -Alias cnote

function New-NoteTodayMeeting{
    [CmdletBinding()]
    [alias("mnote")]
    param(
        [Parameter(Mandatory,Position = 0)][string] $Name,
        [Parameter(Mandatory,Position = 1)][string] $Title,
        [Parameter(Position = 2)][string] $Notes,
        [Parameter(ValueFromPipeline)][string] $IssueUrl,
        [Parameter()][switch] $NoOpen,
        [Parameter()][switch] $Force,
        [Parameter()][string] $RootPath
    )

    begin {
        $category = "meetings"
        $section = $Name
    }

    process{

        $folder = Get-NoteFolder -RootPath $RootPath -Category $category -Section $section -Force:$Force

        if (-not $folder) {
            Write-Error "Client folder for '$section' does not exist and Force was not specified."
            return
        }

        New-NoteToday `
            -Category $category `
            -Section $section `
            -Title $Title `
            -Notes $Notes `
            -IssueUrl $IssueUrl `
            -Template "meetingmini" `
            -NoOpen:$NoOpen `
            -AvoidChildFolder # Add all the notes in the same client folder
    }

} Export-ModuleMember -Function New-NoteTodayMeeting -Alias mnote