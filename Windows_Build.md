************************************************************
ALL content of this file designed for Windows version
************************************************************


</ABC-RS> 
executable - abc.exe required abc.rc for work.Both must be in Release directory with other .EXE and .LIB files
path to sources - Raptor\yosys_verific_rs\logic_synthesis-rs\abc-rs
executable will be created in Raptor\yosys_verific_rs\logic_synthesis-rs\abc-rs\ _TEST\ directory

Downloads


You need to download
1. <sed> command for Windows from here 
	https://gnuwin32.sourceforge.net/packages/sed.htm
2. <awk> command from this link
	<link>
3. <unix2dos> command from this link
	https://sourceforge.net/projects/dos2unix/

4. And you need to install PowerShell Core(pwsh.exe)
	https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?WT.mc_id=THOMASMAURER-blog-thmaure&view=powershell-7
5. VisalStudio 2019 (with C++ Desktop development package)
	https://visualstudio.microsoft.com/vs/older-downloads/


Build
Step 1: run this commands with "pwsh.exe"

```bash
sed -i 's#ABC_USE_PTHREADS\"#ABC_DONT_USE_PTHREADS\" /D \"_ALLOW_KEYWORD_MACROS=1\"#g' *.dsp
awk 'BEGIN { del=0; } /# Begin Group "uap"/ { del=1; } /# End Group/ { if( del > 0 ) {del=0; next;} } del==0 {print;} ' abclib.dsp > tmp.dsp
copy tmp.dsp abclib.dsp
del tmp.dsp
unix2dos *.dsp
```

Step 2: create "action.ps1" file with the below contents and run it with "pwsh action.ps1" command in PowerShell.

```bash
function MsDevShell {
    # Use `vswhere` to locate Visual Studio editions.
    $products = 'Community','Professional','Enterprise','BuildTools' | %{ "Microsoft.VisualStudio.Product.$_" }
    $vswhere = Get-Command 'vswhere'
    $vs = & $vswhere.Path -products $products -latest -format json | ConvertFrom-Json
    $tools = Join-Path $vs.installationPath 'Common7' 'Tools'
  
    try {
      # Attempt 1 (Visual Studio 2019 and newer)
      #
      # Look for DevShell.dll and import it. Then use the provided
      # `Enter-VsDevShell` command to merge the DevShell environment into
      # the current environment.
  
      # Locate DevShell.dll within the Visual Studio installation.
      $devshell = Join-Path $tools 'Microsoft.VisualStudio.DevShell.dll'
      if (!(Test-Path $devshell -Type Leaf)) {
          $devshell = Join-Path $tools 'vsdevshell' 'Microsoft.VisualStudio.DevShell.dll'
      }
      if (!(Test-Path $devshell -Type Leaf)) {
          throw "error: cannot find Microsoft.VisualStudio.DevShell.dll"
      }
  
      # Import DevShell.dll and use Enter-VsDevShell.
      Import-Module $devshell
      Enter-VsDevShell -VsInstanceId $vs.instanceId -SkipAutomaticLocation -DevCmdArguments '-arch=x86 -no_logo'
  
    } catch {
      # Print exception for debugging.
      echo $_
  
      # Attempt 2 (Visual Studio 2017)
      #
      # Execute VsDevCmd.bat and parse its output into a collection. Then
      # take each entry and merge it into the environment. The idea was
      # taken from:
      #     https://github.com/microsoft/vswhere/issues/150#issuecomment-485381959
  
      # Locate VsDevCmd.bat within the Visual Studio installation.
      $devcmd = Join-Path $tools 'VsDevCmd.bat'
      if (!(Test-Path $devcmd -Type Leaf)) {
          throw "error: cannot find VsDevCmd.bat"
      }
  
      # Run VsDevCmd.bat and parse the output into a collection.
      $cmd = '"{0}" -arch=x86 -no_logo && pwsh -Command "Get-ChildItem env: | Select-Object Name,Value | ConvertTo-Json"' -f $devcmd
      $output = $(& "${env:COMSPEC}" /s /c $cmd)
      if ($LASTEXITCODE -ne 0) {
          throw $output
      }
  
      # Merge the output into the environment.
      $output | ConvertFrom-Json | %{ Set-Content "env:$($_.Name)" $_.Value }
    }
  }
  
  # Enter VsDevShell and collect the environment before and after.
  $before = @{}
  Get-ChildItem env: | %{ $before.Add($_.Name, $_.Value) }
  MsDevShell
  $after = @{}
  Get-ChildItem env: | %{ $after.Add($_.Name, $_.Value) }
  
  # Calculate environment update.
  $diff = $after.GetEnumerator() | where { -not $before.ContainsKey($_.Name) -or $before[$_.Name] -ne $_.Value }
  
  # Print and export environment update.
  echo '----------------------------------------'
  echo 'Updated Environment'
  echo '----------------------------------------'
  $diff | Format-List
  echo '----------------------------------------'
  $diff | %{ echo "$($_.Name)=$($_.Value)" >> $env:GITHUB_ENV }

```

Step 3: run command 
```bash
devenv abcspace.dsw /upgrade  ; if (-not $? ) { cat UpgradeLog.htm }
```

Step 4: open Visual Studio solution file " abcspace.sln ".On configure window press OK

Step 5: run command
```bash
msbuild abcspace.sln /m /nologo /p:Configuration=Release /p:PlatformTarget=x86
```

Abc-rs must be build with some wornings
</ABC-RS>


___________________________________________________________________________________________________________________________________