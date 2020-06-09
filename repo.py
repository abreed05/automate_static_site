#!/usr/bin/python3

import config
import os

def create_repo_fn():
    domain_name = config.domainname
    gh_token = config.github_token
    repo_cmd = 'curl -H \"Authorization: token ' + gh_token + '" --data \'{"name":"' + domain_name + '", "private":"true"}\' https://api.github.com/user/repos'
    os.system(repo_cmd)


create_repo_fn()
