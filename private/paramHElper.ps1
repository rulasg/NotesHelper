function Get-ParamValuesCategory{
     param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    $list = Get-NotesCategories

    $list | ConvertTo-CompleteResults -wordToComplete $wordToComplete
}

function Get-ParamValuesSection{
     param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    $category = getParameterValue -commandAst $commandAst -ParameterName "Category"

    $list = Get-NotesSections -Category $category

    $list | ConvertTo-CompleteResults -wordToComplete $wordToComplete
}