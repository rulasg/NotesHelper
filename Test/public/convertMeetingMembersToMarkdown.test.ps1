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

function Test_ConvertMeetingsMembersToMarkdown_Big_sample{

    $imput = @"
"Angulo, Amparo" <amparo.angulo@accenture.com>, "Ana González Talaván (She/Her)" <anamg@microsoft.com>, David Mangas Nuñez <dmangas@microsoft.com>, Felipe Tomazini <ftomazini@microsoft.com>, janet.amezcua@microsoft.com, Jose Luis De la Cruz Moreno <joseld@microsoft.com>, "Mora Alonso, Juan Antonio" <juan.a.mora@accenture.com>, juan.olivera@microsoft.com, "Vilanova Arnal, Juan" <juan.vilanova.arnal@accenture.com>, miguelselman1@bookings.microsoft.com, miguelselman@microsoft.com, "Oana (GitHub) Dinca" <oanamariadinca@github.com>, Oscar Muller <oscarmuller@github.com>, Pilar Blasco <pilarblasco@microsoft.com>, Ramiro Gómez de la Cruz <ramiro.gomez@microsoft.com>, Ricardo Sastre Martín <ricardosa@microsoft.com>, Roberto Arocha <roberto.arocha@microsoft.com>, Ryan Drewery <ryandrewery@github.com>, Sergio Gallego Martinez <sergio.gallego@microsoft.com>, silviahe@microsoft.com, Stéphane Biermann <stephanebiermann@github.com>, Tim Guibert <timguibert@github.com>
"@

    $result = Convert-MeetingMembersToMarkdown -MeetingMembers $imput

    Assert-AreEqual -Presented $result -Expected @"
- Accenture
    - "Angulo, Amparo" <amparo.angulo@accenture.com>
    - "Mora Alonso, Juan Antonio" <juan.a.mora@accenture.com>
    - "Vilanova Arnal, Juan" <juan.vilanova.arnal@accenture.com>
- Github
    - "Oana (GitHub) Dinca" <oanamariadinca@github.com>
    - Oscar Muller <oscarmuller@github.com>
    - Ryan Drewery <ryandrewery@github.com>
    - Stéphane Biermann <stephanebiermann@github.com>
    - Tim Guibert <timguibert@github.com>
- Microsoft
    - "Ana González Talaván (She/Her)" <anamg@microsoft.com>
    - David Mangas Nuñez <dmangas@microsoft.com>
    - Felipe Tomazini <ftomazini@microsoft.com>
    - Jose Luis De la Cruz Moreno <joseld@microsoft.com>
    - Pilar Blasco <pilarblasco@microsoft.com>
    - Ramiro Gómez de la Cruz <ramiro.gomez@microsoft.com>
    - Ricardo Sastre Martín <ricardosa@microsoft.com>
    - Roberto Arocha <roberto.arocha@microsoft.com>
    - Sergio Gallego Martinez <sergio.gallego@microsoft.com>
"@
}