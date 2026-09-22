
function Get-NotesCategories{
    [CmdletBinding()]
    param()

     $categoryPath = Get-NoteFolder

     $folders = getSubfolders $categoryPath

     $ret = $folders.Name

     return $ret

} Export-ModuleMember -Function Get-NotesCategories

function Get-NotesSections{
    [CmdletBinding()]
    param(
        [Parameter()][string] $Category
    )

    $categoryPath = Get-NoteFolder -Category $Category

    if(-not $categoryPath){
        "No category path found for category '$Category'" | Write-MyError
        return
    }

    $folders = getSubfolders $categoryPath

     $ret = $folders.Name

     return $ret

} Export-ModuleMember -Function Get-NotesSections

function Get-NotesTitle{
    [CmdletBinding()]
    param(
        [Parameter()][string] $Category,
        [Parameter()][string] $Section
    )

    $path = Get-NoteFolder -Category $Category -Section $Section

    if(-not $path){
        "No category path found for category '$Category' and section '$Section'" | Write-MyError
        return
    }

    $files = getNoteFiles $path

     $ret = $files.Name

     return $ret

} Export-ModuleMember -Function Get-NotesTitle


function getSubfolders($path){
    $subfolders = Get-ChildItem -Path $path -Directory

    return $subfolders
}

function getNoteFiles($path){
    $files = Get-ChildItem -Path $path -File |
        Where-Object {
            $_.Name -match '^(?<date>\d{6})' -and
            $_.Extension -match '\.(md|markdown)$'
        }

    return $files
}