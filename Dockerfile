FROM mcr.microsoft.com/dotnet/core/sdk:3.1-alpine AS builder
WORKDIR /source
RUN wget -O - \
  `wget -O - "https://api.github.com/repos/yar229/WebDavMailRuCloud/releases/latest" \
    | grep '"tarball_url":' \
    |  sed -E 's/.*"([^"]+)".*/\1/' \
  `| tar -xzf - \
  && mv yar229-WebDavMailRuCloud* WebDavMailRuCloud

RUN dotnet restore WebDavMailRuCloud/WebDAVMailRuCloud.sln
RUN dotnet publish WebDavMailRuCloud/WDMRC.Console/WDMRC.Console.csproj -c Release -f netcoreapp3.0 -r linux-musl-x64 -o /app


FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-alpine
WORKDIR /app
COPY --from=builder /app .

ENV PORT=8010
EXPOSE ${PORT}
CMD /app/wdmrc -p ${PORT} -h http://*
