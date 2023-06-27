# 脚本用于扫描替换注册表值，比如修改用户文件夹名后
Import-Module .\regedit.psm1 #引入脚本
$replaceKey=@(‘C:\Users\中文名’,‘C:\Users\ChineseName’) #在这里写要替换的字符串和目标字符串
# check param num
if ($replaceKey.count -ne 2)
{
    throw "参数不匹配,replaceKey需要两个参数"
}
$re=$replaceKey[0] -replace "\\","\\"
# query regdata
function Shell-Do(){
	#遍历注册表5个根项
    Foreach($hkey in @('HKCR','HKCU','HKLM','HKU','HKCC')) {
        $querydata=reg query $hkey /s /d /f $replaceKey[0] #HKCR HKCU HKLM HKU HKCC
        [regex]::matches($querydata,'(?m)(?<path>\S+) {5}\S+ {4}\S+ {4}') |
        foreach{
            RegistryValue-Replace $_.Groups['path'].value $null -DoMethod {
                param($Propert,[string]$path)
                if ($Propert.Value -match $re){
                    $new=$Propert.Value -replace $re,$replaceKey[1]
                    SetAndLong -Path "'$path'" -Name "`"$($Propert.Name)`"" -Value "'$new'" -OldValue "$($Propert.Value)"
                }
            }
        }
    }
}

Shell-Do
