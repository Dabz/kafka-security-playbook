# Building a CA with OpenSSL

This is a collection is scripts useful to generated a local CA setup. While the PKI could be set in different ways, for this example
we generate:

* A root CA identity, for example for your mother company.
* An intermediate CA identity, for example the one generated for your department or smaller company.
* And then the client certificates.

All the scripts are wrapping openssl to generate the required structures.


## Commands

A collection of scripts are provided to generate any of the required steps to build this CA.

*IMPORTANT:* This scripts set a default password for the CA certs, this password is: __confluent__ . You should change it.

### Building the root CA

To construct the root CA setup, you can run the script:

```bash
./utils/build-ca.sh
```

this script will generate the default directory structure for the CA, including the root certificate for your authority. After the execution you should see a directory structure like this:

```bash
➜  ca-builder-scripts git:(ca-builder-scripts) ✗ ls -la ca
total 48
drwxr-xr-x  13 pere  staff   416  3 May 16:33 .
drwxr-xr-x  16 pere  staff   512  3 May 16:32 ..
drwxr-xr-x   3 pere  staff    96  3 May 16:33 certs
drwxr-xr-x   2 pere  staff    64  3 May 16:32 crl
-rw-r--r--   1 pere  staff    97  3 May 16:33 index.txt
-rw-r--r--   1 pere  staff    21  3 May 16:33 index.txt.attr
drwxr-xr-x   3 pere  staff    96  3 May 16:33 newcerts
-rw-r--r--   1 pere  staff  4117  3 May 16:32 openssl.cnf
drwx------   3 pere  staff    96  3 May 16:32 private
-rw-r--r--   1 pere  staff     5  3 May 16:33 serial
```

*NOTE*: This script sets a default password for the root certificate, change it if you require to have another one.

### Building the intermediate CA.

Once the main CA structure is created, you need to create the intermediate CA, for this you can use this script:

```bash
./utils/build-intermediate-ca.sh
```

Once the script is run, you should see a directory structure like this:

```bash
➜  ca-builder-scripts git:(ca-builder-scripts) ✗ ls -la ca/intermediate
total 80
drwxr-xr-x  16 pere  staff   512  3 May 17:22 .
drwxr-xr-x  13 pere  staff   416  3 May 16:33 ..
drwxr-xr-x   5 pere  staff   160  3 May 16:34 certs
drwxr-xr-x   3 pere  staff    96  3 May 17:21 crl
-rw-r--r--   1 pere  staff     5  3 May 17:22 crlnumber
drwxr-xr-x   4 pere  staff   128  3 May 16:34 csr
-rw-r--r--   1 pere  staff   109  3 May 17:20 index.txt
-rw-r--r--   1 pere  staff    21  3 May 17:20 index.txt.attr
drwxr-xr-x   3 pere  staff    96  3 May 16:34 newcerts
-rw-r--r--   1 pere  staff  4328  3 May 16:33 openssl.cnf
drwx------   4 pere  staff   128  3 May 16:33 private
-rw-r--r--   1 pere  staff     5  3 May 16:34 serial
```
*NOTE*: This script sets a default password for the certificate, change it if you require to have another one.

### Generating an end user certificate

Once the full CA is setup, next step is to generate end user certificates, to do this you can use a command that look like:

```bash
./create-pair-certs.sh kafka.confluent.local server_cert
```
where the first parameter is the certificate name and the second is the extension being used. For this CA we support server_certs and usr_cert. See the [configs/](configs/) directory for details of the configuration.

### revoke certs

A common process in any CA is to revoke certificates, in with this scripts you can do it like this:

```bash
./revoke-cert.sh kafka.confluent.local
```

this command will revoke a certificate with the name _kakfa.confluent.local_.

Once this command is run, you should an update in the intermediate CA text db like this:

```bash
➜  ca-builder-scripts git:(ca-builder-scripts) ✗ cat ca/intermediate/index.txt
R	200512143408Z	190503152037Z	1000	unknown	/C=DE/ST=Berlin/L=Berlin/O=Confluent Ltd/CN=kafka.confluent.local
```

this means this cert is revoked, so no longer valid


## create certificate revocation lists

To revoke a cert is nice, but you need to announce this to the world, for this you need to create a list of revoked certificates. This you can do using this script:

```bash
./create-crl.sh
```

Once this is run, there will be a new file being created under

```bash
➜  ca-builder-scripts git:(ca-builder-scripts) ✗ ls ca/intermediate/crl
intermediate.crl.pem
```

that will contain the list of revoked certs, this can be used then as part of your distribution points list, to inform clients of the CA which identities are being revoked.


## Common errors

> error 20 at 0 depth lookup:unable to get local issuer certificate

could not find the original file, paths to cerfiticates CA is wrong.

> TXT_DB error number 2 failed to update database

Because you have generated your own self signed certificate with the same CN (Common Name) information that the CA certificate that you’ve generated before.

Enter another Common Name.
