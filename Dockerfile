FROM mcr.microsoft.com/dotnet/core/sdk:3.1-alpine AS builder
WORKDIR /source
RUN wget -O - \
  `wget -O - "https://api.github.com/repos/yar229/WebDavMailRuCloud/releases/latest" \
    | grep '"tarball_url":' | head -n 1\
    |  sed -E 's/.*"([^"]+)".*/\1/' \
  `| tar -xzf - \
  && mv yar229-WebDavMailRuCloud* WebDavMailRuCloud

RUN dotnet restore WebDavMailRuCloud/WebDAVMailRuCloud.sln
RUN dotnet publish WebDavMailRuCloud/WDMRC.Console/WDMRC.Console.csproj -c Release -f netcoreapp3.0 -r linux-musl-x64 -o /app


FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-alpine
ENV PORT=8010

RUN apk add pound \
  && cat /etc/pound.cfg \
  | head -n `cat /etc/pound.cfg | grep -n ListenHTTP | head -n 1 | awk '{split($0,a,":"); print a[1]}'` \
  >> /etc/pound.cfg.new \
  && mv /etc/pound.cfg.new /etc/pound.cfg \
  && echo -e "ListenHTTPS\r\n Address 0.0.0.0\r\n Port ${PORT}\r\n Cert \"/cert.pem\"" >> /etc/pound.cfg \
  && echo -e " xHTTP 4\r\n Service\r\n  BackEnd\r\n   Address 127.0.0.1\r\n   Port 8011\r\n  End\r\n End\r\nEnd" >> /etc/pound.cfg

WORKDIR /app
COPY --from=builder /app .

EXPOSE ${PORT}
CMD test -f /cert.pem && sh -c "pound -f /etc/pound.cfg && /app/wdmrc -p 8011 -h http://*" || sh -c "/app/wdmrc -p ${PORT} -h http://*"