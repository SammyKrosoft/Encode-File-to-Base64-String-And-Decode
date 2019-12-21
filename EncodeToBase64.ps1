Function RawExecuteBase64Converter{

    # The full path to the file we want to encode to Base64 ASCII characters so that it's considered by antivirus as Text files, and not filtered out
    $FileName = "C:\Users\sammy\OneDrive\Utils\timber.exe"

    # The full path of the file we will decode the Base64 to "rebuild" that file
    $DestBase64EncodedFile= "C:\Users\sammy\OneDrive\Utils\timberConv.txt"

    # Executing the function to convert the file $FileName, to Base64, reading all bytes to ensure we don't lose anything of the file integrity
    # Note1: the content in Base64 will be stored in the $Base64String PowerShell variable, which we will save into a file.
    # Note2: the Base64 code is pure string, and will naturally take more space than the original file. But it's very highly compressible using WinZip or 7Zip.
    $base64string = [Convert]::ToBase64String([IO.File]::ReadAllBytes($FileName))

    # Storing the $Base64String into a file for zipping and transferring
    Set-Content -Value $base64string -Path $DestBase64EncodedFile

    Exit

    # To decode the Base64 string to its original file type, just convert from Base64, writing all bytes:
    [IO.File]::WriteAllBytes($DestFileName, [Convert]::FromBase64String($base64string))
}

# Desinging functions from the above for re-useability

Function EncodeBase64ToFile {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, Position = 0)][String] $FilePath ,
        [Parameter(Mandatory = $false)][String]$DestinationBase64StringFile = "$($Env:USERPROFILE)\Documents\Base64EncodedStringFile.txt"
    )
    
    Write-Debug "Beginning Try sequence with current options $FilePath and $DestinationBase64StringFile ..."
    Try {
        Write-Debug "Trying to convert file specified to Base64 string... it can be long if the file you try to encode is big !"
        $Base64String = [Convert]::ToBase64String([IO.File]::ReadAllBytes($FilePath))
        Write-Debug "Finished converting with success !"
    } Catch {
        Write-Debug "Something went wrong ... We're in the CATCH section ..."
        Write-Host "File specified $FilePath not found ... please use an existing file path and try again !" -ForegroundColor Red
    }

    Write-Debug "Pouring the Base64 generated code into the destination file $DestinationBase64StringFile"
    Set-Content -Value $Base64String -Path $DestinationBase64StringFile

}

Function DecodeBase64StringFromFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True, Position = 0)]
        [String]
        $FilePathContainingBase64Code,
        [Parameter(Mandatory = $true, Position = 1)]
        [String]
        $DestinationFile
    )

    $Base64Content = Get-Content -Path $FilePathContainingBase64Code
    [IO.File]::WriteAllBytes($DestinationFile, [Convert]::FromBase64String($Base64Content))

}

# Example with the above strings (file Timber.exe)

# The full path to the file we want to encode to Base64 ASCII characters so that it's considered by antivirus as Text files, and not filtered out
$FileName = "C:\Users\sammy\OneDrive\Utils\timber.exe"

# The full path of the file we will decode the Base64 to "rebuild" that file
$DestBase64EncodedFile= "C:\Users\sammy\OneDrive\Utils\timberConv.txt"

EncodeBase64ToFile -FilePath $FileName -DestinationBase64StringFile $DestBase64EncodedFile -Verbose

# DecodeBase64StringFromFile -FilePathContainingBase64Code $DestBase64EncodedFile -DestinationFile $FileName