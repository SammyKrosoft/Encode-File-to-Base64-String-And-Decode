#EncodeDecodeToFromBase64.ps1 script - about to become a module

Before I understand PowerShell modules fully, we for now publish it as a .ps1 script, that you must dot source to be able to use the functions defined inside this script.

## Mode information - How to use the functions

You must dot source this script to be able to use the functions described below :-)" -BackgroundColor red -ForegroundColor Yellow
To dot source this script, type "". .\EncodeDecodeToFromBase64.ps1"" - note the ""dot"" before the "".\EncodeDecodeToFromBase64.ps1"" script ;-)"

## 2 functions available in this script

```powershell
EncodeBase64ToFile -FilePath <path of the file to encode in Base64> [-Compress] [-DestinationBase64StringFile <Path of the destination Base64 file (Optional - will generate from original file name if not specified)>]" -ForegroundColor yellow -BackgroundColor blue
```

```powershell
DecodeBase64StringFromFile -FilePAthContainingBase64Code <Path of the file to decode> [-DestinationFile <Path of the destination file (optional - will generate from Base64 file name if not specified)>]" -ForegroundColor yellow -BackgroundColor blue
```

## Usage


To encode a file (EXE, JPG, whatever) to a Base64 string in a file:"

```powershell
EncodeBase64ToFile -FilePath c:\temp\myExecutable.exe" -ForegroundColor Yellow
```
=> will encode the ""myExecutable.exe"" file" 
into a base64 file named myExecutableexe.txt (extension merged in the file name, and appended "".txt"" new
extension.


To decode a previously Base64 encoded file into its original form:"
```powershell
DecodeBase64StringFromFile -FilePathContainingBase64Code c:\temp\myExecutableexe.txt" -ForegroundColor Yellow
```

=> will decode the "myExecutableexe.txt" (note the "exe" substring in the file name) and rename it to "myExecutable.exe"
