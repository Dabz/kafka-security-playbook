#!/usr/bin/expect

proc slurp {file} {
    set fh [open $file r]
    set ret [read $fh]
    close $fh
    return $ret
}

proc create_certs {cert_name,machine} {
  eval spawn ./create-pair-certs.sh $cert_name $machine server_cert
}

set timeout 20
set configslurp [slurp configs/ca-config-vars]

set lines [split $configslurp \n]
set COUNTRY_NAME [lrange $lines 0 0]
set STATE [lrange $lines 1 1]
set LOCALITY [lrange $lines 2 2]
set ORGANIZATION [lrange $lines 3 3]

set cert_name [lindex $argv 0]
set machine [lrange $argv 1 end]

eval spawn ./create-pair-certs.sh $cert_name $machine server_cert

## Generating the data for the CA setup.
expect "Country Name (2 letter code)"
send "$COUNTRY_NAME\r";
expect "State or Province Name"
send "$STATE\r";
expect "Locality Name"
send "$LOCALITY\r";
expect "Organization Name"
send "$ORGANIZATION\r";
expect "Organizational Unit Name"
send "\r";
expect "Common Name"
send "$cert_name\r";
expect "Email Address"
send "\r";
# Sign the certificate and commit
expect "Sign the certificate?"
send "y\r";
expect "1 out of 1 certificate requests certified, commit?"
send "y\r";
#interact
