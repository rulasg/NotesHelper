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

    $categoryPath = New-TestingFolder -Path "./TestNotesRoot/$category" -PassThru

    # Add note with folder using -Force
    $path = New-NoteToday $category $title -NoOpen -Force

    $content = Get-Content -Path $path -Raw

    Assert-IsTrue $content.StartsWith($header)

    # File should be in a folder of its own name
    $parentPath = $path | Split-Path -parent
    Assert-AreEqualPath -Expected $categoryPath -Presented $parentPath

}

function Test_AddNotesToday_Simple_AddNoteFolder {

    Reset-InvokeCommandMock

    New-TestingFolder "TestNotesRoot"
    MockCallToString 'Invoke-NotesHelperNotesRoot' -OutString "./TestNotesRoot"

    $category = "TestClient"
    $title = "This is the title of the note"

    New-TestingFolder -Path "./TestNotesRoot/$category"

    # Add folder for the note -AddNoteFolder
    $path = New-NoteToday $category $title -NoOpen -AddNoteFolder

    # File should be in a folder of its own name
    $parentName = $path | Split-Path -Parent | Split-Path -Leaf
    $fileNameBase = $path | Split-Path -LeafBase
    Assert-AreEqual -Expected $fileNameBase -Presented $parentName
    Assert-AreNotEqual -Expected $parentName -Presented $category

    # Parent folder should be child or category folder
    $granParent = $path | Split-Path -Parent | Split-Path -Parent | Split-Path -Leaf
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
    $path = New-NoteToday $category $title -NoOpen -Notes $notes

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

function Test_NewNotes_SUCCESS{

    Reset-InvokeCommandMock

    New-TestingFolder "TestNotesRoot"
    MockCallToString 'Invoke-NotesHelperNotesRoot' -OutString "./TestNotesRoot"

    New-TestingFolder -Path "./TestNotesRoot/howto"
    $today = (Get-Date).ToString("yyMMdd")

    # Act
    $result = New-Note howto "someting that may be useful" -NoOpen

    $expectedPath = "./TestNotesRoot/howto/howto-someting_that_may_be_useful/howto-someting_that_may_be_useful.md"

    Assert-AreEqualPath -Expected $expectedPath -Presented $result

    # With date

    $result = New-Note howto "someting that may be useful" -NoOpen -Date $today

    $expectedPath = "./TestNotesRoot/howto/$today-howto-someting_that_may_be_useful/$today-howto-someting_that_may_be_useful.md"

    Assert-AreEqualPath -Expected $expectedPath -Presented $result

}

function Test_NewNotes_SUCCESS_WithRootPath{

    Reset-InvokeCommandMock

    $RootFolder = "TestNotesRoot"

    New-TestingFolder $RootFolder

    New-TestingFolder -Path "./$RootFolder/howto"
    $today = (Get-Date).ToString("yyMMdd")

    # Act
    $result = New-Note howto "someting that may be useful" -NoOpen -RootPath $RootFolder

    $expectedPath = "./$RootFolder/howto/howto-someting_that_may_be_useful/howto-someting_that_may_be_useful.md"

    Assert-AreEqualPath -Expected $expectedPath -Presented $result

    # With date

    $result = New-Note howto "someting that may be useful" -NoOpen -Date $today -RootPath $RootFolder

    $expectedPath = "./$RootFolder/howto/$today-howto-someting_that_may_be_useful/$today-howto-someting_that_may_be_useful.md"

    Assert-AreEqualPath -Expected $expectedPath -Presented $result

}