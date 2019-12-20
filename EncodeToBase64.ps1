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


# Desinging functions from the above for re-useability

Function EncodeBase64ToFile {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, Position = 0)][String] $FilePath ,
        [Parameter(Mandatory = $false)][String]$DestinationBase64StringFile = "$($Env:USERPROFILE)\Documents\Base64EncodedStringFile.txt"
    )
    
    $Base64String = [Convert]::ToBase64String([IO.File]::ReadAllBytes($FilePath))

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

    [IO.File]::WriteAllBytes($DestinationFile, [Convert]::FromBase64String(Get-Content -Path $FilePathContainingBase64Code))
    
}