function Get-NoteLink {
    [CmdletBinding()]
    param (
        # Local file path to get the GitHub link for
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,Position=0)][Alias("Path")][string] $NotePath
    )

    # Resolve the full path
    $fullPath = Resolve-Path -Path $NotePath -ErrorAction SilentlyContinue
    if (-not $fullPath) {
        Write-Error "Path not found: $NotePath"
        return
    }

    # Get the directory to run git commands from
    $workingDir = if (Test-Path -Path $fullPath -PathType Container) { $fullPath } else { Split-Path -Path $fullPath -Parent }

    # Get the git root directory
    $gitRoot = git -C $workingDir rev-parse --show-toplevel 2>$null
    if (-not $gitRoot) {
        Write-Error "Path is not inside a Git repository: $NotePath"
        return
    }

    # Get the remote origin URL
    $remoteUrl = git -C $gitRoot remote get-url origin 2>$null
    if (-not $remoteUrl) {
        Write-Error "No remote 'origin' found for repository"
        return
    }

    # Parse HTTPS URL format
    # HTTPS format: https://hostname/owner/repo.git
    if ($remoteUrl -match '^https://([^/]+)/(.+?)(?:\.git)?$') {
        $hostName = $matches[1]
        $repoPath = $matches[2] -replace '\.git$', ''
        $baseUrl = "https://$hostName/$repoPath"
    }
    else {
        Write-Error "Unsupported remote URL format: $remoteUrl"
        return
    }

    # Get the current branch
    $branch = git -C $gitRoot rev-parse --abbrev-ref HEAD 2>$null
    if (-not $branch) {
        $branch = "main"
    }

    # Get the relative path from the git root
    $relativePath = $fullPath.Path.Substring($gitRoot.Length).TrimStart('/', '\') -replace '\\', '/'

    # Construct the GitHub URL
    $githubUrl = "$baseUrl/blob/$branch/$relativePath"

    return $githubUrl
} Export-ModuleMember -Function Get-NoteLink

