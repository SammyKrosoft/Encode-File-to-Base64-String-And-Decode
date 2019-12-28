<#PSScriptInfo

.VERSION 1.2

.GUID 0c680374-770b-4ec8-a924-ab9bdb1c4ace

.AUTHOR Sammy

.COMPANYNAME Microsoft Canada

.COPYRIGHT Free (I took and enhanced it from some forum discussion)

.TAGS Base64, Encode, Decode, String

.PROJECTURI https://github.com/SammyKrosoft/Encode-File-to-Base64-String-And-Decode

.RELEASENOTES
v1.2 - Added link to the Github original repository
v1.1 - Added explanations to dot source this script to be able to use the EncodeBase64 / DecodeBase64 functions

#>

<# 

.DESCRIPTION 
 This script contains functions to encode and decode files in and from Base64 

 .EXAMPLE
 EncodeBase64ToFile -FilePath "$($env:USERPROFILE)\Downloads\MyFile.exe" -Compress -Verbose

 Will encode the file specified in the current users's Downloads folder, and compress it 


 .EXAMPLE
 DecodeBase64FromFile -FilePathContainingBase64Code $DestBase64EncodedFile

This will decode a file with Base64content, and convert it to a file, using the file name, and the 3 last
characters as the "new" extension.

.LINK
https://github.com/SammyKrosoft/Encode-File-to-Base64-String-And-Decode

#> 
cls
Write-Host "you must dot source this script to be able to use the functions described below :-)" -BackgroundColor red -ForegroundColor Yellow
Write-Host "To dot source this script, type "". .\EncodeDecodeToFromBase64.ps1"" - note the ""dot"" before the "".\EncodeDecodeToFromBase64.ps1"" script ;-)"
write-host "`n"
Write-Host "You now have 2 functions you can use in this PowerShell session:"
WRite-Host "EncodeBase64ToFile -FilePath <path of the file to encode in Base64> [-Compress] [-DestinationBase64StringFile <Path of the destination Base64 file (Optional - will generate from original file name if not specified)>]" -ForegroundColor yellow -BackgroundColor blue
write-host "`n"
Write-Host "DecodeBase64FromFile -FilePAthContainingBase64Code <Path of the file to decode> [-DestinationFile <Path of the destination file (optional - will generate from Base64 file name if not specified)>]" -ForegroundColor yellow -BackgroundColor blue
write-host "`n"
Write-Host "Usage:"
Write-Host "----------------------------------------------------------------------------------------------------------------------"
Write-Host "To encode a file (EXE, JPG, whatever) to a Base64 string in a file:"
Write-Host "    -> EncodeBase64ToFile -FilePath c:\temp\myExecutable.exe" -ForegroundColor Yellow
Write-Host "    => will encode the ""myExecutable.exe"" file" 
Write-Host "    into a base64 file named myExecutableexe.txt (extension merged in the file name, and appended "".txt"" new"
Write-Host "    extension."
Write-Host "-----------------------------------------------------------------------------------------------------------------------"
Write-Host "To decode a previously Base64 encoded file into its original form:"
Write-Host "    -> DecodeBase64FromFile -FilePathContainingBase64Code c:\temp\myExecutableexe.txt" -ForegroundColor Yellow
Write-Host "    => will decode the ""myExecutableexe.txt"" (note the ""exe"" substring in the file name) and rename it to ""myExecutable.exe"" "


