# A Brief History 

The reason behind this particular repo is simple. It was done for learning purposes. 
For a while I have been playing around in AWS. I was creating static sites manually and 
using hugo + AWS' codepipeline to deploy content from Github to S3. Easy enough. 

But the setup of the infrastructure it ran on was all manual. So anytime I needed to standup 
a new static site for whatever reason I need to create the hosted zone, update the DNS servers with godaddy, 
create the S3 buckets, create the DNS record to validate for an ACM certificate, and create the Cloudfront 
distribution. A lot of work that really needed to be automated. 

This particular problem granted me the opportunity to learn a bit of TF and go beyond what the guides on the 
interent go into. 


# How This project works 

This project is fairly basic with one unique twist I think updating the domain registras NS servers. 
If you purchased your domain through AWS this isn't an issue. But lots of people purchase through godaddy, namecheap, 
or some other domain registrar. For me it's Godaddy. 

DNS.py is the script that solves the updating of the domain registrar. 

It uses the aws cli to pull down the recenly created hostedzone name servers and
put them in a format that dns.py can use. The script then reads the txt file that was created. Assigns each line in the file as a variable and
makes a request to the Godaddy API with the updated name name servers and finally cleansup the tmp files generated earlier. 

Because the Godaddy API requires an API key I have also created a config.py script with two variables that are imported to dns.py
The two variables are api_key and api_secret. This is so the API key can be kept out of source. 

# Terraform 

The terraform files are fairly straightforward. There are 3 files main.tf, variables.tf, and provider.tf. 

main.tf is the main tf file. Nothing should need to be changed in here. 
variables.tf contains the domain name variable for use in main.tf 
provider.tf simply tells terraform which provider to use and in what region to build the resources. 

Overall the project is fairly simple and should be able to be used with minimal editing. 
