
function groupAttendeesByCompany {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][object[]]$Attendees
    )

    $validAttendees = $Attendees | Where-Object { $null -ne $_ }

    if ($validAttendees.Count -eq 0) {
        return ""
    }

    # Response sort order and emoji indicators per attendance type
    $responseOrder = @{
        'Accepted'       = 1
        'Tentative'      = 2
        'Following'      = 3
        'Declined'       = 4
        "Didn't respond" = 5
    }

    $requiredEmoji = @{
        'Accepted'       = '✅'
        'Tentative'      = '⬜️'
        'Following'      = '👀'
        'Declined'       = '❌'
        "Didn't respond" = '⭕️'
    }

    $optionalEmoji = @{
        'Accepted'       = '✅'
        'Tentative'      = '🟩'
        'Following'      = '👀'
        'Declined'       = '❎'
        "Didn't respond" = '🟩'
    }

    # Group by company, sort companies alphabetically
    $grouped = $validAttendees | Group-Object -Property Company | Sort-Object -Property Name

    $result = @()

    foreach ($companyGroup in $grouped) {
        $memberCount = $companyGroup.Group.Count
        $result += "- $($companyGroup.Name) ($memberCount)"

        # Sort by attendance (Required before Optional), then response order, then name
        $sortedMembers = $companyGroup.Group | Sort-Object -Property @(
            @{ Expression = { if ($_.Attendance -eq 'Required') { 0 } else { 1 } } },
            @{ Expression = { $responseOrder[$_.Response] ?? 99 } },
            @{ Expression = { ($_.DisplayName.Trim('"')).ToLower() } }
        )

        foreach ($member in $sortedMembers) {
            $emojiMap = if ($member.Attendance -eq 'Required') { $requiredEmoji } else { $optionalEmoji }
            $emoji = $emojiMap[$member.Response] ?? '❓'
            $attLetter = if ($member.Attendance -eq 'Required') { 'R' } else { 'O' }
            $result += "    - $emoji$attLetter $($member.OriginalFormat)"
        }
    }

    return ($result -join "`n")
}
