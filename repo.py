import config
import os
import requests

def create_repo_fn():
   
    repo_url = "https://api.github.com/user/repos"
    repo_headers = {'Authorization':"Token "+config.github_token}
    repo_payload = {"name": config.domainname, 'private': 'true'}
    requests.post(repo_url, headers=repo_headers, json=repo_payload)

create_repo_fn()
