# ArrStack with VPN-Protected qBittorrent

This docker-compose setup includes qBittorrent running behind a VPN for enhanced privacy and security.

## Setup Instructions

### 1. Environment Configuration
1. Copy the environment file:
   ```bash
   cp env.example .env
   ```

2. Edit `.env` and set your media server path:
   ```bash
   MEDIA_SERVER_PATH=/path/to/your/media/server
   ```

### 2. Surfshark VPN Configuration
1. Create the OpenVPN configuration directory:
   ```bash
   mkdir -p ${MEDIA_SERVER_PATH}/docker/openvpn
   ```

2. Get your Surfshark credentials:
   - Go to https://account.surfshark.com/vpn/manual-setup
   - Note your username and password (these are different from your login credentials)

3. Download Surfshark OpenVPN configuration:
   - Visit https://account.surfshark.com/vpn/manual-setup
   - Download the OpenVPN configuration file for your preferred server location
   - Rename the downloaded file to `surfshark.ovpn`
   - Place it in: `${MEDIA_SERVER_PATH}/docker/openvpn/surfshark.ovpn`

4. Update your `.env` file with your Surfshark credentials:
   ```bash
   SURFSHARK_USERNAME=your_surfshark_username
   SURFSHARK_PASSWORD=your_surfshark_password
   ```

### 3. Starting the Services
```bash
docker-compose up -d
```

### 4. Verification
1. Check if the VPN is working:
   ```bash
   docker exec openvpn curl -s ifconfig.me
   ```
   This should show your VPN IP address, not your real IP.

2. Check qBittorrent logs:
   ```bash
   docker logs qbittorrent
   ```

3. Access qBittorrent Web UI at: http://localhost:8080
   - Default credentials: admin/adminadmin

## How It Works

- The `openvpn` container establishes the VPN connection
- qBittorrent uses `network_mode: "service:openvpn"` which means it shares the network stack with the VPN container
- All traffic from qBittorrent goes through the VPN tunnel
- Other services (Jellyfin, Sonarr, etc.) remain on the regular network

## Troubleshooting

### VPN Connection Issues
1. Check OpenVPN logs:
   ```bash
   docker logs openvpn
   ```

2. Verify your .ovpn file is valid and contains the correct credentials

3. Some VPN providers require additional authentication files (certificates, keys)

### qBittorrent Not Accessible
1. Ensure the VPN container is running:
   ```bash
   docker ps | grep openvpn
   ```

2. Check if qBittorrent is using the VPN network:
   ```bash
   docker exec qbittorrent curl -s ifconfig.me
   ```

## Security Notes

- Only qBittorrent traffic goes through the VPN
- Other services (Jellyfin, Sonarr, Radarr) remain on your local network
- Consider using a kill switch or firewall rules for additional security
- Regularly update your VPN configuration files

## Alternative VPN Images

If you prefer different VPN solutions:

1. **gluetun**: More user-friendly with built-in support for many VPN providers
2. **binhex/arch-qbittorrentvpn**: qBittorrent with built-in VPN
3. **haugene/transmission-openvpn**: Similar setup but for Transmission

## Port Configuration

- qBittorrent Web UI: 8080
- qBittorrent BitTorrent: 6881 (TCP/UDP)
