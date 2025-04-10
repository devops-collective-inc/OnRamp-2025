$secureString = ConvertTo-SecureString -String 'This is my password' -AsPlainText

$ssPtr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString)
try {
    $plaintext = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ssPtr)
    # Perform operations with the contents of $plaintext in this section.
    Write-Output $plaintext
} finally {
    # The following line ensures that sensitive data is not left in memory.
    $plainText = [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ssPtr)
}

Write-Output $plaintext
