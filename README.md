🕵️‍♂️ Recon Automation Script
Automate subdomain enumeration, asset discovery, and vulnerability reconnaissance using tools like Subfinder, Findomain, crt.sh, Katana, ParamSpider, Waybackurls, RustScan, and more — all in a single Bash script.

📌 Features
Validates and accepts domain input

Automatically checks & installs required tools (macOS Homebrew assumed)

Aggregates subdomains from:

Subfinder

Findomain

crt.sh

Puredns

Assetfinder

Discovers URLs via:

Katana

ParamSpider

Waybackurls

Waymore

Filters sensitive extensions and keywords

IP enumeration and port scanning using:

Shodan

RustScan

Scans vulnerabilities using:

Nuclei

⚙️ Requirements
Make sure the following tools are installed (the script tries to install via Homebrew by default):

figlet

brew (or modify script for apt)

puredns

subfinder

findomain

jq

assetfinder

katana

python3 with paramspider

waybackurls

waymore

shodan

rustscan

nuclei

🔧 You may need to manually configure:

Path to resolvers.txt for puredns

Path to paramspider.py

Nuclei templates directory

📦 Installation
bash
Copy
Edit
git clone https://github.com/yourusername/recon-script.git
cd recon-script
chmod +x recon.sh
🚀 Usage
bash
Copy
Edit
./recon.sh
Follow the prompt to enter your target domain (e.g., example.com). All outputs will be saved in corresponding .txt files.

📁 Output Files
puredns_output.txt

subfinder_output.txt

findomain_output.txt

crtsh_output.txt

assetfinder_output.txt

subdomains.txt – Unique subdomains combined

katana_output.txt

paramspider_output.txt

waybackurls_output.txt

waymore_output.txt

ww.txt – Combined wayback data

ext.txt – URLs with specific extensions

databug/*.txt – Files containing sensitive parameters

IPs.txt – IPs found using Shodan

forRust.txt – Extracted IPs for Rustscan

rustscanRes.txt – Rustscan results

NucleiResults.txt – Nuclei vulnerability findings

📎 Notes
Make sure to set your SHODAN API key before running:

bash
Copy
Edit
shodan init <YOUR_API_KEY>
Ensure your Python environment supports paramspider.

Update any hardcoded paths like:

/path/to/resolvers.txt

/path/to/paramspider.py

/path/to/templates-particular

🛡️ Legal Disclaimer
This script is intended for authorized security testing and educational purposes only. Do not use against systems without proper authorization.

👨‍💻 Author

Rishi 
