#!/bin/bash

# pull AWS Hosted zones and output to a txt file
aws route53 list-hosted-zones-by-name > hzid.txt

# variables to clean up the output from AWS. Strips down to just the domain you need to modify.
# since there could be multiple domains in the hosted_zone file. 
hzid_grep=$(grep yourdomainhere.com -B 1 hzid.txt) 
hzid_awk=$(awk '/[Z][0-9]{8}/ {print $2}' <<< "${hzid_grep}") 
hzid_sed=$(sed 's|[\",]||g' <<< "${hzid_awk}")
aws route53 list-resource-record-sets --hosted-zone-id $hzid_sed --query "ResourceRecordSets[?Type == 'NS']" > dns_records.txt

# Cleans up DNS records to be used for python
# shell command is basically grep | awk | sed

dns_grep=$(grep Value dns_records.txt)
dns_awk=$(awk '/[ns][-][0-9]{2}/ {print $2}' <<< "${dns_grep}")
dns_sed1=$(sed 's/\"//g' <<< "${dns_awk}")
dns_sed2=$(sed 's/.$//g' <<< "${dns_sed1}") 
echo $dns_sed2 > dns_records.txt
sed -i 's/ /\n/g' dns_records.txt 


