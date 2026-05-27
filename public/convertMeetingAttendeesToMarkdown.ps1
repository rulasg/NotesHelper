
function Convert-NotesMeetingAttendeesToMarkdown {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position = 0, ValueFromPipeline)][string]$MeetingAttendees,
        [Parameter()][switch]$SetClipboard
    )

    process {
        if ([string]::IsNullOrWhiteSpace($MeetingAttendees)) {
            return ""
        }

        # Split by newlines, trim, and filter empty lines
        $lines = $MeetingAttendees -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

        if ($lines.Count -lt 2) {
            return ""
        }

        # Skip header line (Name, Attendance, Response)
        $dataLines = $lines | Select-Object -Skip 1

        # Pattern: Name part (greedy), then Required/Optional, then response text
        # Works with tabs, spaces, or no separator between fields
        $linePattern = '^(.+)(Required|Optional)\s*(.+)\s*$'

        $parsedMembers = @()

        foreach ($line in $dataLines) {
            if ($line -match $linePattern) {
                $memberString = $matches[1].Trim()
                $attendance = $matches[2]
                $response = $matches[3].Trim()

                $member = parseMemberEmail -MemberString $memberString

                if ($null -ne $member) {
                    $member | Add-Member -NotePropertyName 'Attendance' -NotePropertyValue $attendance
                    $member | Add-Member -NotePropertyName 'Response' -NotePropertyValue $response
                    $parsedMembers += $member
                }
            }
        }

        if ($parsedMembers.Count -eq 0) {
            return ""
        }

        # Group by company, sub-group by attendance, sort by response
        $result = groupAttendeesByCompany -Attendees $parsedMembers

        if ($SetClipboard) {
            $result | Set-Clipboard
        } else {
            $result
        }
    }
} Export-ModuleMember -Function 'Convert-NotesMeetingAttendeesToMarkdown'
