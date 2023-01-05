
Write-Output "abc action script starts "


sed -i 's#ABC_USE_PTHREADS\"#ABC_DONT_USE_PTHREADS\" /D \"_ALLOW_KEYWORD_MACROS=1\"#g' .\*.dsp
awk 'BEGIN { del=0; } /# Begin Group "uap"/ { del=1; } /# End Group/ { if( del > 0 ) {del=0; next;} } del==0 {print;} ' .\abclib.dsp > .\tmp.dsp
copy .\tmp.dsp .\abclib.dsp
del .\tmp.dsp
unix2dos .\*.dsp
<# executing MsDevShell #>
pwsh.exe .\function.ps1

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
