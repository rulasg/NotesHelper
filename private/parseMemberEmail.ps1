
function parseMemberEmail {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)][string]$MemberString
    )

    process {
        $memberString = $MemberString.Trim()
        
        if ([string]::IsNullOrWhiteSpace($memberString)) {
            return $null
        }

        # Pattern: "Name" <email@domain.com> or Name <email@domain.com>
        # The display name may contain quotes, commas, parentheses
        $pattern = '^(.+?)\s*<([^>]+)>$'
        
        if ($memberString -match $pattern) {
            $displayName = $matches[1].Trim()
            $email = $matches[2].Trim()
            
            # Filter out resource/room calendar entries
            if ($email -match '@resource\.calendar\.google\.com$') {
                return $null
            }
            
            # Extract domain from email
            $domain = ($email -split '@')[1]
            if ($domain) {
                # Get company name from domain (first part before any dots)
                $company = ($domain -split '\.')[0]
                # Capitalize first letter if company has content
                if ($company.Length -gt 0) {
                    $company = $company.Substring(0, 1).ToUpper() + $company.Substring(1).ToLower()
                }
                else {
                    $company = "Unknown"
                }
            }
            else {
                $company = "Unknown"
            }

            # If display name equals email (Outlook pattern), treat as email-only
            if ($displayName -ieq $email) {
                return [PSCustomObject]@{
                    DisplayName    = $email
                    Email          = $email
                    Company        = $company
                    OriginalFormat = $email
                }
            }
            
            # Convert ALL CAPS names to Title Case
            $originalFormat = $memberString
            $lettersOnly = $displayName -replace '[^a-zA-ZÀ-ÿ]', ''
            if ($lettersOnly.Length -gt 1 -and $lettersOnly -ceq $lettersOnly.ToUpper()) {
                $displayName = (Get-Culture).TextInfo.ToTitleCase($displayName.ToLower())
                $originalFormat = "$displayName <$email>"
            }

            return [PSCustomObject]@{
                DisplayName    = $displayName
                Email          = $email
                Company        = $company
                OriginalFormat = $originalFormat
            }
        }
        
        # Pattern: just an email address (email@domain.com)
        $emailPattern = '^([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})$'
        
        if ($memberString -match $emailPattern) {
            $email = $memberString
            
            # Extract domain from email
            $domain = ($email -split '@')[1]
            if ($domain) {
                # Get company name from domain (first part before any dots)
                $company = ($domain -split '\.')[0]
                # Capitalize first letter if company has content
                if ($company.Length -gt 0) {
                    $company = $company.Substring(0, 1).ToUpper() + $company.Substring(1).ToLower()
                }
                else {
                    $company = "Unknown"
                }
            }
            else {
                $company = "Unknown"
            }

            return [PSCustomObject]@{
                DisplayName    = $email
                Email          = $email
                Company        = $company
                OriginalFormat = $memberString
            }
        }
        
        return $null
    }
}

function groupMembersByCompany {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][object[]]$Members
    )

    # Filter out null members
    $validMembers = $Members | Where-Object { $null -ne $_ }
    
    if ($validMembers.Count -eq 0) {
        return ""
    }

    # Group by company and sort by company name
    $grouped = $validMembers | Group-Object -Property Company | Sort-Object -Property Name

    $result = @()
    
    foreach ($group in $grouped) {
        # Add company header with member count
        $memberCount = $group.Group.Count
        $result += "- $($group.Name) ($memberCount)"
        
        # Add members with 4-space indentation, sorted case-insensitively by DisplayName (without quotes)
        $sortedMembers = $group.Group | Sort-Object -Property { ($_.DisplayName.Trim('"')).ToLower() }
        foreach ($member in $sortedMembers) {
            $result += "    - $($member.OriginalFormat)"
        }
    }

    return ($result -join "`n")
}
