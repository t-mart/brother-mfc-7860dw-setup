# Brother Printer FTP Server

Run an FTP server as a Docker Compose service that is connectable from my old printer, the Brother
MFC-7860DW.

# Steps

1. Run this service:

  ```shell
  docker compose up --detach --build --always-recreate-deps
  ```