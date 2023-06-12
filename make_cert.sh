#/bin/bash

rm -rf ssl
mkdir ssl
cd ssl

openssl genrsa -aes256 -out privkey_cert.key 4096
openssl req -new -key privkey_cert.key -out cacert.csr
openssl x509 -req -in cacert.csr -signkey privkey_cert.key -days 3650 -extensions v3_ca -out cacert.pem

openssl genrsa -aes256 -out privkey_withpasswd.key 4096
openssl req -new -key privkey_withpasswd.key -out server.csr

openssl rsa -in privkey_withpasswd.key -out server.key

openssl x509 -req -in server.csr -CA cacert.pem -CAkey privkey_cert.key -CAcreateserial -extfile ../subjectnames.txt -days 730 -out server.crt

cd ..
mv -f ./ssl ~/
