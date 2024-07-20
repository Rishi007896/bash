#!/bin/bash

# Display 'Recon' in slant font using figlet
figlet -f slant "Recon"

# Display 'MADE BY RISHI'
echo "MADE BY RISHI"

# Prompt user for domain name
echo "Please enter the domain name (e.g., domain.com):"
read domain_name

# Validate the input format
if [[ ! $domain_name =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    echo "Invalid domain name format. Please enter the domain name in the format 'domain.com'."
    exit 1
fi


# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install a tool using Homebrew (assuming macOS)
install_with_brew() {
    if ! command_exists "$1"; then
        echo "Installing $1..."
        brew install "$1"
    fi
}

# Function to install a tool using apt-get (assuming Ubuntu/Debian)
install_with_apt() {
    if ! command_exists "$1"; then
        echo "Installing $1..."
        sudo apt-get install -y "$1"
    fi
}


# Check if puredns is installed; if not, install it
if ! command_exists puredns; then
    install_with_brew puredns  # Replace with appropriate package manager command if not using Homebrew
fi

# Check if subfinder is installed; if not, install it
if ! command_exists subfinder; then
    install_with_brew subfinder  # Replace with appropriate package manager command if not using Homebrew
fi

# Check if findomain is installed; if not, install it
if ! command_exists findomain; then
    install_with_brew findomain  # Replace with appropriate package manager command if not using Homebrew
fi

# Check if jq is installed (needed for crt.sh); if not, install it
if ! command_exists jq; then
    install_with_brew jq  # Replace with appropriate package manager command if not using Homebrew
fi

# Check if assetfinder is installed; if not, install it
if ! command_exists assetfinder; then
    install_with_brew assetfinder  # Replace with appropriate package manager command if not using Homebrew
fi

# Run Puredns
echo "Running Puredns..."
puredns bruteforce /path/to/raw "$domain_name" -r /path/to/resolvers.txt -q >> puredns_output.txt
echo "Puredns scan completed. Output saved to puredns_output.txt"

# Run subfinder
echo "Running subfinder..."
subfinder -d "$domain_name" >> subfinder_output.txt
echo "Subfinder scan completed. Output saved to subfinder_output.txt"

# Run findomain
echo "Running findomain..."
findomain -t "$domain_name" | grep -E '^[a-zA-Z0-9.-]+$' > findomain_output.txt
echo "Findomain scan completed. Output saved to findomain_output.txt"

# Run crt.sh
echo "Running crt.sh..."
curl "https://crt.sh/?q=%.$domain_name&output=json" | jq -r '.[].name_value' | grep -v '*' | sort | uniq >> crtsh_output.txt
echo "crt.sh scan completed. Output saved to crtsh_output.txt"

# Run assetfinder
echo "Running assetfinder..."
assetfinder --subs-only "$domain_name" >> assetfinder_output.txt
echo "Assetfinder scan completed. Output saved to assetfinder_output.txt"

# Combine the outputs and remove duplicates
echo "Combining the outputs and removing duplicates..."
cat puredns_output.txt subfinder_output.txt findomain_output.txt crtsh_output.txt assetfinder_output.txt | sort -u > subdomains.txt
echo "Combined output saved to subdomains.txt"

# Run Katana (assuming katana is installed globally or in the PATH)
echo "Running Katana..."
katana -u subdomains.txt -d 5 | grep -oE 'https?://[a-zA-Z0-9./_-]+' > katana_output.txt
echo "Katana scan completed. Output saved to katana_output.txt"

# Run ParamSpider (assuming paramspider.py is in the current directory or specified path)
echo "Running ParamSpider..."
python3 /path/to/paramspider.py --domain "$domain_name" -p " " | grep -oE 'https?://[^ ]+' > paramspider_output.txt
echo "ParamSpider scan completed. Output saved to paramspider_output.txt"

# Run waybackurls on the domain
echo "Running waybackurls on $domain_name..."
waybackurls "$domain_name" | tee -a waybackurls_output.txt
echo "Output saved to waybackurls_output.txt"

# Run waymore on the domain (assuming waymore.py is in the current directory or specified path)
echo "Running waymore on $domain_name..."
waymore.py -i "$domain_name" -oU waymore_output.txt
echo "Output saved to waymore_output.txt"

# Combine the outputs and remove duplicates
echo "Combining the outputs and removing duplicates..."
cat waybackurls_output.txt waymore_output.txt | sort -u > ww.txt
echo "Combined output saved to ww.txt"

# Define keywords for specific file extensions
extensions=(".js" ".json" ".sql" ".zip" ".txt" ".php" ".aspx" ".env")

# Create ext.txt file to save extensions
> ext.txt

# Loop through each extension and grep the lines containing it from ww.txt
for ext in "${extensions[@]}"; do
    echo "Extracting lines containing extension: $ext"
    grep -i "$ext" ww.txt >> ext.txt
    echo "Lines containing extension saved to ext.txt"
done

# Define keywords for databug
keywords=("redirect=" "redir=" "uri=" ".zip" ".sql" "uuid=" "id=" "refer=" "token=" "verification" "source=" "example=" "sample=" "test=" "users" "password" "jwt" "code" "verification_code" "=false" "=true" "private" "username" "debug" "file=" "path=" "target=" "tar.gz" ".pdf" "return_to=" "apikey" ".js")

# Create a directory to save files
mkdir -p databug

# Loop through each keyword and grep the lines containing it from ww.txt
for keyword in "${keywords[@]}"; do
    echo "Extracting lines containing keyword: $keyword"
    grep -i "$keyword" ww.txt > "databug/$keyword.txt"
    echo "Lines containing keyword saved to databug/$keyword.txt"
done

# Run Shodan to search for IPs
echo -e "[INFO] Starting scan for IPs..."
shodan search "hostname:$domain_name" 200 --limit 1000 --fields ip_str | tee IPs.txt
echo -e "[INFO] All IPs are saved in file: IPs.txt"

# Extract IPs from IPs.txt
grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" IPs.txt > forRust.txt

# Run Rustscan to scan for open ports
echo -e "[INFO] Scanning for open ports..."
rustscan -a 'forRust.txt' -r 1-65535 --ulimit 5000 --scripts none | tee rustscanRes.txt
echo -e "[INFO] Open ports scanned and results saved in rustscanRes.txt"

# Run Nuclei on rustscanRes.txt
echo -e "[INFO] Running Nuclei on Rustscan results..."
nuclei -l rustscanRes.txt -t /path/to/templates-particular | tee NucleiResults.txt
echo -e "[INFO] Nuclei scan completed and results saved in NucleiResults.txt"
