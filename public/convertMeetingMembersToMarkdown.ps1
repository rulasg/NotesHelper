
function Convert-NotesMeetingMembersToMarkdown {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline)][string]$MeetingMembers
    )

    process {
        if ([string]::IsNullOrWhiteSpace($MeetingMembers)) {
            return ""
        }

        # Parse the comma-separated list, handling quoted names with commas
        # Split on ', ' followed by a quote or a letter (not inside quotes)
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

        # Parse each member
        $parsedMembers = $members | ForEach-Object { parseMemberEmail -MemberString $_ }
        
        # Filter out nulls
        $parsedMembers = $parsedMembers | Where-Object { $null -ne $_ }
        
        if ($parsedMembers.Count -eq 0) {
            return ""
        }

        # Group and format as markdown
        $result = groupMembersByCompany -Members $parsedMembers

        return $result
    }
} Export-ModuleMember -Function 'Convert-NotesMeetingMembersToMarkdown'
