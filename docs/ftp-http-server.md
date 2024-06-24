# Debian FTP/HTTP Server Setup

This will create:

- An anonymous FTP server for the printer to send scans to. Hosted on port 21.
- An HTTP server for browsing the scans. Hosted on port 5000.

## Steps

1. Create user and group:

   ```bash
   sudo addgroup --system scans
   sudo adduser --system --no-create-home --ingroup scans scans
   ```

2. Install `unftp`:

    (Check if there's a newer version at <https://github.com/bolcom/unFTP/releases>)

   ```bash
   curl -L https://github.com/bolcom/unFTP/releases/download/v0.14.7/unftp_x86_64-unknown-linux-gnu \
   | sudo tee /usr/local/bin/unftp > /dev/null && sudo chmod +x /usr/local/bin/unftp
   ```

3. Install `dufs`

   (Check if there's a newer version at <https://github.com/sigoden/dufs/releases>)

    ```bash
    curl -L https://github.com/sigoden/dufs/releases/download/v0.41.0/dufs-v0.41.0-x86_64-unknown-linux-musl.tar.gz \
    | sudo tar -xz -C /usr/local/bin dufs && sudo chmod +x /usr/local/bin/dufs
    ```

4. Create the unftp service unit file:

    ```bash
    sudo tee /etc/systemd/system/unftp.service > /dev/null <<EOF
    [Unit]
    Description=unftp Service https://unftp.rs/
    After=network.target

    [Service]
    Type=simple
    User=scans
    Group=scans
    ExecStart=/usr/local/bin/unftp --bind-address 0.0.0.0:21 --auth-type anonymous --root-dir /srv/scans --bind-address-http 0.0.0.0:8181 -v
    Restart=on-failure
    RestartSec=5s

    [Install]
    WantedBy=multi-user.target
    EOF
    ```

5. Create the `dufs` service unit file:

    ```bash
    sudo tee /etc/systemd/system/dufs.service > /dev/null <<EOF
    [Unit]
    Description=Dufs File Server https://crates.io/crates/dufs
    After=network.target

    [Service]
    User=scans
    Group=scans
    ExecStart=/usr/local/bin/dufs --config /etc/dufs/dufs.yml
    Restart=on-failure

    [Install]
    WantedBy=multi-user.target
    EOF
    ```

6. Create the `dufs` configuration file:

    ```bash
    sudo mkdir /etc/dufs
    sudo tee /etc/dufs/dufs.yml > /dev/null <<EOF
    serve-path: '/srv/scans'
    bind: 0.0.0.0
    port: 5000
    allow-all: true
    enable-cors: true
    log-file: /var/log/dufs/dufs.log
    EOF
    ```

7. Setup log rotation for `dufs`:

    ```bash
    sudo tee /etc/logrotate.d/dufs > /dev/null <<EOF
    /var/log/dufs/dufs.log {
        daily
        rotate 7
        compress
        delaycompress
        missingok
        notifempty
        create 644 scans scans
    }
    EOF
    ```

8. Create the log directory:

    ```bash
    sudo mkdir /var/log/dufs
    sudo chown scans:scans /var/log/dufs
    ```

9. Create the scan directory:

    ```bash
    sudo mkdir /srv/scans
    sudo chown scans:scans /srv/scans
    ```

10. Start and enable the services:

    ```bash
    sudo systemctl daemon-reload
    sudo systemctl enable unftp dufs
    sudo systemctl start unftp dufs
    ```
