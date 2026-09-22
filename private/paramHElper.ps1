
# function Add-CategoryAndSectionParamCompletion($cmdlet){
#     Register-ArgumentCompleter -CommandName $cmdlet -ParameterName "Category" -ScriptBlock { param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters) Get-ParamValuesCategory @PsBoundParameters }
#     Register-ArgumentCompleter -CommandName $cmdlet -ParameterName "Section" -ScriptBlock { param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters) Get-ParamValuesSection @PsBoundParameters }
# }

function Get-ParamValuesCategory{
     param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    $list = Get-NotesCategories

    $list | ConvertTo-CompleteResults -wordToComplete $wordToComplete
}

function Get-ParamValuesSection{
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters, $category)

    # Category
    if([string]::IsNullOrWhiteSpace($category)){ $category = getParameterValue -commandAst $commandAst -ParameterName "Category"}

    "Getting sections for category: $category" | Write-Mydebug -Section "ArgumentCompleter"
    $list = Get-NotesSections -Category $category

    $list | ConvertTo-CompleteResults -wordToComplete $wordToComplete
}

function Get-ParamValuesTitle{
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters, $category, $section)

    # Category
    if([string]::IsNullOrWhiteSpace($category)){ 
        "No CATEGORY provided, trying to get from commandAst" | Write-Mydebug -Section "ArgumentCompleter"
        $category = getParameterValue -commandAst $commandAst -ParameterName "Category" -ParameterPosition 0
        "CATEGORY from commandAst: $category" | Write-Mydebug -Section "ArgumentCompleter"
    }

    # Section
    if([string]::IsNullOrWhiteSpace($section)){ 
        "No SECTION provided, trying to get from commandAst" | Write-Mydebug -Section "ArgumentCompleter"
        $section = getParameterValue -commandAst $commandAst -ParameterName "Section" -ParameterPosition 0
        "SECTION from commandAst: $section" | Write-Mydebug -Section "ArgumentCompleter"
    }

    if([string]::IsNullOrWhiteSpace($category) -or [string]::IsNullOrWhiteSpace($section)){
        return $null
    }

    "Getting titles for category: $category and section: $section" | Write-Mydebug -Section "ArgumentCompleter"
    $list = Get-NotesTitle -Category $category -Section $section

    $list | ConvertTo-CompleteResults -wordToComplete $wordToComplete
}

function Get-ParamValuesTemplate{
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    $list = @("none","meetingmini")

    $list | ConvertTo-CompleteResults -wordToComplete $wordToComplete
}