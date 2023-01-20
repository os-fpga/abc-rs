
Write-Output "abc action script starts "

Write-Output "Path: $env:PATH"

$OldPATH = $env:PATH
$env:PATH = (Test-Path -Path "C:\cygwin64\bin") ? "C:\cygwin64\bin\" : "C:\cygwin\bin\"
$env:PATH -split ";"
$CygwinBin = $env:PATH
$Cygwin = $env:PATH + "bash.exe"
$arg = "-c"

& $Cygwin $arg "sed -i 's#ABC_USE_PTHREADS\"#ABC_DONT_USE_PTHREADS\" /D \"_ALLOW_KEYWORD_MACROS=1\"#g' .\*.dsp"
& $Cygwin $arg "gawk 'BEGIN { del=0; } /# Begin Group "uap"/ { del=1; } /# End Group/ { if( del > 0 ) {del=0; next;} } del==0 {print;} ' .\abclib.dsp > .\tmp.dsp"
& $Cygwin $arg "unix2dos .\*.dsp"
$env:PATH = $OldPath


Write-Output "Path: $env:PATH" 

copy .\tmp.dsp .\abclib.dsp
del .\tmp.dsp
$env:PATH = $CygwinBin
& $Cygwin $arg "unix2dos ./*.dsp"
$env:PATH = $OldPat
<# executing MsDevShell #>
pwsh.exe -File .\function.ps1 -All

devenv abcspace.dsw /upgrade  ; if (-not $? ) { cat UpgradeLog.htm }
Write-Output "Build abc..."
msbuild abcspace.sln /m /nologo /p:Configuration=Release /p:PlatformTarget=x86

<# After build we copying abc.exe, abc.rc and pthreadVC2.dll files to Release directory #>


if(Test-Path -Path .\..\..\yosys_verific_rs\bin)
{
	Write-Output "bin directory already exists"
}
else
{
	mkdir .\..\..\bin
}

Write-Output "Copying files to the bin directory..."

copy .\lib\x64\pthreadVC2.dll ..\..\bin
copy .\_TEST\abc.exe ..\..\bin
copy .\abc.rc ..\..\bin

Write-Output "abc action script ended"
