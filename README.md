# wdmrc-proxy
Docker with application [WDMRC](https://github.com/yar229/WebDavMailRuCloud), can run as https or http webdav server

## https
for run images as https webdav server you should have PEM-certificate
command for run image as https:
```sh
docker run -d -v /root/test/Dockerfile:/cert.pem -p 8010:8010 ivang7/webdav-mailru-cloud:http-and-https
```
if cert not found or it uncorrect then proxy will run on http-mode

## http
for run images as http webdav server you should not set path to cert.pem
```sh
docker run -d -p 8010:8010 ivang7/webdav-mailru-cloud:http-and-https
```