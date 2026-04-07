
function Convert-NotesMeetingMembersToMarkdown {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline)][string]$MeetingMembers,
        [Parameter()][switch]$SetClipboard
    )

    process {
        if ([string]::IsNullOrWhiteSpace($MeetingMembers)) {
            return ""
        }

        # Detect format: semicolons = Outlook/Office 365, commas = Google Calendar
        if ($MeetingMembers -match ';') {
            # Outlook/Office 365 format: semicolon-separated
            $members = $MeetingMembers -split '\s*;\s*' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
        } else {
            # Google Calendar format: comma-separated with quote handling
            $members = @()
            $currentMember = ""
            $inQuotes = $false
            
            for ($i = 0; $i -lt $MeetingMembers.Length; $i++) {
                $char = $MeetingMembers[$i]
                
                if ($char -eq '"') {
                    $inQuotes = -not $inQuotes
                    $currentMember += $char
                }
                elseif ($char -eq ',' -and -not $inQuotes) {
                    # End of member
                    if (-not [string]::IsNullOrWhiteSpace($currentMember)) {
                        $members += $currentMember.Trim()
                    }
                    $currentMember = ""
                }
                else {
                    $currentMember += $char
                }
            }
            
            # Add the last member
            if (-not [string]::IsNullOrWhiteSpace($currentMember)) {
                $members += $currentMember.Trim()
            }
        }

        # Parse each member
        $parsedMembers = $members | ForEach-Object { parseMemberEmail -MemberString $_ }
        
        # Filter out nulls
        $parsedMembers = $parsedMembers | Where-Object { $null -ne $_ }
        
        if ($parsedMembers.Count -eq 0) {
            return ""
        }

        # Group and format as markdown
        $result = groupMembersByCompany -Members $parsedMembers

        if ($SetClipboard) {
            $result | Set-Clipboard
        } else {
            $result
        }

    }
} Export-ModuleMember -Function 'Convert-NotesMeetingMembersToMarkdown'
