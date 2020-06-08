#!/usr/bin/python3

import re
import os
import subprocess
import time
import config

def call_bash_script():
    subprocess.call("./cleanup.sh", shell=True)
    time.sleep(10)




def update_dns_fn():
    gdcreds = config.api_key + ":" + config.api_secret
    gd_domain = yourdomain.com
    f = open('dns_records.txt', 'r')
    lines = f.readlines()[-4:]
    f.close()
    char_list = ["'", "\[", "\]"]
    split1 = lines[0].strip().split()
    split1 = re.sub("|".join(char_list), "", str(split1))
    split2 = lines[1].strip().split()
    split2 = re.sub("|".join(char_list), "", str(split2))
    split3 = lines[2].strip().split()
    split3 = re.sub("|".join(char_list), "", str(split3))
    split4 = lines[3].strip().split()
    split4 = re.sub("|".join(char_list), "", str(split4))
    update_dns = 'curl -X PUT \"https://api.godaddy.com/v1/domains/' + gd_domain + '/records/NS/%40\" -H  \"accept: application/json\" -H  \"Content-Type: application/json\" -H  \"Authorization: sso-key ' + gdcreds + '\" -d \"[  {\\"data\\": \\"' + str(split1) + '\\",' + ' \\"ttl\\": 3600},  {\\"data\\": \\"' + str(split2) + '\\", \\"ttl\\": 3600}, {\\"data\\": \\"' + str(split3) + '\\", \\"ttl\\": 3600}, {\\"data\\": \\"' + str(split4) + '\\", \\"ttl\\": 3600}]\"'
    os.system(update_dns)


def cleanup_fn():
    cleanup = "rm dns_records.txt hzid.txt"
    os.system(cleanup)

call_bash_script()
update_dns_fn()
cleanup_fn()
