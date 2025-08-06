function Test_AddNotesToday_Simple{

    Reset-InvokeCommandMock

    New-TestingFolder "TestNotesRoot"
    MockCallToString 'Invoke-NotesHelperNotesRoot' -OutString "./TestNotesRoot"

    $category = "TestClient"
    $title = "This is the title of the note"
    $date = (Get-Date).ToString("yyMMdd")

    $header = "# {category} - {title} ({date})"
    $header = $header -replace "{category}", $category
    $header = $header -replace "{title}", $title
    $header = $header -replace "{date}", $date

    New-TestingFolder -Path "./TestNotesRoot/$category"

    # Add note with folder using -Force
    $path = New-NoteToday $category $title -NoOpen -Force

    $content = Get-Content -Path $path -Raw

    Assert-IsTrue $content.StartsWith($header)

    # File should be in a folder of its own name
    $parentName = $path | Split-Path -Parent | Split-Path -Leaf
    $fileNameBase = $path | Split-Path -LeafBase
    Assert-AreEqual -Expected $fileNameBase -Presented $parentName
    Assert-AreNotEqual -Expected $parentName -Presented $category

    # Parent folder should be child or category folder
    $granParent = $path | Split-Path -Parent | Split-Path -Parent | Split-Path -Leaf
    Assert-AreEqual -Expected $granParent -Presented $category
}

function Test_AddNotesToday_Simple_AvoidChildFolder {

    Reset-InvokeCommandMock

    New-TestingFolder "TestNotesRoot"
    MockCallToString 'Invoke-NotesHelperNotesRoot' -OutString "./TestNotesRoot"

    $category = "TestClient"
    $title = "This is the title of the note"
    $date = (Get-Date).ToString("yyMMdd")

    $header = "# {category} - {title} ({date})"
    $header = $header -replace "{category}", $category
    $header = $header -replace "{title}", $title
    $header = $header -replace "{date}", $date

    New-TestingFolder -Path "./TestNotesRoot/$category"

    # Add note on the same folder using -AvoidChildFolder
    $path = New-NoteToday $category $title -NoOpen -AvoidChildFolder

    $content = Get-Content -Path $path -Raw

    Assert-IsTrue $content.StartsWith($header)

    # Parent folder should be child or category folder
    $granParent = $path | Split-Path -Parent | Split-Path -Leaf
    Assert-AreEqual -Expected $granParent -Presented $category

}

function Test_AddNotesToday_WithContent {

    Reset-InvokeCommandMock

    New-TestingFolder "TestNotesRoot"
    MockCallToString 'Invoke-NotesHelperNotesRoot' -OutString "./TestNotesRoot"

    $category = "TestClient"
    $title = "This is the title of the client note"
    $date = (Get-Date).ToString("yyMMdd")
    $notes = "These are the notes for the client" ; $notesContains ="## Notes`n`n$notes`n"

    $header = "# {category} - {title} ({date})"
    $header = $header -replace "{category}", $category
    $header = $header -replace "{title}", $title
    $header = $header -replace "{date}", $date

    New-TestingFolder -Path "./TestNotesRoot/$category"

    # Check Notes content
    $path = New-NoteToday $category $title -NoOpen -AvoidChildFolder -Notes $notes

    $content = Get-Content -Path $path -Raw

    Assert-IsTrue $content.StartsWith($header)

    Assert-IsTrue $content.Contains($notesContains)

    # Parent folder should be child or category folder
    $granParent = $path | Split-Path -Parent | Split-Path -Leaf
    Assert-AreEqual -Expected $granParent -Presented $category
}

function Test_AddNotesToday_Client_Simple{


    Reset-InvokeCommandMock

    New-TestingFolder "TestNotesRoot"
    MockCallToString 'Invoke-NotesHelperNotesRoot' -OutString "./TestNotesRoot"

    $category = "Clients"
    $clientName = "TestClientName"
    $title = "This is the title of the note"
    $date = (Get-Date).ToString("yyMMdd")

    $clientName = "TestClientName"

    $header = "# {header} - {title} ({date})"
    $header = $header -replace "{header}", $clientName
    $header = $header -replace "{title}", $title
    $header = $header -replace "{date}", $date

    New-TestingFolder -Path "./TestNotesRoot/$category/$clientName"

    # Add note with folder using -Force
    $path = New-NoteTodayClient $clientName $title -NoOpen

    $content = Get-Content -Path $path -Raw

    Assert-IsTrue $content.StartsWith($header)

    # File has to be in the Client name folder
    $parentName = $path | Split-Path -Parent | Split-Path -Leaf
    Assert-AreEqual -Expected $clientName -Presented $parentName

    # Parent folder should be Clients
    $greatParent = $path | Split-Path -Parent | Split-Path -Parent | Split-Path -Leaf
    Assert-AreEqual -Expected "Clients" -Presented $greatParent
}

function Test_NewNotesToday_Failing{

    Reset-InvokeCommandMock

    New-TestingFolder "TestNotesRoot"
    MockCallToString 'Invoke-NotesHelperNotesRoot' -OutString "./TestNotesRoot"

    New-TestingFolder -Path "./TestNotesRoot/howto"
    $today = (Get-Date).ToString("yyMMdd")

    # Act
    $result = note howto "someting that may be useful" -NoOpen

    $expectedPath = "./TestNotesRoot/howto/$today-howto-someting_that_may_be_useful/$today-howto-someting_that_may_be_useful.md"

    Assert-AreEqualPath -Expected $expectedPath -Presented $result
}

# ./TestNotesRoot/howto/250720-howto-someting_that_may_be_useful/250720-howto-someting_that_may_be_useful.md ] 
# ./TestNotesRoot/howto/250728-howto-someting_that_may_be_useful/250728-howto-someting_that_may_be_useful.md ]
# [ /tmp/Posh_Testing_250728_87d8dc/TestRunFolder/Test_NewNotesToday_Failing