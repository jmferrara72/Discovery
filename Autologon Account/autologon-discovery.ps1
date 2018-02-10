$privUser=$args[0]
$privPassword=ConvertTo-SecureString $args[1] -AsPlainText -Force
$privDomain=$args[2]
$ComputerName=$args[3]
$Creds=New-Object System.Management.Automation.PSCredential ($privUser, $privPassword)

$script = {
    $checkRegistry = Get-ItemProperty "hklm:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" | Select DefaultDomainName, DefaultUserName
    $DefaultDomainName = $checkRegistry.DefaultDomainName
    $DefaultUserName=$checkRegistry.DefaultUserName
try 
{
    $ServiceName = "autologon"
    $Dependency = @()
    $userObj = New-Object -TypeName psobject
    $userObj | Add-Member -MemberType NoteProperty -Name Machine -Value $env:COMPUTERNAME
    $userObj | Add-Member -MemberType NoteProperty -Name ServiceName -Value $ServiceName
    $userObj | Add-Member -MemberType NoteProperty -Name Username -Value $DefaultUserName
    $userObj | Add-Member -MemberType NoteProperty -Name Domain -Value $DefaultDomainName
    $Dependency +=$userObj
    return $Dependency;

}
catch
{
    throw "No AutoLogon Dependencies found on $env:COMPUTERNAME" #needed till we fix discovery. Not adding "throw" will result in "No Dependencies Found" error for computers without autologn
}
}
Invoke-Command -ComputerName $ComputerName -ScriptBlock $script #-Credential $creds #this is optional, only use if you're having trouble connecting
