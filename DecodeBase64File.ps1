<#PSScriptInfo

.VERSION 1.2.1

.GUID 0c680374-770b-4ec8-a924-ab9bdb1c4ace

.AUTHOR Sammy

.COMPANYNAME Microsoft Canada

.COPYRIGHT Free (I took and enhanced it from some forum discussion)

.TAGS Base64, Encode, Decode, String

.PROJECTURI https://github.com/SammyKrosoft/Encode-File-to-Base64-String-And-Decode

.RELEASENOTES
v1.2.1 - renamed DecodeBase64StringFromFile to DecodeBase64FromFile
v1.2 - Added link to the Github original repository
v1.1 - Added explanations to dot source this script to be able to use the EncodeBase64 / DecodeBase64 functions

#>

<# 

.DESCRIPTION 
 This script decodes files encoded into Base64 by the EncodeBase64ToFile.ps1 script. 

 .EXAMPLE
 DecodeBase64File.ps1 -FilePathContainingBase64Code $DestBase64EncodedFile

This will decode a file with Base64content, and convert it to a file, using the file name, and the 3 last
characters as the "new" extension.

.LINK
https://github.com/SammyKrosoft/Encode-File-to-Base64-String-And-Decode

#> 

[CmdletBinding()]
param (
    [Parameter(Mandatory = $True, Position = 0)]
    [String]
    $FilePathContainingBase64Code,
    [Parameter(Mandatory = $false, Position = 1)]
    [String]
    $DestinationFile
)

$StopWatch = [System.Diagnostics.Stopwatch]::StartNew()


Function WriteGreen {
    param(
        [string]$message
    )
    write-Host $message -ForegroundColor Green
}

If(!(Test-Path $FilePathContainingBase64Code)){
    Write-Host "File specified $FilePathContainingBase64Code not found ... please use an existing file path and try again !" -ForegroundColor Yellow -BackgroundColor Red
    $StopWatch.Stop()
    $StopWatch.Elapsed | Fl TotalSeconds
    Exit
}

# Below sequenceis only string manipulation, which transforms a file name previously converted with EncodeBase64ToFile PowerShell function/script 
# (saved as FileNameExtension.txt) into filename.extension (drops the .txt extension, and puts a dot on the 3 last letters of the string)
# Note that the first thing we do is removing the .txt extension (4 last characters) and then the last 3 letters are the file extension
# and the other letters are the file name without the extension... and finally we re-build the file name by concatenating
# the file name without extension, with a dot, with the extension (3 last letters)
# Example : $FilePathContainingBase64Code = "Timberexe.txt" that will become Timberexe, then Timber, then Timber.exe

if ($DestinationFile -eq "" -or $DestinationFile -eq $null){
    WriteGreen "-DestinationFile parameter not specified ... constructing with current Base64 file name specified: $FilePathContainingBase64Code"
    $FileName64Txt = Split-Path $FilePathContainingBase64Code -Leaf
    $FilePath64 = Split-Path $FilePathContainingBase64Code -Parent

    $FileName64 = $FileName64Txt.Substring(0,$FileName64Txt.Length - 4)
    
    WriteGreen "File Name without TXT extension............$FileName64"
    $FileExt = $FileName64.Substring($FileName64.Length - 3)
    WriteGreen "Destination File Extension.................$FileExt"
    $FileNameNoExt = $FileName64.Substring(0, $FileName64.Length - 3)
    WriteGreen "Destination File Name Without Extension....$FileNameNoExt"
    $FileName = $FileNameNoExt + "." + $FileExt
    WriteGreen "Destination file constructed: $FileName"
    #Adding Downloads folder
    $DestinationFile = ($Env:userprofile) + "\Downloads\" + $FileName
    WriteGreen "Final destination file and Path          =   $DestinationFile"

} Else {
    WriteGreen "-DestinationFile parameter specified : $DestinationFile"
}

WriteGreen "Beginning TRY sequence with parameters specified -FilePathContainingBase64Code as $FilePathContainingBase64Code and -DestinationFile as $DestinationFile"
Try {
    WriteGreen "Trying to read the Base 64 content from file specified : $FilePathContainingBase64Code"
    $Base64Content = Get-Content -Path $FilePathContainingBase64Code
    [IO.File]::WriteAllBytes($DestinationFile, [Convert]::FromBase64String($Base64Content))
    Write-Host "Success ! File written: $DestinationFile" -BackgroundColor Green -ForegroundColor Black
} Catch {
    WriteGreen "Something went wrong ... We're in the CATCH section..."
    Write-Host "Something went wrong :-(" -ForegroundColor Yellow -BackgroundColor Red
}
$StopWatch.Stop()
$StopWatch.Elapsed | fl TotalSeconds