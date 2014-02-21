#!/usr/bin/env python

#    Puppet module to manage network interface and IP failover.
# 	 Based on Python class provided by OVH as part of API client example resources.
#    Copyright (C) 2014  Benjamin Merot (ben@busyasabee.org)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
# Copyright (c) 2013, OVH SAS.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#* Redistributions of source code must retain the above copyright
#  notice, this list of conditions and the following disclaimer.
#* Redistributions in binary form must reproduce the above copyright
#  notice, this list of conditions and the following disclaimer in the
#  documentation and/or other materials provided with the distribution.
#* Neither the name of OVH SAS nor the
#  names of its contributors may be used to endorse or promote products
#  derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY OVH SAS AND CONTRIBUTORS ``AS IS'' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL OVH SAS AND CONTRIBUTORS BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import requests
import hashlib
import time
import json
import sys
from pprint import pprint

OVH_API_EU = "https://api.ovh.com/1.0"          # Root URL of OVH european API
OVH_API_CA = "https://ca.api.ovh.com/1.0"       # Root URL of OVH canadian API

baseUrl = ""
applicationKey = ""
applicationSecret = ""
consumerKey = ""
    
def timeDelta():
    serverTime = int(requests.get(baseUrl + "/auth/time").text)
    return serverTime - int(time.time())

def requestCredential(accessRules, redirectUrl = None):
    targetUrl = baseUrl + "/auth/credential"
    params = {"accessRules": accessRules}
    params["redirection"] = redirectUrl
    queryData = json.dumps(params)
    q = requests.post(targetUrl, headers={"X-Ovh-Application": applicationKey, "Content-type": "application/json"}, data=accessRules)
    return json.loads(q.text)

def rawCall(method, path, content = None):
    targetUrl = baseUrl + path
    now = str(int(time.time()) + timeDelta())
    body = ""
    if content is not None:
        body = json.dumps(content)
    s1 = hashlib.sha1()
    s1.update("+".join([applicationSecret, consumerKey, method.upper(), targetUrl, body, now]))
    sig = "$1$" + s1.hexdigest()
    queryHeaders = {"X-Ovh-Application": applicationKey, "X-Ovh-Timestamp": now, "X-Ovh-Consumer": consumerKey, "X-Ovh-Signature": sig, "Content-type": "application/json"}
    if consumerKey == "":
        queryHeaders = {"X-Ovh-Application": applicationKey, "X-Ovh-Timestamp": now, "Content-type": "application/json"}
    req = getattr(requests, method.lower())
    # For debug : print "%s %s" % (method.upper(), targetUrl)
    result = req(targetUrl, headers=queryHeaders, data=body).text
    return json.loads(result)
       
def main():
    global baseUrl
    baseUrl = "https://api.ovh.com/1.0"
    response = ""  
    if len(sys.argv) < 4:
         print "Not enough arguments\nExpects: <HTTP_VERB> <PATH> <APPLICATION_KEY> <APPLICATION_SECRET> <CONSUMER_KEY> (<REQUEST_BODY_CONTENT>)"
    else:
        verb = ""
        content = None
        if sys.argv[1].lower() not in ["get", "post"]:
            print "Error"
        else:
            verb = sys.argv[1].lower()
            path = sys.argv[2]
            global applicationKey
            applicationKey = sys.argv[3]
            global applicationSecret
            applicationSecret = sys.argv[4]            
            try:
                global consumerKey
                consumerKey = sys.argv[5]            
                content = dict(ip=sys.argv[6])
            except:
                pass            
            if verb == "get":
                response = rawCall("get", path)
                if response is not None:
                    if "already routed" in response["message"].lower():
                        print response["message"]
                        sys.exit(0)
                    else:
    		    	    sys.exit(1)
                else:
                    sys.exit(1)
            elif verb == "post":
                if "/auth/credential" in path:
                    rules = []
                    rule1 = {"method": "POST", "path": "/dedicated/server/*"}
                    rule2 = {"method": "GET", "path": "/dedicated/server/*"}
                    rules.append(rule1)
                    rules.append(rule2)
                    response = requestCredential(json.dumps(dict(accessRules=rules)))
                    print pprint(response)
                elif "/dedicated/server/" in path:
                    response = rawCall("post", path, content)
                    #print pprint(response)
                    feedback = ""
                    if "message" in response:
                        feedback = response["message"].lower()
                    elif "comment" in response:
                        feedback = response["comment"].lower()
                    print feedback
                    if "already" in feedback:
        		    	sys.exit(0)
                    elif "move" in feedback:
        		    	sys.exit(0)
                    elif "moving" in feedback:
        		    	sys.exit(0)
                    elif "not implemented" in feedback:
        		    	sys.exit(3)
                    else:
        		    	sys.exit(1)
                else:    
                    response = rawCall("post", path, content)
            else:
		    	sys.exit(1)
                		   
if __name__ == "__main__":
    main()