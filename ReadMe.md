# EncodeDecodeBase64File.ps1 script - about to become a module

## Standalone Encode and Decode scripts:

You can download the scripts separately (one for Encoding a file to Base64, one for decoding a file from Base64 encoded file) - _**Right-Click "Save link as..." to save it to your drive**_:

[Download the standalone EncodeBase64ToFile.ps1](https://raw.githubusercontent.com/SammyKrosoft/Encode-File-to-Base64-String-And-Decode/master/EncodeBase64ToFile.ps1)

[Download the standalone DecodeBase64File.ps1](https://raw.githubusercontent.com/SammyKrosoft/Encode-File-to-Base64-String-And-Decode/master/DecodeBase64File.ps1)

## Using the 0script containing the functions instead of separate scripts

Before transforming it to a PowerShell module, we for now publish it as a .ps1 script, that you must dot source to be able to use the functions defined inside this script.

## Mode information - How to use the functions

You must dot source this script to be able to use the functions described below :grin: :grin:

To dot source this script, you must type a dot, then a space, then the path to the script - if it's a script you're calling from the current directory, the path before the file name is "dot-back-slash" aka ".\\" and then the file name:
```powershell
. .\EncodeDecodeToFromBase64.ps1
```

About dot sourcing, quoting from docs.microsoft.com (link below the extract):

*The dot sourcing feature lets you run a script in the current scope instead of in the script scope. When you run a script that is dot sourced, the commands in the script run as though you had typed them at the command prompt. The functions, variables, aliases, and drives that the script creates are created in the scope in which you are working. After the script runs, you can use the created items and access their values in your session.*

*To dot source a script, type a dot (.) and a space before the script path.*


<a href = "https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_scripts?view=powershell-6" target = "_blank">Link about dot sourcing:</a>


## 2 functions available in this script

```powershell
EncodeBase64ToFile -FilePath <path of the file to encode in Base64> [-Compress] [-DestinationBase64StringFile <Path of the destination Base64 file (Optional - will generate from original file name if not specified)>]
```

```powershell
DecodeBase64FromFile -FilePAthContainingBase64Code <Path of the file to decode> [-DestinationFile <Path of the destination file (optional - will generate from Base64 file name if not specified)>]
```

## Usage


To encode a file (EXE, JPG, whatever) to a Base64 string in a file:"

```powershell
EncodeBase64ToFile -FilePath c:\temp\myExecutable.exe
```
=> will encode the ""myExecutable.exe"" file" 
into a base64 file named myExecutableexe.txt (extension merged in the file name, and appended "".txt"" new
extension.


To decode a previously Base64 encoded file into its original form:"
```powershell
DecodeBase64FromFile -FilePathContainingBase64Code c:\temp\myExecutableexe.txt
```

=> will decode the "myExecutableexe.txt" (note the "exe" substring in the file name) and rename it to "myExecutable.exe"
