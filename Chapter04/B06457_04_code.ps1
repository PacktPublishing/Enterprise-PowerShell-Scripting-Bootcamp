###################################################################
# Chapter 4 - Code File
###################################################################

###################################################################
# Example On How To Create passwords
###################################################################

Function create-password {
    
    # Declare password variable outside of loop.
    $password = ""

    # For numbers between 33 and 126
    For ($a=33;$a –le 126;$a++) {
        # Add the Ascii text for the ascii number referenced. 
        $ascii += ,[char][byte]$a
    }
    # Generate a random character form the $ascii character set.
    # Repeat 30 times, or create 30 random characters.
    1..30 | ForEach { $password += $ascii | get-random }
    
    # Return the password
    return $password
}
# Create four 30 character passwords
create-password
create-password
create-password
create-password


###################################################################
# Example On How To Load the .NET Assemblies
###################################################################

Write-host "Loading the .NET System.Security Assembly For Encryption"
Add-Type -AssemblyName System.Security -ErrorAction SilentlyContinue -ErrorVariable err
if ($err) {
    Write-host "Error Importing the .NET System.Security Assembly."
    PAUSE
    EXIT
}
# if err is not set, it was successful.
if (!$err) {
    Write-host "Succesfully loaded the .NET System.Security Assembly For Encryption"
}

###################################################################
# Example On How To Encrypt a String using RijndaelManaged Encryption
###################################################################
# Import the System.Security Assembly
Add-Type -AssemblyName System.Security
function Encrypt-String { param($String, $Pass, $salt="CreateAUniqueSalt", $init="CreateAUniqueInit")
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
Encrypt-String "Encrypt This String" "A_Complex_Password_With_A_Lot_Of_Characters"

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
Decrypt-String "hK7GHaDD1FxknHu03TYAPxbFAAZeJ6KTSHlnSCPpJ7c=" "A_Complex_Password_With_A_Lot_Of_Characters"


###################################################################
# Example On How To Encode a Password
###################################################################
$pass = "A_Complex_Password_With_A_Lot_Of_Characters"
$encodedpass = [System.Text.Encoding]::Unicode.GetBytes($pass)
$encodedvalue = [Convert]::ToBase64String($encodedpass)
$encodedvalue

###################################################################
# Example On How To decode a Password
###################################################################
$encvalue = "QQBfAEMAbwBtAHAAbABlAHgAXwBQAGEAcwBzAHcAbwByAGQAXwBXAGkAdABoAF8AQQBfAEwAbwB0AF8ATwBmAF8AQwBoAGEAcgBhAGMAdABlAHIAcwA="
$encbytes = [System.Convert]::FromBase64String($encvalue)
$decodedvalue = [System.Text.Encoding]::Unicode.GetString($encbytes)
$decodedvalue

############################################################################
# Full example on how to properly decode a string for use in decrypting data
############################################################################
# Cheat Sheet for Script example.
$xmlfile = "c:\temp\Example.xml"
$RTD = "mAF8AQwBoAGEAcgBhAGMAdABlAHIAcwA="

# The script is invoked with the command line of:
# powershell.exe -file "c:\temp\Example.ps1" "c:\temp\Example.xml" "mAF8AQwBoAGEAcgBhAGMAdABlAHIAcwA=" 
param($xmlfile, $RTD)

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

