#!/bin/bash

# Colors 
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' 

# usage
usage() {
    echo -e "${YELLOW}"
    cat << "EOF"
     (        (              (     
     )\ )     )\ )    (      )\ )  
    (()/( (  (()/(    )\    (()/(  
     /(_)))\  /(_))((((_)(   /(_)) 
    (_)) ((_)(_))_  )\ _ )\ (_))   
    | _ \| __||   \ (_)_\(_)| _ \  
    |   /| _| | |) | / _ \  |   /  
    |_|_\|___||___/ /_/ \_\ |_|_\  
                                

                                              
EOF
    echo -e "${PURPLE}  Recon Automation Framework"
    echo -e "${CYAN}  Developed by 0x1C3B00DA${NC}"
    echo ""
    echo "Usage: $0 --mode <mode> --target <target_file>"
    echo "  --mode    Mode of operation (1 or 2)"
    echo "  --target  Target file containing domains"
    exit 1
}

# gather subdomains
gather_subdomains() {
    local input_file=$1
    echo -e "${BLUE}[+] Running Amass...${NC}"
    sudo amass enum -passive -norecursive -noalts -df $input_file -o amass.txt

    echo -e "${GREEN}[+] Running Subfinder...${NC}"
    subfinder -dL $input_file -v -t 25 -o subfinder.txt

    echo -e "${YELLOW}[+] Running Subdominator...${NC}"
    subdominator -dL $input_file -o subdominator.txt -cp /home/.config/subdominator/config_keys.yaml

    echo -e "${PURPLE}[+] Running Assetfinder...${NC}"
    cat $input_file | assetfinder > assetfinder.txt

    echo -e "${BLUE}[+] Combining and sorting results...${NC}"
    sort -u amass.txt subfinder.txt subdominator.txt assetfinder.txt > sortedDomains.txt

    echo -e "${GREEN}[+] Filtering in-scope domains...${NC}"
    while IFS= read -r domain; do
        grep -e "$domain" sortedDomains.txt
    done < $input_file > Domains.txt

    echo -e "${YELLOW}[+] Checking for subdomain takeover vulnerabilities...${NC}"
    subzy run --targets Domains.txt --vuln --output SubdomainTakeover-subzy.txt

    echo -e "${PURPLE}[+] Finding alive domains...${NC}"
    cat Domains.txt | ~/go/bin/httpx > alive.txt


#    echo -e "${GREEN}[+] Performing visual reconnaissance with Eyewitness...${NC}"
#   Eyewitness -f alive.txt --web -d Eyewitness --no-prompt
}

# for mode 1
mode_1() {
    gather_subdomains $1
}

# for mode 2
# mode_2() {
#     gather_subdomains $1
#     echo -e "${CYAN}[+] Performing visual reconnaissance with Eyewitness...${NC}"
#     Eyewitness -f alive.txt --web -d Eyewitness --no-prompt
# }

# Parse command line arguments
MODE=""
TARGET_FILE=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --mode) MODE="$2"; shift ;;
        --target) TARGET_FILE="$2"; shift ;;
        *) usage ;;
    esac
    shift
done

# Validate arguments
if [[ -z "$MODE" || -z "$TARGET_FILE" ]]; then
    usage
fi

# Execute the selected mode
case $MODE in
    1)
        mode_1 $TARGET_FILE
        ;;
    2)
        mode_2 $TARGET_FILE
        ;;
    *)
        echo -e "${RED}Invalid mode selected. Use 1 or 2.${NC}"
        usage
        ;;
esac

echo -e "${CYAN}Reconnaissance completed.${NC}"


