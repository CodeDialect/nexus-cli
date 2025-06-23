
# Nexus Prover Node One-Click Installer

This script sets up a Nexus Prover Node on any Ubuntu VPS or local Linux machine with a single command. It installs dependencies, prompts you for your wallet and node ID, and runs the node inside a background `screen` session.

---

## 🔧 Features

- Installs required packages (Rust, build tools, etc.)
- Installs and configures the Nexus CLI
- Automatically links your wallet and node
- Runs the node inside a `screen` session for background operation
- Clean and interactive prompts

---

##  🚀 Quick Start
### Install Dependencies 
```bash
sudo apt update && sudo apt install curl -y
```

### Run the script
```bash
bash <(curl -sL https://raw.githubusercontent.com/CodeDialect/nexus-cli/main/nexus_cli_setup.sh)
```

It will prompt you for:
- Your **EVM wallet address**
- Whether you already have a **Node ID**

If yes, you'll be asked to paste your node ID.  
If not, a new node ID will be generated and registered.

---

## 📺 Managing Your Node

### To attach to the running node session:
```bash
screen -r nexus
```

### To detach (leave running in background):
Press: `CTRL+A` then `D`

### To stop the node completely:
```bash
screen -XS nexus quit
```

---

## 🧹 Uninstall Instructions

To remove everything created by the script:
```bash
screen -XS nexus quit || true
rm -rf ~/.nexus ~/.cargo ~/.rustup ~/nexus_autoinstall ~/nexus-network
sed -i '/.cargo\/env/d' ~/.bashrc
exec bash
```

---

## Get Your Node ID

1. Visit: https://app.nexus.xyz
2. Login with your EVM wallet (e.g., MetaMask)
3. Go to: https://app.nexus.xyz/nodes
4. Click **Add Node**  **Add CLI Node**
5. Copy your **Node ID**

Or use CLI:
```bash
nexus-network register-user --wallet-address your-wallet-address
nexus-network register-node
```

---

