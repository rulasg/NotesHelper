function Test_ConvertMeetingMembersToMarkdown_SingleCompany {

    # Arrange
    $input = "Alice Johnson <alice.johnson@alphatech.com>, `"Bob Smith (AlphaTech)`" <bob.smith@alphatech.com>"

    # Act
    $result = Convert-NotesMeetingMembersToMarkdown -MeetingMembers $input

    # Assert
    $expected = @"
- Alphatech (2)
    - Alice Johnson <alice.johnson@alphatech.com>
    - "Bob Smith (AlphaTech)" <bob.smith@alphatech.com>
"@
    Assert-AreEqual -Expected $expected -Presented $result -Comment "Single company output should match expected format"
}

function Test_ConvertMeetingMembersToMarkdown_MultipleCompanies {

    # Arrange
    $input = "Alice Johnson <alice.johnson@alphatech.com>, `"Bob Smith (AlphaTech)`" <bob.smith@alphatech.com>, Alice Johnson <alice.johnson@betasoft.com>, `"Charlie Brown, David`" <charlie.brown@gammatech.com>, `"Emma Wilson, Frank`" <emma.wilson@gammatech.com>, `"Grace Lee, Henry`" <grace.lee@gammatech.com>"

    # Act
    $result = Convert-NotesMeetingMembersToMarkdown -MeetingMembers $input

    # Assert
    $expected = @"
- Alphatech (2)
    - Alice Johnson <alice.johnson@alphatech.com>
    - "Bob Smith (AlphaTech)" <bob.smith@alphatech.com>
- Betasoft (1)
    - Alice Johnson <alice.johnson@betasoft.com>
- Gammatech (3)
    - "Charlie Brown, David" <charlie.brown@gammatech.com>
    - "Emma Wilson, Frank" <emma.wilson@gammatech.com>
    - "Grace Lee, Henry" <grace.lee@gammatech.com>
"@
    Assert-AreEqual -Expected $expected -Presented $result -Comment "Multiple companies should be sorted alphabetically"
}

function Test_ConvertMeetingMembersToMarkdown_DuplicateMemberDifferentCompanies {

    # Arrange
    $input = "Alice Johnson <alice.johnson@alphatech.com>, Alice Johnson <alice.johnson@betasoft.com>"

    # Act
    $result = Convert-NotesMeetingMembersToMarkdown -MeetingMembers $input

    # Assert
    # Same person with different emails should appear in both company groups
    $expected = @"
- Alphatech (1)
    - Alice Johnson <alice.johnson@alphatech.com>
- Betasoft (1)
    - Alice Johnson <alice.johnson@betasoft.com>
"@
    Assert-AreEqual -Expected $expected -Presented $result -Comment "Same person with different emails should appear in both companies"
}

function Test_ConvertMeetingMembersToMarkdown_SpecialCharactersInName {

    # Arrange
    $input = "`"Bob Smith (AlphaTech)`" <bob.smith@alphatech.com>, `"Charlie Brown, David`" <charlie.brown@gammatech.com>"

    # Act
    $result = Convert-NotesMeetingMembersToMarkdown -MeetingMembers $input

    # Assert
    # Names with special characters (parentheses, commas) should be preserved
    $expected = @"
- Alphatech (1)
    - "Bob Smith (AlphaTech)" <bob.smith@alphatech.com>
- Gammatech (1)
    - "Charlie Brown, David" <charlie.brown@gammatech.com>
"@
    Assert-AreEqual -Expected $expected -Presented $result -Comment "Names with special characters should be preserved"
}

function Test_ConvertMeetingMembersToMarkdown_EmptyInput {

    # Arrange
    $input = ""

    # Act
    $result = Convert-NotesMeetingMembersToMarkdown -MeetingMembers $input

    # Assert
    Assert-AreEqual -Expected "" -Presented $result -Comment "Empty input should return empty string"
}

function Test_ConvertMeetingMembersToMarkdown_WhitespaceOnlyInput {

    # Arrange
    $input = "   "

    # Act
    $result = Convert-NotesMeetingMembersToMarkdown -MeetingMembers $input

    # Assert
    Assert-AreEqual -Expected "" -Presented $result -Comment "Whitespace-only input should return empty string"
}

function Test_ConvertMeetingMembersToMarkdown_SingleMember {

    # Arrange
    $input = "John Doe <john.doe@example.com>"

    # Act
    $result = Convert-NotesMeetingMembersToMarkdown -MeetingMembers $input

    # Assert
    $expected = @"
- Example (1)
    - John Doe <john.doe@example.com>
"@
    Assert-AreEqual -Expected $expected -Presented $result -Comment "Single member should work correctly"
}

function Test_ConvertMeetingsMembersToMarkdown_Big_sample{

    $imput = @"
"Alice Anderson" <alice.anderson@deltalab.com>, "Amy Adams (She/Her)" <amy.adams@betasoft.com>, "Bob Brown" <bob.brown@betasoft.com>, "Charlie Chen" <charlie.chen@betasoft.com>, david.davis@betasoft.com, "David Dennis" <david.dennis@betasoft.com>, "Emma Evans, Eric" <emma.evans@deltalab.com>, emma.edwards@betasoft.com, "Frank Fields, Fiona" <frank.fields@deltalab.com>, george.garcia@bookings.betasoft.com, george.garcia@betasoft.com, "Grace (AlphaTech) Garcia" <grace.garcia@alphatech.com>, "Henry Harris" <henry.harris@alphatech.com>, "Iris Ingram" <iris.ingram@betasoft.com>, "Jack Johnson" <jack.johnson@betasoft.com>, "James Jackson" <james.jackson@betasoft.com>, "Jennifer Jones" <jennifer.jones@betasoft.com>, "Kevin Kim" <kevin.kim@alphatech.com>, "Kyle Knight" <kyle.knight@betasoft.com>, lisa.lee@betasoft.com, "Laura Lewis" <laura.lewis@alphatech.com>, "Mark Martinez" <mark.martinez@alphatech.com>
"@

    $result = Convert-NotesMeetingMembersToMarkdown -MeetingMembers $imput

    Assert-AreEqual -Presented $result -Expected @"
- Alphatech (5)
    - "Grace (AlphaTech) Garcia" <grace.garcia@alphatech.com>
    - "Henry Harris" <henry.harris@alphatech.com>
    - "Kevin Kim" <kevin.kim@alphatech.com>
    - "Laura Lewis" <laura.lewis@alphatech.com>
    - "Mark Martinez" <mark.martinez@alphatech.com>
- Betasoft (9)
    - "Amy Adams (She/Her)" <amy.adams@betasoft.com>
    - "Bob Brown" <bob.brown@betasoft.com>
    - "Charlie Chen" <charlie.chen@betasoft.com>
    - "David Dennis" <david.dennis@betasoft.com>
    - "Iris Ingram" <iris.ingram@betasoft.com>
    - "Jack Johnson" <jack.johnson@betasoft.com>
    - "James Jackson" <james.jackson@betasoft.com>
    - "Jennifer Jones" <jennifer.jones@betasoft.com>
    - "Kyle Knight" <kyle.knight@betasoft.com>
- Deltalab (3)
    - "Alice Anderson" <alice.anderson@deltalab.com>
    - "Emma Evans, Eric" <emma.evans@deltalab.com>
    - "Frank Fields, Fiona" <frank.fields@deltalab.com>
"@
}