# 🚀 SSH Security Auto Setup
**Automatically change root password + change SSH port to 1632 + disable port 22 + smooth loading effect**

This tool configures SSH security with **a single command**.  
Compatible with most Linux distributions: *Ubuntu, Debian, Rocky Linux, AlmaLinux, CentOS…*

---

## 🔒 Features

- ✔️ **Change root password** (default: `tbao123`)  
- ✔️ **Change SSH port to 1632**  
- ✔️ **Disable port 22 completely**  
- ✔️ **Automatically open firewall for the new port**  
- ✔️ **Pre-check configuration for errors before applying**  
- ✔️ **Automatically restart SSH service**  
- ✔️ **Smooth loading effect – beautiful console interface**  

---

## 🛠️ Usage

### 1️⃣ Run directly via curl

```bash
curl -sSL https://raw.githubusercontent.com/Quangqq/chageportssh/refs/heads/main/run.sh | bash
```

==========================================
     🚀 SSH SECURITY AUTO CONFIGURE 🚀
==========================================

▶ Changing root password...
⠋⠙⠸⠼⠴ Loading...
✔ Success!

▶ Changing SSH port to 1632...
⠇⠧⠏⠛ Loading...
✔ New port enabled!

▶ Restarting SSH...
✔ Done! 🎉

➡ Please log in using port 1632
##
⚠️ Important Notes

Port 22 will be permanently disabled after the script runs.

Open an additional SSH window before running the script to avoid locking yourself out.

If a firewall (UFW / firewalld) is active, the script will automatically open the correct port.

❤️ Contribution

All improvement ideas are welcome.
Feel free to open an issue or send a pull request to support multiple ports or advanced options.

📄 License

MIT License — free to use & modify.
