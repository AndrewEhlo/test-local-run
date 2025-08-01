FROM mcr.microsoft.com/dotnet/aspnet:8.0

RUN apt-get update && \
    apt-get install -y wget openssl fontconfig libfreetype6 libx11-6 libxcb1 libxext6 libxrender1 xfonts-75dpi xfonts-base libjpeg62-turbo libssl3=3.0.* && \
    wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.bookworm_amd64.deb && \
    dpkg -i wkhtmltox_0.12.6.1-3.bookworm_amd64.deb && \
    rm wkhtmltox_0.12.6.1-3.bookworm_amd64.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY ./publish /opt/virtocommerce/platform

COPY ./wait-for-it.sh /wait-for-it.sh
RUN chmod +x wait-for-it.sh

WORKDIR /opt/virtocommerce/platform
EXPOSE 80
ENV ASPNETCORE_HTTP_PORTS=80
ENTRYPOINT ["dotnet", "VirtoCommerce.Platform.Web.dll"]
