
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


function getSubfolders($path){
    $subfolders = Get-ChildItem -Path $path -Directory

    return $subfolders
}