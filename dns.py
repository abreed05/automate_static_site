#!/usr/bin/python3

import re
import os
import subprocess
import time
# imports config.py to use the API key for Godaddy
import config

# A function to call the cleanup.sh script
def call_bash_script():
    subprocess.call("./cleanup.sh", shell=True)
    time.sleep(10)



# Function to actually update the DNS servers at godaddy
def update_dns_fn():

    # gdcreds creates the API string from config.py that the curl command below will need to interact with the godaddyapi
    gdcreds = config.api_key + ":" + config.api_secret

    # gd_domain is the domain you want to modify. 
    gd_domain = yourdomain.com

    # read the dns_records.txt file created by cleanup.sh 
    f = open('dns_records.txt', 'r')
    lines = f.readlines()[-4:]
    f.close()

    # char_list strips bad characters in the dns_records.txt file. Basically more cleanup of the text
    char_list = ["'", "\[", "\]"]

    # split1 - 4 assigns a line from the index of lines and strips away all characters that are not in the ns format
    split1 = lines[0].strip().split()
    split1 = re.sub("|".join(char_list), "", str(split1))
    split2 = lines[1].strip().split()
    split2 = re.sub("|".join(char_list), "", str(split2))
    split3 = lines[2].strip().split()
    split3 = re.sub("|".join(char_list), "", str(split3))
    split4 = lines[3].strip().split()
    split4 = re.sub("|".join(char_list), "", str(split4))

    # update_dns prepare the command to be called. This is just a lot of strings added together to make one complete curl command. 
    update_dns = 'curl -X PUT \"https://api.godaddy.com/v1/domains/' + gd_domain + '/records/NS/%40\" -H  \"accept: application/json\" -H  \"Content-Type: application/json\" -H  \"Authorization: sso-key ' + gdcreds + '\" -d \"[  {\\"data\\": \\"' + str(split1) + '\\",' + ' \\"ttl\\": 3600},  {\\"data\\": \\"' + str(split2) + '\\", \\"ttl\\": 3600}, {\\"data\\": \\"' + str(split3) + '\\", \\"ttl\\": 3600}, {\\"data\\": \\"' + str(split4) + '\\", \\"ttl\\": 3600}]\"'
    
    # Actually calls the curl command through the OS
    os.system(update_dns)

# A cleanup function to remove the tmp files created by cleanup.sh
def cleanup_fn():
    cleanup = "rm dns_records.txt hzid.txt"
    os.system(cleanup)

call_bash_script()
update_dns_fn()
cleanup_fn()
