# {"arrayOutput":{"type":"Array","value":["a","b","c","d"]},"boolOutputA":{"type":"Bool","value":true},"boolOutputB":{"type":"Bool","value":false},"intOutput":{"type":"Int","value":98052},"objectOutput":{"type":"Object","value":{"objectPropertyA":"hello","objectPropertyB":"world"}},"secureObjectOutput":{"type":"SecureObject"},"secureStringOutput":{"type":"SecureString"},"stringOutput":{"type":"String","value":"this is a string"}}

#$outputJson = '{"arrayOutput":{"type":"Array","value":["a","b","c","d"]},"boolOutputA":{"type":"Bool","value":true},"boolOutputB":{"type":"Bool","value":false},"intOutput":{"type":"Int","value":98052},"objectOutput":{"type":"Object","value":{"objectPropertyA":"hello","objectPropertyB":"world"}},"secureObjectOutput":{"type":"SecureObject"},"secureStringOutput":{"type":"SecureString"},"stringOutput":{"type":"String","value":"this is a string"}}'

function ParseProperty([psnoteproperty] $property) {
    Write-Host ("##vso[task.setvariable variable=$variablePrefix" + $property.Name + ";issecret=true]" + (ConvertTo-Json -Compress $property.Value.value))
}

function ParseStringProperty([psnoteproperty] $property) {
    Write-Host ("##vso[task.setvariable variable=$variablePrefix" + $property.Name + ";issecret=true]" + $property.Value.value)
}

function ParseSecureObject([psnoteproperty] $property) {
    Write-Host "SecureObject output is not returned by the Azure DevOps ARM deployment task"
}

function ParseSecureString([psnoteproperty] $property) {
    Write-Host "SecureString output is not returned by the Azure DevOps ARM deployment task"
}

$outputJson = Get-VstsInput -Name "armOutput" -Require

$variablePrefix = Get-VstsInput -Name "variablePrefix"  # "var_"
$excludedVariablesList = Get-VstsInput -Name "excludedOutputs" 

$excludedVariables = $excludedVariablesList.Replace(" ", "").Split(",")

$output = ConvertFrom-Json $outputJson


foreach ($prop in $output.PSObject.Properties) {
    if ($excludedVariables -contains $prop.Name) {
        Write-Host "Skipping " $prop.Name
        continue
    }
    
    switch ($prop.Value.type) {
        "Array"         { ParseProperty $prop }
        "Bool"          { ParseProperty $prop }
        "Int"           { ParseProperty $prop }
        "Object"        { ParseProperty $prop }
        "SecureObject"  { ParseSecureObject $prop }
        "SecureString"  { ParseSecureString $prop }
        "String"        { ParseStringProperty $prop }
    }
}
