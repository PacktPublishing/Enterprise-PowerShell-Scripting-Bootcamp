###################################################################
# Chapter 12 - Code File - Encryption Script
###################################################################
# Function for String Encryption
Add-Type -AssemblyName System.Security
function Encrypt-String { param($String)
    try{
        $r = new-Object System.Security.Cryptography.RijndaelManaged
        $pass = [Text.Encoding]::UTF8.GetBytes($pass)
        $salt = [Text.Encoding]::UTF8.GetBytes($salt)
        $init = [Text.Encoding]::UTF8.GetBytes($init) 

        $r.Key = (new-Object Security.Cryptography.PasswordDeriveBytes $pass, $salt, "SHA1", 50000).GetBytes(32)
        $r.IV = (new-Object Security.Cryptography.SHA1Managed).ComputeHash($init)[0..15]

        $c = $r.CreateEncryptor()
        $ms = new-Object IO.MemoryStream
        $cs = new-Object Security.Cryptography.CryptoStream $ms,$c,"Write"
        $sw = new-Object IO.StreamWriter $cs
        $sw.Write($String)
        $sw.Close()
        $cs.Close()
        $ms.Close()
        $r.Clear()
        [byte[]]$result = $ms.ToArray()
    }
    catch { 
        $err = "Error Occurred Encrypting String: $_"   
    }
    if($err) {
        # Report Back Error
        return $err
    } 
    else {
        return [Convert]::ToBase64String($result)
    }
}
# All of the encoded values from YOUR execution of Script 1.
$rtd = "AAZwAmAE4AMgAoAFEAVAAhAFAA"
$ssd = "LAAyAGwAdQBRAG8AZABMAEwAJgA"
$afd = "5AFIAQgBYACYAXgBRAC4AUgA5AF"
$encSalt = "NABFAEIASgAzADsAOgBnAHEAagBxAGgAJgBcAH4AZgBRAD0ARAAzACEAZwAiACYATQBuAGwAWABzAHkA"
$encInit ="ZgA/ADoAbQBGAFMAewAjAHcAMgBYAGQALwBYACEAVgB4AHEARABVAHAANwBgACQAeAAqAD0AbgBnADEA"

# Decode the Password
$encpass = $ssd + $afd + $rtd
$encbytes = [System.Convert]::FromBase64String($encpass)
$pass = [System.Text.Encoding]::Unicode.GetString($encbytes)

# Decode the Salt
$encbytes = [System.Convert]::FromBase64String($encSalt)
$salt = [System.Text.Encoding]::Unicode.GetString($encbytes)

# Decode the Init
$encbytes = [System.Convert]::FromBase64String($encInit)
$Init = [System.Text.Encoding]::Unicode.GetString($encbytes)

cls
write-host "To End This Application, Close the Window"	
Write-host ""

do
    {	
	$string = read-host "Please Enter a String to Encrypt"
	$encrypted = Encrypt-String $string
	write-host "Encrypted String is: $encrypted"
    }
While ($good -ne "True")