#!/bin/bash

domain="$1"

if [ -z "$1" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

re="\e[0m"
r="\e[31m"
g="\e[32m"
b="\e[1;34m"
p="\e[1;35m"
c="\e[36m"
m="\033[35m"
o="\033[33m"
y="\033[1;33m"
bold="\e[1m"

#domain="$1"

echo "[+]------ Starting Passive Subdomain Enumeration ------[+]"

#running_assetfinder
echo "[+] Started collecting with Assetfinder [+]"
assetfinder -subs-only $domain 2> /dev/null 1> assetfinder.txt
echo -e "${bold}${y}$(cat assetfinder.txt | wc -l assetfinder.txt | grep -Eo '[0-9]*') valid subdomains found from assetfinder ${re}\n"

#running_subfinder
echo "[+] Started collecting with Subfinder [+]"
subfinder -d $domain -pc ~/.config/subfinder/provider-config.yaml -nW -silent 2>/dev/null 1> subfinder.txt
echo -e "${bold}${y}$(cat subfinder.txt | wc -l subfinder.txt | grep -Eo '[0-9]*') valid subdomains found from subfinder ${re}\n"


#running_findomain
echo "[+] Started collecting with Findomain [+]" 
findomain -t https://$domain -q 2>/dev/null 1>> findomain.txt
echo -e "${bold}${y}$(cat findomain.txt | wc -l findomain.txt | grep -Eo '[0-9]*') valid subdomains found from findomain ${re}\n"

#running_github-subdomains
echo "[+] Started collecting with Github-Subdomains [+]"
github-subdomains -d $domain -t ~/.tokens -o 2>/dev/null 1>> gitsub.txt 
echo -e "$(cat gitsub.txt | wc -l gitsub.txt | grep -Eo '[0-9]*') valid subdomains found from findomain ${re}\n"

#running_crt.sh
echo "[+] Started collecting with crt.sh [+]"
bash ~/bin/crt.sh $domain
echo -e "${bold}${y}$(cat crtsubs.txt | wc -l crtsubs.txt | grep -Eo '[0-9]*') valid subdomains found from crt.sh ${re}\n"

#making_passive_subs_file_&_removing_duplicates
echo "[+] Creating single files of passive subdomains and removing duplicate values [+]"
cat assetfinder.txt subfinder.txt findomain.txt gitsub.txt crtsubs.txt | sort -u > passive.txt

#deleting_other_files
echo "[+] Deleting other files [+]"
rm assetfinder.txt subfinder.txt findomain.txt gitsub.txt crtsubs.txt 


echo "[+]------- Starting Active Subdomain Enumeration  ------- [+]"


#running_puredns
echo "[+] Started bruteforce and resolving subdomains  [+]"
puredns bruteforce ~/wordlists/subs.txt $domain -r ~/wordlists/resolvers.txt -w active.txt

#making_active_&_passive_file_&_removing_duplicates
echo "[+] Making single file of passive and active subdomains  [+]"
cat active.txt passive.txt | sort -u > test.txt

#creating_final_file
echo "[+] Creating final file [+]"
cat test.txt | grep -Eo "[^*]+" | sort -u > final.txt

#removing_garbages
echo "[+] Removing extra files [+]"
rm active.txt passive.txt test.txt
