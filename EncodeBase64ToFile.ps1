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
 This script contains functions to encode files into Base64.
 The resulting encoded file will be located in the same folder the original file was in.

 .EXAMPLE
 EncodeBase64ToFile.ps1 -FilePath "$($env:USERPROFILE)\Downloads\MyFile.exe" -Compress -Verbose

 Will encode the file specified in the current users's Downloads folder, and compress it.


 .EXAMPLE
 DecodeBase64FromFile.ps1 -FilePathContainingBase64Code $DestBase64EncodedFile

This will decode a file with Base64content, and convert it to a file, using the file name, and the 3 last
characters as the "new" extension.

.LINK
https://github.com/SammyKrosoft/Encode-File-to-Base64-String-And-Decode

#> 

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true, Position = 0)][String] $FilePath ,
    [Parameter(Mandatory = $false)][String]$DestinationBase64StringFile,
    # Optionnally compress the Base64 file
    [Parameter(Mandatory = $false)][Switch]$Compress
)
#SamHeader
$StopWatch = [System.Diagnostics.Stopwatch]::StartNew()

If(!(Test-Path $FilePath)){
    Write-Host "File specified $FilePath not found ... please use an existing file path and try again !" -ForegroundColor Yellow -BackgroundColor Red
    $StopWatch.Stop()
    $StopWatch.Elapsed | Fl TotalSeconds
    Return
} Else {
    $objFile = Get-ChildItem $FilePath
}

If ([string]::IsNullOrEmpty($DestinationBase64StringFile)) {
    Write-Verbose "-DestinationBase64StringFile not specified ...  constructing with current file name specified: $FilePath"
    $strFileName = ($objFile).Name
    $strFileNameOneWord = ($strFileName -split "\.") -join ""
    $DestinationBase64StringFile = $strFileNameOneWord + ".txt"
    Write-Verbose "-DestinationBase64StringFile constructed from $FilePath : $DestinationBase64StringFile"
}

Write-Verbose "Beginning TRY sequence with current options -Filepath $FilePath and -DestinationBase64StringFile $DestinationBase64StringFile ..."
Try {
    Write-Verbose "Trying to convert file specified to Base64 string... it can be long if the file you try to encode is big !"
    $Base64String = [Convert]::ToBase64String([IO.File]::ReadAllBytes($objFile.VersionInfo.FileName))
    Write-Verbose "Finished converting with success !"
    Write-Verbose "Pouring the Base64 generated code into the destination file $.\$DestinationBase64StringFile"
    Set-Content -Value $Base64String -Path ".\$DestinationBase64StringFile"
    Write-Host "Success ! File written: .\$DestinationBase64StringFile" -BackgroundColor Green -ForegroundColor Black
} Catch {
    Write-Verbose "Something went wrong ... We're in the CATCH section ..."
    Write-Host "Something went wrong :-("  -ForegroundColor Yellow -BackgroundColor Red
}

If ($Compress){
    Write-Verbose "Specified the -Compress parameter, compressing file... "
    $CompressArchiveFileName = ".\$($DestinationBase64StringFile)_$(Get-Date -F ddMMMyyyy_hhmmss).zip"
    Write-Verbose "Entering TRY sequence to try to compress the Base64 file to $CompressArchiveFileName"
    Try {
        Write-Verbose "Trying to compress (REQUIRES POWERSHELL 5 and above !!)..."
        Compress-Archive -LiteralPath $DestinationBase64StringFile -DestinationPath $CompressArchiveFileName -CompressionLevel Optimal -Force
        Write-Verbose "File successfully compressed to $CompressArchiveFileName !"
        Write-Host "Don't forget to uncompress the file before running it through DecodeBase64File.ps1 script !" -ForegroundColor Red
    } Catch {
        Write-Verbose "Something happened ... unable to compress the file or to write the destination for compression..."
        Write-Host "Unable to compress to $CompressArchiveFileName ... "
        Write-Host "Last Error: $($Error[0].Exception.message)"
    }
}

$StopWatch.Stop()
$StopWatch.Elapsed | Fl TotalSeconds
