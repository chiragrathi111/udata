This is whole scenario for aws kms:-

1. Create a KMS Key (in console, you also do cli)

2. Generating Data-Keys for the CMK :-
 
 * aws kms generate-data-key --key-id alias/youtube --key-spec AES_256 --region us-east-1
    youtube = kms alias, us-east-1 = reion
    This command will return two keys, one is plaintext data key and other is encrypted data key.

 o/p :- {"KeyId": "arn:aws:kms:us-east-1:123456789:key/bbee76a1-bd25-4d57-81d8-38ff2b26468a",
"Plaintext": "7DmPVPgzJ8exc9+AekcEmVL7jdv0RWMxPgA4JlrpE4k=",
"CiphertextBlob":
"ADIDAHiiF6PCTM1Hou+61r+M/pyUfwSizO02mH9+pIa0gaFRWwFF+FoN25Pm+tdPZiB0paGRAAAAfjB8BgkqhkiG9w0BBwabbzBtAgEAMGgGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMIB9YpWJsDdZjP4BVAgEQgDvigjj2IaJoDmXJPS2AWG6OHqMwI8H5ybsS6l0Rt26fVUskQTxxWvCzkLSqssqi3bDnEysfaxN/ryXO7w=="}   

 * echo "7DmPVPgzJ8exc9+AekcEmVL7jdv0RWMxPgA4JlrpE4k=" | base64 
--decode > datakey
 * echo "ADIDAHiiF6PCTM1Hou+61r+M/pyUfwSizO02mH9+pIa0gaFRWwFF+FoN25Pm+tdPZiB0paGRAAAAfjB8BgkqhkiG9w0BBwabbzBtAgEAMGgGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMIB9YpWJsDdZjP4BVAgEQgDvigjj2IaJoDmXJPS2AWG6OHqMwI8H5ybsS6l0Rt26fVUskQTxxWvCzkLSqssqi3bDnEysfaxN/ryXO7w=="
| base64 --decode > encrypted-datakey

3. Encrypting data with Plaintext Data-Key :-

  * echo "My database password" > password.txt  
  // any file you use for encrypt and decrept

  * openssl enc -in ./passwords.txt -out ./passwords-encrypted.txt -e -aes256 -k fileb://./datakey

  This command using create encrypted file any password file

  after date delete main passwords.txt file and datakey, so never issue for security purpose

  * rm datakey
  * rm passwords.txt

4. Decrypting data with Encrypted Data Key :-

  * aws kms decrypt --ciphertext-blob fileb://encrypted-datakey  --region us-east-1
    This command will return Plaintext data key again
    o/p :- {"KeyId": "arn:aws:kms:us-east-1:123456789:key/bbee76a1-bd25-4d57-81d8-38ff2b26468a",
"Plaintext": "7DmPVPgzJ8exc9+AekcEmVL7jdv0RWMxPgA4JlrpE4k=",
"EncryptionAlgorithm": "SYMMETRIC_DEFAULT"}

  * echo "7DmPVPgzJ8exc9+AekcEmVL7jdv0RWMxPgA4JlrpE4k=" | base64 --decode > datakey

  If security purpose deleted datakey so above command how can retrive datakey because we need to decreted our password.txt so this file is very important

  * openssl enc -in ./passwords-encrypted.txt -out ./passwords-decrypted.txt -d -aes256 -k fileb://./datakey