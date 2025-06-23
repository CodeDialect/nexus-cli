#!/bin/bash
set -e

# === Colors for output ===
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
NC="\033[0m"

# BANNER
echo -e "${GREEN}"
cat << 'EOF'
 ______              _         _                                             
|  ___ \            | |       | |                   _                        
| |   | |  ___    _ | |  ____ | | _   _   _  ____  | |_   ____   ____  _____ 
| |   | | / _ \  / || | / _  )| || \ | | | ||  _ \ |  _) / _  ) / ___)(___  )
| |   | || |_| |( (_| |( (/ / | | | || |_| || | | || |__( (/ / | |     / __/ 
|_|   |_| \___/  \____| \____)|_| |_| \____||_| |_| \___)\____)|_|    (_____)
EOF
echo -e "${NC}"


echo -e "${YELLOW}>> Updating system and installing dependencies...${NC}"
sudo apt update && sudo apt upgrade -y
sudo apt install screen curl build-essential pkg-config libssl-dev git-all protobuf-compiler -y

# === Check if cargo and rustup are already installed ===
if command -v cargo >/dev/null 2>&1 && command -v rustup >/dev/null 2>&1; then
    echo -e "${GREEN}>> Rust and Cargo are already installed. Skipping installation.${NC}"
else
    echo -e "${YELLOW}>> Installing Rust and Cargo...${NC}"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
fi

# Ensure cargo is in PATH
export PATH="$HOME/.cargo/bin:$PATH"

echo -e "${YELLOW}>> Adding target for Nexus...${NC}"
rustup target add riscv32i-unknown-none-elf

echo -e "${YELLOW}>> Installing Nexus CLI...${NC}"
curl https://cli.nexus.xyz/ | sh
# Ensure nexus-network binary is in PATH
export PATH="$HOME/.nexus/bin:$PATH"
echo 'export PATH="$HOME/.nexus/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
# === Prompt user for wallet address and node ID ===
read -p "Enter your EVM Wallet Address: " WALLET_ADDRESS
read -p "Do you already have a Node ID? (y/n): " HAS_NODE

# === Generate inner script ===
mkdir -p ~/nexus_autoinstall
INSTALL_SCRIPT=~/nexus_autoinstall/run_node.sh
cat > "$INSTALL_SCRIPT" <<EOF
#!/bin/bash
source \$HOME/.cargo/env
export PATH=\$HOME/.cargo/bin:\$PATH

echo -e "${YELLOW}>> Registering user...${NC}"
nexus-network register-user --wallet-address $WALLET_ADDRESS

EOF

if [[ "$HAS_NODE" == "y" || "$HAS_NODE" == "Y" ]]; then
  read -p "Enter your existing Node ID: " NODE_ID
  echo "nexus-network start --node-id $NODE_ID" >> "$INSTALL_SCRIPT"
else
  cat >> "$INSTALL_SCRIPT" <<EOF
echo -e "${YELLOW}>> Creating new Node ID...${NC}"
nexus-network register-node
nexus-network start
EOF
fi

chmod +x "$INSTALL_SCRIPT"

# === Start screen session ===
echo -e "${YELLOW}>> Starting Nexus node in screen session...${NC}"
screen -dmS nexus bash -c "$INSTALL_SCRIPT; exec bash"

echo -e "${GREEN}✅ Nexus node setup complete. Running in screen session named 'nexus'.${NC}"
echo -e "${YELLOW}>> To attach: screen -r nexus"
echo -e ">> To detach: CTRL+A then D"
echo -e ">> To kill: screen -XS nexus quit${NC}"
