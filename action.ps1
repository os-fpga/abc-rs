
Write-Output "abc action script start "


sed -i 's#ABC_USE_PTHREADS\"#ABC_DONT_USE_PTHREADS\" /D \"_ALLOW_KEYWORD_MACROS=1\"#g' .\*.dsp
awk 'BEGIN { del=0; } /# Begin Group "uap"/ { del=1; } /# End Group/ { if( del > 0 ) {del=0; next;} } del==0 {print;} ' .\abclib.dsp > .\tmp.dsp
copy .\tmp.dsp .\abclib.dsp
del .\tmp.dsp
unix2dos .\*.dsp
<# executing MsDevShell #>
pwsh.exe .\function.ps1

devenv abcspace.dsw /upgrade  ; if (-not $? ) { cat UpgradeLog.htm }
msbuild abcspace.sln /m /nologo /p:Configuration=Release /p:PlatformTarget=x86

<# After build we copying abc.exe, abc.rc and pthreadVC2.dll files to Release directory #>
mkdir ../../x64
mkdir ../../x64/Release
copy .\lib\x64\pthreadVC2.dll ..\..\x64\Release
copy .\_TEST\abc.exe ..\..\x64\Release
copy .\abc.rc ..\..\x64\Release

Write-Output "abc action script end"
