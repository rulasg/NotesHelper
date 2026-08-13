function Mock_NotesRoot{

    New-TestingFolder "TestNotesRoot"
    MockCallToString 'Invoke-NotesHelperNotesRoot' -OutString "./TestNotesRoot"

}