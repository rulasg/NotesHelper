function Test_ConvertMeetingMembersToMarkdown_SingleCompany {

    # Arrange
    $input = "Gisela Torres <0gis0@github.com>, `"David (GitHub) Losert`" <davelosert@github.com>"

    # Act
    $result = Convert-MeetingMembersToMarkdown -MeetingMembers $input

    # Assert
    $expected = @"
- Github
    - Gisela Torres <0gis0@github.com>
    - "David (GitHub) Losert" <davelosert@github.com>
"@
    Assert-AreEqual -Expected $expected -Presented $result -Comment "Single company output should match expected format"
}

function Test_ConvertMeetingMembersToMarkdown_MultipleCompanies {

    # Arrange
    $input = "Gisela Torres <0gis0@github.com>, `"David (GitHub) Losert`" <davelosert@github.com>, Gisela Torres <giselat@microsoft.com>, `"Martin Fernandez, Borja`" <mfborj5@mapfre.com>, `"Jovanovic Obradovic, Mat`" <mjovanovic@mapfre.com>, `"Molina Merchan, Jesus`" <mmjesu6@mapfre.com>"

    # Act
    $result = Convert-MeetingMembersToMarkdown -MeetingMembers $input

    # Assert
    $expected = @"
- Github
    - Gisela Torres <0gis0@github.com>
    - "David (GitHub) Losert" <davelosert@github.com>
- Mapfre
    - "Martin Fernandez, Borja" <mfborj5@mapfre.com>
    - "Jovanovic Obradovic, Mat" <mjovanovic@mapfre.com>
    - "Molina Merchan, Jesus" <mmjesu6@mapfre.com>
- Microsoft
    - Gisela Torres <giselat@microsoft.com>
"@
    Assert-AreEqual -Expected $expected -Presented $result -Comment "Multiple companies should be sorted alphabetically"
}

function Test_ConvertMeetingMembersToMarkdown_DuplicateMemberDifferentCompanies {


    $input = "Gisela Torres <0gis0@github.com>, Gisela Torres <giselat@microsoft.com>"


    $result = Convert-MeetingMembersToMarkdown -MeetingMembers $input


    # Assert
    # Same person with different emails should appear in both company groups
    $expected = @"
- Github
    - Gisela Torres <0gis0@github.com>
- Microsoft
    - Gisela Torres <giselat@microsoft.com>
"@
    Assert-AreEqual -Expected $expected -Presented $result -Comment "Same person with different emails should appear in both companies"
}

function Test_ConvertMeetingMembersToMarkdown_SpecialCharactersInName {

    # Arrange
    $input = "`"David (GitHub) Losert`" <davelosert@github.com>, `"Martin Fernandez, Borja`" <mfborj5@mapfre.com>"

    # Act
    $result = Convert-MeetingMembersToMarkdown -MeetingMembers $input

    # Assert
    # Names with special characters (parentheses, commas) should be preserved
    $expected = @"
- Github
    - "David (GitHub) Losert" <davelosert@github.com>
- Mapfre
    - "Martin Fernandez, Borja" <mfborj5@mapfre.com>
"@
    Assert-AreEqual -Expected $expected -Presented $result -Comment "Names with special characters should be preserved"
}

function Test_ConvertMeetingMembersToMarkdown_EmptyInput {

    # Arrange
    $input = ""

    # Act
    $result = Convert-MeetingMembersToMarkdown -MeetingMembers $input

    # Assert
    Assert-AreEqual -Expected "" -Presented $result -Comment "Empty input should return empty string"
}

function Test_ConvertMeetingMembersToMarkdown_WhitespaceOnlyInput {

    # Arrange
    $input = "   "

    # Act
    $result = Convert-MeetingMembersToMarkdown -MeetingMembers $input

    # Assert
    Assert-AreEqual -Expected "" -Presented $result -Comment "Whitespace-only input should return empty string"
}

function Test_ConvertMeetingMembersToMarkdown_SingleMember {

    # Arrange
    $input = "John Doe <john.doe@example.com>"

    # Act
    $result = Convert-MeetingMembersToMarkdown -MeetingMembers $input

    # Assert
    $expected = @"
- Example
    - John Doe <john.doe@example.com>
"@
    Assert-AreEqual -Expected $expected -Presented $result -Comment "Single member should work correctly"
}