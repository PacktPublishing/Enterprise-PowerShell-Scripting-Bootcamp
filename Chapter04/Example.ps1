# The script is invoked with the command line of:
# powershell.exe -file "c:\temp\Example.ps1" "c:\temp\Example.xml" "mAF8AQwBoAGEAcgBhAGMAdABlAHIAcwA=" 
param($xmlfile, $RTD)

###################################################################
# Example On How To Decrypt a String
###################################################################

Add-Type -AssemblyName System.Security
function Decrypt-String { param($Encrypted, $pass, $salt="CreateAUniqueSalt", $init="CreateAUniqueInit")
   
   if($Encrypted -is [string]){
      $Encrypted = [Convert]::FromBase64String($Encrypted)
   }

   $r = new-Object System.Security.Cryptography.RijndaelManaged
   $pass = [System.Text.Encoding]::UTF8.GetBytes($pass)
   $salt = [System.Text.Encoding]::UTF8.GetBytes($salt)
   $init = [Text.Encoding]::UTF8.GetBytes($init) 
   
   $r.Key = (new-Object Security.Cryptography.PasswordDeriveBytes $pass, $salt, "SHA1", 50000).GetBytes(32)
   $r.IV = (new-Object Security.Cryptography.SHA1Managed).ComputeHash($init)[0..15]

   $d = $r.CreateDecryptor()
   $ms = new-Object IO.MemoryStream @(,$Encrypted)
   $cs = new-Object Security.Cryptography.CryptoStream $ms,$d,"Read"
   $sr = new-Object IO.StreamReader $cs

   try {
       $result = $sr.ReadToEnd()
       $sr.Close()
       $cs.Close()
       $ms.Close()
       $r.Clear()
       Return $result
   }
   Catch {
       Write-host "Error Occurred Decrypting String: Wrong String Used In Script."
   }
}

# Read the XML file for the Answer File Decryptor
[xml] $xml = (get-content $xmlfile)
$AFD = $xml.GetElementsByTagName("AFD").Name

# Define the Script Side Decryptor
$SSD = "QQBfAEMAbwBtAHAAbABlAHgAXwBQAGEAc"

# Combine the Decryptors
$encvalue = $SSD + $AFD + $RTD 
# Decode the values
$encbytes = [System.Convert]::FromBase64String($encvalue)
$decrypt = [System.Text.Encoding]::Unicode.GetString($encbytes)

# Decrypt the string.
Decrypt-String "hK7GHaDD1FxknHu03TYAPxbFAAZeJ6KTSHlnSCPpJ7c=" $decrypt

PAUSE
