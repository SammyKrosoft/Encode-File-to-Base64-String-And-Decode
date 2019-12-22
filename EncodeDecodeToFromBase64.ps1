Function RawExecuteBase64Converter{

    # The full path to the file we want to encode to Base64 ASCII characters so that it's considered by antivirus as Text files, and not filtered out
    $FileName = "C:\temp\timber.exe"

    # The full path of the file we will decode the Base64 to "rebuild" that file
    $DestBase64EncodedFile= "C:\temp\timberConv.txt"

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
        [Parameter(Mandatory = $false)][String]$DestinationBase64StringFile,
        # Optionnally compress the Base64 file
        [Parameter(Mandatory = $false)][Switch]$Compress
    )
    #SamHeader
    $StopWatch = [System.Diagnostics.Stopwatch]::StartNew()

If ($DestinationBase64StringFile -eq "" -or $DestinationBase64StringFile -eq $Null) {
    $strFileName = (Get-Item $FileName).Name
    $strFileNameOneWord = $strFileName -join "\."
    $DestinationBase64StringFile = $strFileNameOneWord + ".txt"
}

    Write-Verbose "Beginning TRY sequence with current options -Filepath $FilePath and -DestinationBase64StringFile $DestinationBase64StringFile ..."
    Try {
        Write-Verbose "Trying to convert file specified to Base64 string... it can be long if the file you try to encode is big !"
        $Base64String = [Convert]::ToBase64String([IO.File]::ReadAllBytes($FilePath))
        Write-Verbose "Finished converting with success !"
        Write-Verbose "Pouring the Base64 generated code into the destination file $DestinationBase64StringFile"
        Set-Content -Value $Base64String -Path $DestinationBase64StringFile
        Write-Host "Done !" -ForegroundColor Green
    } Catch {
        Write-Verbose "Something went wrong ... We're in the CATCH section ..."
        Write-Host "File specified $FilePath not found ... please use an existing file path and try again !" -ForegroundColor Yellow -BackgroundColor Red
    }

    If ($Compress){
        Write-Verbose "Specified the -Compress parameter, compressing file... "
        $CompressArchiveFileName = "$($Env:USERPROFILE)\Documents\CompressedBase64File_$(Get-Date -F ddMMMyyyy_hhmmss).zip"
        Write-Verbose "Entering TRY sequence to try to compress the Base64 file to $CompressArchiveFileName"
        Try{
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


# Below sequence transforms a file name previously converted with EncodeBase64ToFile PowerShell function into the filename extension
# Note that the first thing we do is removing the .txt extension (4 last characters) and then the last 3 letters are the file extension
# and the other letters are the file name withtou the extension... and finally we re-build the file name by concatenating
# the file name without extension, with a dot, with the extension (3 last letters)
# Example : $FilePathContainingBase64Code = "Timberexe.txt" that will become Timberexe, then Timber, then Timber.exe

if ($DestinationFile -eq "" -or $DestinationFile -eq $null){
    $FilePathContainingBase64Code = $FilePathContainingBase64Code.Substring(0,$FilePathContainingBase64Code.Length - 4)
    $DestinationFileExtension = $FilePathContainingBase64Code.Substring($FilePathContainingBase64Code.Length - 3)
    $DestinationFileNameWithoutExtension = $FilePathContainingBase64Code.Substring(0, $FilePathContainingBase64Code.Length - 3)
    $DestinationFile = $DestinationFileNameWithoutExtension + "." + $DestinationFileExtension
}

$DestinationFile

    $StopWatch = [System.Diagnostics.Stopwatch]::StartNew()
    Write-Verbose "Beginning TRY sequence with parameters specified -FilePathContainingBase64Code as $FilePathContainingBase64Code and -DestinationFile as $DestinationFile"
    Try {
        Write-Verbose "Trying to read the Base 64 content from file specified : $FilePathContainingBase64Code"
        $Base64Content = Get-Content -Path $FilePathContainingBase64Code
        [IO.File]::WriteAllBytes($DestinationFile, [Convert]::FromBase64String($Base64Content))
        Write-Host "Success ! File written: $DestinationFile" -BackgroundColor Green -ForegroundColor Black
    } Catch {
        Write-Verbose "Something went wrong ... We're in the CATCH section..."
        Write-Host "File specified $FilePathContainingBase64Code inexistant or destination file $Destination not specified ..." -ForegroundColor Yellow -BackgroundColor Red
    }
    $StopWatch.Stop()
    $StopWatch.Elapsed | fl TotalSeconds
}

# Example with the above strings (file Timber.exe)

# The full path to the file we want to encode to Base64 ASCII characters so that it's considered by antivirus as Text files, and not filtered out
$FileName = "$($env:USERPROFILE)\Downloads\MyFile.exe"

# The full path of the file we will decode the Base64 to "rebuild" that file
$DestBase64EncodedFile= "C:\temp\MyFileExe.txt"

 EncodeBase64ToFile -FilePath $FileName -DestinationBase64StringFile $DestBase64EncodedFile -Verbose -Compress
# DecodeBase64StringFromFile -FilePathContainingBase64Code $DestBase64EncodedFile -DestinationFile $FileName