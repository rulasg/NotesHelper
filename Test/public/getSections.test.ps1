
function Test_GetCategories{

    # Arrange
    Mock_NotesRoot

    # Act empty
    $result = Get-NotesCategories

    # Assert
    Assert-Count -Expected 0 -Presented $result

    # Arrange
    New-testingFolder "TestNotesRoot/clients"
    New-testingFolder "TestNotesRoot/projects"
    New-testingFolder "TestNotesRoot/meetings"

    # Act
    $result = Get-NotesCategories

    # Assert
    Assert-Count -Expected 3 -Presented $result
    Assert-Contains -Expected "clients" -Presented $result
    Assert-Contains -Expected "projects" -Presented $result
    Assert-Contains -Expected "meetings" -Presented $result
}

function Test_GetSections_CatNotExist {

    $catname = "kkcat"

    # Arrange
    Mock_NotesRoot

    # Act 
    $result = Get-NotesSections -Category $catname

    # Assert
    Assert-IsNull $result
}

function Test_GetSections_CatExist_Empty {

    $catname = "kkcat"

    # Arrange
    Mock_NotesRoot
    New-testingFolder "TestNotesRoot/$catname"

    # Act
    $result = Get-NotesSections -Category $catname

    # Assert
    Assert-Count -Expected 0 -Presented $result
}

function Test_GetSections_CatExist_SectionsExist {

    $catname = "kkcat"

    # Arrange
    Mock_NotesRoot
    New-testingFolder "TestNotesRoot/$catname"
    New-testingFolder "TestNotesRoot/$catname/section1"
    New-testingFolder "TestNotesRoot/$catname/section2"

    # Act
    $result = Get-NotesSections -Category $catname

    # Assert
    Assert-Count -Expected 2 -Presented $result
    Assert-Contains -Expected "section1" -Presented $result
    Assert-Contains -Expected "section2" -Presented $result
}