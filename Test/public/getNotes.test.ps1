function Test_GetNotes_Category{

    Reset-InvokeCommandMock
    New-TestingFolder "TestNotesRoot"
    MockCallToString 'Invoke-NotesHelperNotesRoot' -OutString "./TestNotesRoot"

             New-TestingFile "TestNotesRoot/Folder1" "name11-name12-name13.md"
    $file1 = New-TestingFile "TestNotesRoot/Folder1" "name21-name22-name23.md" -PassThru
             New-TestingFile "TestNotesRoot/Folder2" "name31-name32-name33.md"
    $file3 = New-TestingFile "TestNotesRoot/Folder2" "name41-name42-name43.md" -PassThru

    $result = Get-Notes

    Assert-Count -Expected 4 -Presented $result

    # Pick a random file to test
    $file = $result[1]
    Assert-AreEqual -Expected "name21-name22-name23.md" -Presented $file.Name
    Assert-AreEqual -Expected "name22" -Presented $file.Category
    Assert-AreEqualPath -Expected $file1 -Presented $file.FullName

    $file = $result[3]
    Assert-AreEqual -Expected "name41-name42-name43.md" -Presented $file.Name
    Assert-AreEqual -Expected "name42" -Presented $file.Category
    Assert-AreEqualPath -Expected $file3 -Presented $file.FullName

}

function Test_GetNotes_Category_WithDots{

    Reset-InvokeCommandMock
    New-TestingFolder "TestNotesRoot"
    MockCallToString 'Invoke-NotesHelperNotesRoot' -OutString "./TestNotesRoot"

             New-TestingFile "TestNotesRoot/Folder1" "name01-name02-name03.md"
    $file1 = New-TestingFile "TestNotesRoot/Folder1" "name11-name12-name13.md" -PassThru
             New-TestingFile "TestNotesRoot/Folder2" "name21-name22-name23.md"
    $file3 = New-TestingFile "TestNotesRoot/Folder2" "name31-name32-name33.md" -PassThru
             
             New-TestingFile "TestNotesRoot/Folder2" "name41-name42-name43.md"
    $file5 = New-TestingFile "TestNotesRoot/Folder1" "name51.name52.name53.md" -PassThru
             New-TestingFile "TestNotesRoot/Folder1" "name61.name62.name63.md"
    $file7 = New-TestingFile "TestNotesRoot/Folder2" "name71.name72.name73.md" -PassThru

    $result = Get-Notes

    Assert-Count -Expected 8 -Presented $result

    # Pick a random file to test
        # Pick a random file to test
    $file = $result[1]
    Assert-AreEqual -Expected "name11-name12-name13.md" -Presented $file.Name
    Assert-AreEqual -Expected "name12" -Presented $file.Category
    Assert-AreEqualPath -Expected $file1 -Presented $file.FullName

    $file = $result[3]
    Assert-AreEqual -Expected "name31-name32-name33.md" -Presented $file.Name
    Assert-AreEqual -Expected "name32" -Presented $file.Category
    Assert-AreEqualPath -Expected $file3 -Presented $file.FullName

    $file = $result[5]
    Assert-AreEqual -Expected "name51.name52.name53.md" -Presented $file.Name
    Assert-AreEqual -Expected "name52" -Presented $file.Category
    Assert-AreEqualPath -Expected $file5 -Presented $file.FullName

    $file = $result[7]
    Assert-AreEqual -Expected "name71.name72.name73.md" -Presented $file.Name
    Assert-AreEqual -Expected "name72" -Presented $file.Category
    Assert-AreEqualPath -Expected $file7 -Presented $file.FullName

}