
function Test_ConvertMeetingAttendeesToMarkdown_HeaderOnly {

    # Arrange
    $input = "Name`tAttendance`tResponse"

    # Act
    $result = Convert-NotesMeetingAttendeesToMarkdown -MeetingAttendees $input

    # Assert
    Assert-AreEqual -Expected "" -Presented $result -Comment "Header-only input should return empty string"
}

function Test_ConvertMeetingAttendeesToMarkdown_SingleAttendee {

    # Arrange
    $input = @"
Name`tAttendance`tResponse
André Müller <amuller@devtools.com>`tRequired`tAccepted
"@

    # Act
    $result = Convert-NotesMeetingAttendeesToMarkdown -MeetingAttendees $input

    # Assert
    $expected = @'
- Devtools (1)
    - ✅R André Müller <amuller@devtools.com>
'@
    Assert-AreEqual -Expected $expected -Presented $result -Comment "Single attendee should include attendance and response"
}

function Test_ConvertMeetingAttendeesToMarkdown_MultipleCompanies {

    # Arrange
    $input = @"
Name`tAttendance`tResponse
Alice Johnson <alice@alphatech.com>`tRequired`tAccepted
Bob Smith <bob@betasoft.com>`tOptional`tDeclined
Charlie Chen <charlie@alphatech.com>`tOptional`tAccepted
"@

    # Act
    $result = Convert-NotesMeetingAttendeesToMarkdown -MeetingAttendees $input

    # Assert
    $expected = @'
- Alphatech (2)
    - ✅R Alice Johnson <alice@alphatech.com>
    - ✅O Charlie Chen <charlie@alphatech.com>
- Betasoft (1)
    - ❎O Bob Smith <bob@betasoft.com>
'@
    Assert-AreEqual -Expected $expected -Presented $result -Comment "Multiple companies should be sorted with attendance info"
}

function Test_ConvertMeetingAttendeesToMarkdown_AllCapsConversion {

    # Arrange
    $input = @"
Name`tAttendance`tResponse
ALICE JOHNSON <alice@alphatech.com>`tRequired`tAccepted
BOB SMITH <bob@betasoft.com>`tOptional`tAccepted
"@

    # Act
    $result = Convert-NotesMeetingAttendeesToMarkdown -MeetingAttendees $input

    # Assert
    $expected = @'
- Alphatech (1)
    - ✅R Alice Johnson <alice@alphatech.com>
- Betasoft (1)
    - ✅O Bob Smith <bob@betasoft.com>
'@
    Assert-AreEqual -Expected $expected -Presented $result -Comment "ALL CAPS names should be converted to title case"
}

function Test_ConvertMeetingAttendeesToMarkdown_EmailOnlyFormat {

    # Arrange
    $input = @"
Name`tAttendance`tResponse
john.davis@acmecorp.com <john.davis@acmecorp.com>`tRequired`tAccepted
"@

    # Act
    $result = Convert-NotesMeetingAttendeesToMarkdown -MeetingAttendees $input

    # Assert
    $expected = @'
- Acmecorp (1)
    - ✅R john.davis@acmecorp.com
'@
    Assert-AreEqual -Expected $expected -Presented $result -Comment "Email-only format should show email with attendance info"
}

function Test_ConvertMeetingAttendeesToMarkdown_SpaceSeparated {

    # Arrange
    $input = @"
Name Attendance Response
Alice Johnson <alice@alphatech.com> Required Accepted
Bob Smith <bob@betasoft.com> Optional Declined
"@

    # Act
    $result = Convert-NotesMeetingAttendeesToMarkdown -MeetingAttendees $input

    # Assert
    $expected = @'
- Alphatech (1)
    - ✅R Alice Johnson <alice@alphatech.com>
- Betasoft (1)
    - ❎O Bob Smith <bob@betasoft.com>
'@
    Assert-AreEqual -Expected $expected -Presented $result -Comment "Space-separated fields should be parsed correctly"
}

function Test_ConvertMeetingAttendeesToMarkdown_NoSeparator {

    # Arrange
    $input = @"
NameAttendanceResponse
Alice Johnson <alice@alphatech.com>RequiredAccepted
Bob Smith <bob@betasoft.com>OptionalDeclined
"@

    # Act
    $result = Convert-NotesMeetingAttendeesToMarkdown -MeetingAttendees $input

    # Assert
    $expected = @'
- Alphatech (1)
    - ✅R Alice Johnson <alice@alphatech.com>
- Betasoft (1)
    - ❎O Bob Smith <bob@betasoft.com>
'@
    Assert-AreEqual -Expected $expected -Presented $result -Comment "Concatenated fields with no separator should be parsed correctly"
}

function Test_ConvertMeetingAttendeesToMarkdown_BigSample {

    # Arrange
    $input = @"
Name`tAttendance`tResponse
André Müller <amuller@devtools.com>`tRequired`tAccepted
john.davis@acmecorp.com <john.davis@acmecorp.com>`tRequired`tAccepted
EMMA WATSON CLARK <emma.watson@acmecorp.com>`tRequired`tAccepted
Grace Kim <gracekim@cloudtech.com>`tOptional`tAccepted
Helen de la Cruz Torres <helendc@cloudtech.com>`tOptional`tAccepted
FRANK MILLER THOMPSON <frank.miller.thompson@acmecorp.com>`tOptional`tAccepted
David Parker Lane <dparker@cloudtech.com>`tOptional`tFollowing
LAURA CHEN WANG <laura.chen@acmecorp.com>`tOptional`tDeclined
Mark Stevens (External Consulting LLC) <m-stevens@devtools.com>`tRequired`tDidn't respond
Nathan Brooks Wilson <Nathan.Brooks@cloudtech.com>`tOptional`tDidn't respond
PETER JONES GARCIA <p.jones@acmecorp.com>`tOptional`tDidn't respond
SARAH TAYLOR RODRIGUEZ <staylor@acmecorp.com>`tOptional`tDidn't respond
René Dubois Martín <rdubois@cloudtech.com>`tOptional`tDidn't respond
"@

    # Act
    $result = Convert-NotesMeetingAttendeesToMarkdown -MeetingAttendees $input

    # Assert
    $expected = @'
- Acmecorp (6)
    - ✅R Emma Watson Clark <emma.watson@acmecorp.com>
    - ✅R john.davis@acmecorp.com
    - ✅O Frank Miller Thompson <frank.miller.thompson@acmecorp.com>
    - ❎O Laura Chen Wang <laura.chen@acmecorp.com>
    - 🟩O Peter Jones Garcia <p.jones@acmecorp.com>
    - 🟩O Sarah Taylor Rodriguez <staylor@acmecorp.com>
- Cloudtech (5)
    - ✅O Grace Kim <gracekim@cloudtech.com>
    - ✅O Helen de la Cruz Torres <helendc@cloudtech.com>
    - 👀O David Parker Lane <dparker@cloudtech.com>
    - 🟩O Nathan Brooks Wilson <Nathan.Brooks@cloudtech.com>
    - 🟩O René Dubois Martín <rdubois@cloudtech.com>
- Devtools (2)
    - ✅R André Müller <amuller@devtools.com>
    - ⭕️R Mark Stevens (External Consulting LLC) <m-stevens@devtools.com>
'@
    Assert-AreEqual -Expected $expected -Presented $result -Comment "Big sample should match expected output with attendance and RSVP"
}
