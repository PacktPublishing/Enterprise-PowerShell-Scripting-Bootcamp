###################################################################
# Chapter 12 - Code File - Encoding
###################################################################


###################################################################
# Example On Create a Random Passphrase
###################################################################
Function create-password {
    $password = ""
    For ($a=33;$a –le 126;$a++) {
        $ascii += ,[char][byte]$a
    }
    1..30 | % { $password += $ascii | get-random }    
    return $password
}
$pass = create-password
$salt = create-password
$init = create-password

###################################################################
# Example On How To Prompt for Encoding a Passphrase
###################################################################
$encodedpass = [System.Text.Encoding]::Unicode.GetBytes($pass)
$encodedvalue = [Convert]::ToBase64String($encodedpass)
# Since the returned encoding is 80 characters in length, you split into 27, 27, 26
$SSD = $encodedvalue.substring(0,27)
$AFD = $encodedvalue.substring(27,27)
$RTD = $encodedvalue.substring(54,26)

$encSalt = [System.Text.Encoding]::Unicode.GetBytes($salt)
$encSalt = [Convert]::ToBase64String($encSalt)

$encInit = [System.Text.Encoding]::Unicode.GetBytes($init)
$encInit = [Convert]::ToBase64String($encInit)

Write-host "The SSD is: $SSD"
Write-host "The AFD is: $AFD"
Write-host "The RTD is: $RTD"
Write-host "The Salt is: $encSalt"
Write-host "The Init is: $encInit"


