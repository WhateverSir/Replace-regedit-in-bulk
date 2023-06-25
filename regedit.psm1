#设置注册表并日志
function SetAndLong($Path,$Name,$Value,$OldValue){
    #Requires -RunAsAdministrator
    $command="Set-ItemProperty -Path $Path -Name $Name -Value $Value "+';$?'
    $status=iex $command
    if ($status){
        "$(Get-Date) $command oldvalue $OldValue" |Out-File -Append -Encoding $(if ($PSVersionTable.PSVersion.Major -ge 6){"utf8NoBOM"}else{"utf8"}) -FilePath "regchange.log"
    }

}

#替换注册表https://stackoverflow.com/questions/26680410/powershell-find-and-replace-on-registry-values#
function RegistryValue-Replace(
  [string]$path = $(throw "path为必填(即注册表路径)"),
  [string]$NewValue = $(throw "NewValue为必填(即替换的值)"),
  [string]$key, #可选为指定键
  [string]$OldValue, #OldValue可选(即当前值)，有则进行校验
  [ScriptBlock]$DoMethod #DoMethod可选，自定义处理函数
  ){
    Get-Item -ErrorAction SilentlyContinue -path  "Microsoft.PowerShell.Core\Registry::$path"|
    foreach {
        Get-ItemProperty -Path "Microsoft.PowerShell.Core\Registry::$_" | 
        foreach {
            $CurrentUserShellFoldersPath = $_.PSPath
            $_.PSObject.Properties |
            foreach {
                if (![String]::IsNullOrEmpty($key) -and !($_.name -like $key) ){ #键校验
                    return
                }
                if (![String]::IsNullOrEmpty($OldValue) -and !($_.Value -eq $OldValue)){ #旧值校验
                    return
                }
                if ($DoMethod -ne $Null){
                    $DoMethod.invoke($_,$CurrentUserShellFoldersPath)
                    return
                }
                SetAndLong -Path $CurrentUserShellFoldersPath -Name $_.Name -Value $newValue -OldValue $_.Value
            }
        }
    }
}