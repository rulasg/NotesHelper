function Test_GetNoteLink_ReturnsGitHubUrl{

    # Arrange
    $repoRoot = $PSScriptRoot | Split-Path -Parent | Split-Path -Parent
    $notePath = Join-Path $repoRoot "public/getnoteLink.ps1"

    # Act
    $result = Get-NoteLink -NotePath $notePath

    # Assert
    Assert-IsTrue -Condition ([bool]($result -match "^https://github\.com/.+/blob/.+/public/getnoteLink\.ps1$")) -Comment "Should return a valid GitHub URL"
}

function Test_GetNoteLink_NestedPath{

    # Arrange
    $repoRoot = $PSScriptRoot | Split-Path -Parent | Split-Path -Parent
    $notePath = Join-Path $repoRoot "public/notes/templates/getTemplate.ps1"

    # Act
    $result = Get-NoteLink -NotePath $notePath

    # Assert
    Assert-IsTrue -Condition ([bool]($result -match "^https://github\.com/.+/blob/.+/public/notes/templates/getTemplate\.ps1$")) -Comment "Should handle nested paths correctly"
}

function Test_GetNoteLink_InvalidPath{

    # Arrange
    $notePath = "/nonexistent/path/file.ps1"

    # Act
    $result = Get-NoteLink -NotePath $notePath -ErrorAction SilentlyContinue

    # Assert
    Assert-IsNull -Object $result -Comment "Should return null for invalid path"
}

function Test_GetNoteLink_NotInGitRepo{

    # Arrange
    $notePath = "/tmp"

    # Act
    $result = Get-NoteLink -NotePath $notePath -ErrorAction SilentlyContinue

    # Assert
    Assert-IsNull -Object $result -Comment "Should return null when path is not in a Git repository"
}

function Test_GetNoteLink_UsesHostnameFromRemote{

    # Arrange
    $repoRoot = $PSScriptRoot | Split-Path -Parent | Split-Path -Parent
    $notePath = Join-Path $repoRoot "README.md"
    
    # Get the expected hostname from the actual remote (HTTPS format only)
    $remoteUrl = git -C $repoRoot remote get-url origin 2>$null
    if ($remoteUrl -match '^https://([^/]+)/') {
        $expectedHost = $matches[1]
    }

    # Act
    $result = Get-NoteLink -NotePath $notePath

    # Assert
    Assert-IsTrue -Condition ([bool]($result -match "^https://$expectedHost/")) -Comment "Should use hostname from remote URL"
}
