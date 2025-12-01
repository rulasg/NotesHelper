$TESTED_MODULE_PATH = $PSScriptRoot | split-path -Parent | split-path -Parent

function Test_ConvertMeetingMembersToMarkdown_SingleCompany {

    # Arrange
    $testedModulePath = $TESTED_MODULE_PATH | Join-Path -ChildPath "NotesHelper.psd1"
    $testedModule = Import-Module -Name $testedModulePath -Force -PassThru

    $input = "Gisela Torres <0gis0@github.com>, `"David (GitHub) Losert`" <davelosert@github.com>"

    # Act
    $result = & $testedModule {
        param($input)
        Convert-MeetingMembersToMarkdown -MeetingMembers $input
    } -args $input

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
    $testedModulePath = $TESTED_MODULE_PATH | Join-Path -ChildPath "NotesHelper.psd1"
    $testedModule = Import-Module -Name $testedModulePath -Force -PassThru

    $input = "Gisela Torres <0gis0@github.com>, `"David (GitHub) Losert`" <davelosert@github.com>, Gisela Torres <giselat@microsoft.com>, `"Martin Fernandez, Borja`" <mfborj5@mapfre.com>, `"Jovanovic Obradovic, Mat`" <mjovanovic@mapfre.com>, `"Molina Merchan, Jesus`" <mmjesu6@mapfre.com>"

    # Act
    $result = & $testedModule {
        param($input)
        Convert-MeetingMembersToMarkdown -MeetingMembers $input
    } -args $input

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

    # Arrange
    $testedModulePath = $TESTED_MODULE_PATH | Join-Path -ChildPath "NotesHelper.psd1"
    $testedModule = Import-Module -Name $testedModulePath -Force -PassThru

    $input = "Gisela Torres <0gis0@github.com>, Gisela Torres <giselat@microsoft.com>"

    # Act
    $result = & $testedModule {
        param($input)
        Convert-MeetingMembersToMarkdown -MeetingMembers $input
    } -args $input

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
    $testedModulePath = $TESTED_MODULE_PATH | Join-Path -ChildPath "NotesHelper.psd1"
    $testedModule = Import-Module -Name $testedModulePath -Force -PassThru

    $input = "`"David (GitHub) Losert`" <davelosert@github.com>, `"Martin Fernandez, Borja`" <mfborj5@mapfre.com>"

    # Act
    $result = & $testedModule {
        param($input)
        Convert-MeetingMembersToMarkdown -MeetingMembers $input
    } -args $input

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
    $testedModulePath = $TESTED_MODULE_PATH | Join-Path -ChildPath "NotesHelper.psd1"
    $testedModule = Import-Module -Name $testedModulePath -Force -PassThru

    $input = ""

    # Act
    $result = & $testedModule {
        param($input)
        Convert-MeetingMembersToMarkdown -MeetingMembers $input
    } -args $input

    # Assert
    Assert-AreEqual -Expected "" -Presented $result -Comment "Empty input should return empty string"
}

function Test_ConvertMeetingMembersToMarkdown_WhitespaceOnlyInput {

    # Arrange
    $testedModulePath = $TESTED_MODULE_PATH | Join-Path -ChildPath "NotesHelper.psd1"
    $testedModule = Import-Module -Name $testedModulePath -Force -PassThru

    $input = "   "

    # Act
    $result = & $testedModule {
        param($input)
        Convert-MeetingMembersToMarkdown -MeetingMembers $input
    } -args $input

    # Assert
    Assert-AreEqual -Expected "" -Presented $result -Comment "Whitespace-only input should return empty string"
}

function Test_ConvertMeetingMembersToMarkdown_SingleMember {

    # Arrange
    $testedModulePath = $TESTED_MODULE_PATH | Join-Path -ChildPath "NotesHelper.psd1"
    $testedModule = Import-Module -Name $testedModulePath -Force -PassThru

    $input = "John Doe <john.doe@example.com>"

    # Act
    $result = & $testedModule {
        param($input)
        Convert-MeetingMembersToMarkdown -MeetingMembers $input
    } -args $input

    # Assert
    $expected = @"
- Example
    - John Doe <john.doe@example.com>
"@
    Assert-AreEqual -Expected $expected -Presented $result -Comment "Single member should work correctly"
}

Export-ModuleMember -Function Test_*
