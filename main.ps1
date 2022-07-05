function loadFile() {
    param(
        $path
    )

    return Get-Content -Path $path
}


function parseText() {
    param (
        $txt
    )
    
    $offset = 0

    if(-Not(([regex]::Match($txt[0][0], "\w+")).Success)) {
        $offset = 1
    }


    $line1 = $txt[0 + $offset]
    $line2 = $txt[1 + $offset]
    $flag = $false
    $template = @()
    $buffer = ""

    #Parse header
    for($i = 0; $i -le $line2.length; $i++) {
        if(($i-ge $line2.length) -and ($buffer -ne "")) {
            $template += @{'content'=$buffer.Trim();'index'=$i-1}   #Commit index with -1 since we are already in the new col
            $buffer = ""
        }

        if((([regex]::Match($line1[$i], "\w+")).Success) -Or ($line2[$i] -eq "-")) {
            #When we are detecting a new char after a whitespace _____  [_]___
            if(($flag -eq $true)) {
                $flag = $false
                $template += @{'content'=$buffer.Trim();'index'=$i-1}   #Commit index with -1 since we are already in the new col
                $buffer = ""
            }

            #Found valid letter
            $buffer += $line1[$i]
        } else {
            #When empty space is found but we are still in the current field _____[ ] ____
            if(($flag -ne $true)) {
                $flag = $true
                continue
             } #elseif($i-ge $line2.length) {
            #     $template += @{'content'=$buffer.Trim();'index'=$i-1}   #Commit index with -1 since we are already in the new col
            #     $buffer = ""
            # }
        }
    }

    #i = ROW #j = char / col; Start from Offset + 2 (2 index lines for headers etc.)
    $obj = @()
    $buffer = [ordered]@{}

    for($i = ($offset + 2); $i -lt $txt.length; $i++) {
        $preIndex = 0
        if($txt[$i].trim().length -gt "1") {
            for($j = 0; $j -lt $template.length; $j++) {
                $selector = $template[$j].index
                $field = [string]::join("",($txt[$i][($preIndex)..($selector)]))
                $buffer += [ordered]@{$template[$j].content = $field.trim()}
                
    
                $preIndex = ($selector + 1)
            }
            $obj += @([pscustomobject]($buffer))
            $buffer = [ordered]@{}
        }
    }

    return $obj
}


$directory = Read-Host -Prompt "Please enter the root of the SDDC to store the SDDC-Summary"
$destination = Read-Host -Prompt "Please enter the destination to store the SDDC-Summary"
$nodes = Get-ChildItem -Path $directory -Filter "Node_*"


foreach($node in $nodes) {
    $nodeName = ($node.Name.split("_"))[1]
    $files = Get-ChildItem -Path $node.FullName -Filter "*.txt"

    ("[=== " + $nodeName + " ===]") | Out-File -Append -FilePath ($destination + "\" + $nodename + "_trunc.txt")
    foreach($file in $files) {
        ("[=== " + $file.Name + " ===]") | Out-File -Append -FilePath ($destination + "\" + $nodename + "_trunc.txt")
        $txt = loadFile -path $file.FullName
        if(($txt.length -gt 1) -and -not ($file.Name -like "*verifier*")) {
            $obj = parseText -txt $txt
            $obj | Sort-Object -Property (($obj[0].psobject.properties | Select -ExpandProperty Name)) | ft * | Out-File -Append -FilePath ($destination + "\" + $nodename + "_trunc.txt")
        } else {
            "EMTPY FILE!" | Out-File -Append -FilePath ($destination + "\" + $nodename + "_trunc.txt")
        }
    }
}