Function EncodeBase64ToFile {
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
        Exit
    }

    If ($DestinationBase64StringFile -eq "" -or $DestinationBase64StringFile -eq $Null) {
        Write-Verbose "-DestinationBase64StringFile not specified ...  constructing with current file name specified: $FilePath"
        $strFileName = (Get-Item $FileName).Name
        $strFileNameOneWord = $strFileName -join "\."
        $DestinationBase64StringFile = $strFileNameOneWord + ".txt"
        Write-Verbose "-DestinationBase64StringFile constructed from $FilePath : $DestinationBase64StringFile"
    }

    Write-Verbose "Beginning TRY sequence with current options -Filepath $FilePath and -DestinationBase64StringFile $DestinationBase64StringFile ..."
    Try {
        Write-Verbose "Trying to convert file specified to Base64 string... it can be long if the file you try to encode is big !"
        $Base64String = [Convert]::ToBase64String([IO.File]::ReadAllBytes($FilePath))
        Write-Verbose "Finished converting with success !"
        Write-Verbose "Pouring the Base64 generated code into the destination file $($env:userprofile)\Documents\$DestinationBase64StringFile"
        Set-Content -Value $Base64String -Path "$($env:userprofile)\Documents\$DestinationBase64StringFile"
        Write-Host "Done !" -ForegroundColor Green
    } Catch {
        Write-Verbose "Something went wrong ... We're in the CATCH section ..."
        Write-Host "Something went wrong :-("  -ForegroundColor Yellow -BackgroundColor Red
    }

    If ($Compress){
        Write-Verbose "Specified the -Compress parameter, compressing file... "
        $CompressArchiveFileName = "$($Env:USERPROFILE)\Documents\$($DestinationBase64StringFile)_$(Get-Date -F ddMMMyyyy_hhmmss).zip"
        Write-Verbose "Entering TRY sequence to try to compress the Base64 file to $CompressArchiveFileName"
        Try {
            Write-Verbose "Trying to compress (REQUIRES POWERSHELL 5 and above !!)..."
            Compress-Archive -LiteralPath $DestinationBase64StringFile -DestinationPath $CompressArchiveFileName -CompressionLevel Optimal -Force
            Write-Verbose "File successfully compressed to $CompressArchiveFileName !"
        } Catch {
            Write-Verbose "Something happened ... unable to compress the file or to write the destination for compression..."
            Write-Host "Unable to compress to $CompressArchiveFileName ... "
        }
    }

    $StopWatch.Stop()
    $StopWatch.Elapsed | Fl TotalSeconds

}

Function DecodeBase64FromFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True, Position = 0)]
        [String]
        $FilePathContainingBase64Code,
        [Parameter(Mandatory = $true, Position = 1)]
        [String]
        $DestinationFile
    )

    $StopWatch = [System.Diagnostics.Stopwatch]::StartNew()

    If(!(Test-Path $FilePathContainingBase64Code)){
        Write-Host "File specified $FilePathContainingBase64Code not found ... please use an existing file path and try again !" -ForegroundColor Yellow -BackgroundColor Red
        $StopWatch.Stop()
        $StopWatch.Elapsed | Fl TotalSeconds
        Exit
    }

    # Below sequence transforms a file name previously converted with EncodeBase64ToFile PowerShell function into the filename extension
    # Note that the first thing we do is removing the .txt extension (4 last characters) and then the last 3 letters are the file extension
    # and the other letters are the file name withtou the extension... and finally we re-build the file name by concatenating
    # the file name without extension, with a dot, with the extension (3 last letters)
    # Example : $FilePathContainingBase64Code = "Timberexe.txt" that will become Timberexe, then Timber, then Timber.exe

    if ($DestinationFile -eq "" -or $DestinationFile -eq $null){
        Write-Verbose "-DestinationFile parameter not specified ... constructing with current Base64 file name specified: $FilePathContainingBase64Code"
        $FilePathContainingBase64Code = $FilePathContainingBase64Code.Substring(0,$FilePathContainingBase64Code.Length - 4)
        $DestinationFileExtension = $FilePathContainingBase64Code.Substring($FilePathContainingBase64Code.Length - 3)
        $DestinationFileNameWithoutExtension = $FilePathContainingBase64Code.Substring(0, $FilePathContainingBase64Code.Length - 3)
        $DestinationFile = $DestinationFileNameWithoutExtension + "." + $DestinationFileExtension
        Write-Verbose "Destination file constructed: $DestinationFile"
    } Else {
        Write-Verbose "-DestinationFile parameter specified : $DestinationFile"
    }

    Write-Verbose "Beginning TRY sequence with parameters specified -FilePathContainingBase64Code as $FilePathContainingBase64Code and -DestinationFile as $DestinationFile"
    Try {
        Write-Verbose "Trying to read the Base 64 content from file specified : $FilePathContainingBase64Code"
        $Base64Content = Get-Content -Path $FilePathContainingBase64Code
        [IO.File]::WriteAllBytes($DestinationFile, [Convert]::FromBase64String($Base64Content))
        Write-Host "Success ! File written: $DestinationFile" -BackgroundColor Green -ForegroundColor Black
    } Catch {
        Write-Verbose "Something went wrong ... We're in the CATCH section..."
        Write-Host "Something went wrong :-(" -ForegroundColor Yellow -BackgroundColor Red
    }
    $StopWatch.Stop()
    $StopWatch.Elapsed | fl TotalSeconds
}
