#!/usr/bin python

"""
#
# create-custom-group-vrops.py contains the python program to automatically create custom groups in vROps as per
# tagging in vCenter Server
# Author Sajal Debnath <sdebnath@vmware.com>
# 2021-11-16   modify by Ron Tsai<rtsai@vmware.com>
# modify to support vRops 8.x 
# create group by custom group
"""
# Importing the Modules

import nagini
import requests
import json
import os, sys
import base64
from requests.packages.urllib3.exceptions import InsecureRequestWarning



# Function to get the absolute path of the script
def get_script_path():
    return os.path.dirname(os.path.realpath(sys.argv[0]))


# Disabling the warning sign for self signed certificates. Remove the below line for CA certificates
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)
#pp = pprint.PrettyPrinter(indent=2)


# Getting the absolute path from where the script is being run
basepath = get_script_path()

# Getting the path of the data and envrionment files
datapath = basepath +"/"+"attributelist.json"
envpath = basepath + "/" + 'env.json'

# Opening the env.json file
with open(envpath) as env_file:
    envinfo = json.load(env_file)

# Getting the information from env.json file

adapter = envinfo["adapterKind"]
resourceknd = envinfo["resourceKind"]
servername = envinfo["server"]["name"]
passwd = base64.b64decode(envinfo["server"]["password"])
uid = envinfo["server"]["userid"]


# connecting to the vROps server, note the Internal APis option

vrops = nagini.Nagini(host=servername, user_pass=(uid, passwd),useInternalApis=True)


# Opening the taglist.json file to get the information
with open(datapath) as data_file:
    data=json.load(data_file)

#print data

# Getting current list of custom groups
getdata = vrops.get_custom_groups()

#print "\n\n\n"

#print json.dumps(getdata)
parseddata = []

# Storing the Custom Group names in parseddata
for information in getdata["groups"]:
    parseddata.append(information["resourceKey"]["name"])

# Creating a set for the data. this will result in fastest search in the list
setdata = set(parseddata)
# If you have created Group Type in vROps with name equal to the name of the TagCategory in vCenter and want to
# create custom groups under the groupt type then change the following parameter to True,
print json.dumps(parseddata)

create_by_tag_category = False

# This is the main portion, here we are creating the custom groups
for info in data:

    # Change the following properties to anything you want to match in the criteria
    properties = "summary|customTag:"+ info["attrKey"]  +"|customTagValue"
    #print  properties
    # If you want to change the compare operator then change the operator value to IS or something that you want
    operator = "CONTAINS"
    # Change the value according to the type you want to use as adapterkindkey
    adapterkindkey = "Container"

    groupName = info["attrKey"] + "-" + info["attrValue"]
    #print groupName 

    # Checking the name of the tag with the existing custom group. If a group exists then skip to the next element
    if groupName in setdata:
        print("Custom Group:: " + groupName + " ::already exists::")
        continue



    resourcekindkey = info["attrKey"] 

    # Generating the JSON data
    proReq = '{ "autoResolveMembership": true,"membershipDefinition": { "excludedResources": [],"includedResources": [],"rules": [ { "propertyConditionRules": [ { "compareOperator": ' \
         '"' + operator + '"' + ',"key":' + '"'+ properties + '"'+ ',"stringValue":' + '"'+ info["attrValue"] + '"'+ '}],"resourceKindKey": \
         { "adapterKind":' + '"'+ adapter + '"' + ',"resourceKind":' + '"'+ resourceknd + '"' + '},"resourceNameConditionRules": [],"relationshipConditionRules": [],"statConditionRules": []}]},"resourceKey": { "adapterKindKey":' + '"'+ adapterkindkey + '"' + ',"name":' + '"'+ groupName + '"'+ \
         ',"resourceIdentifiers": [],"resourceKindKey":' + '"'+ resourcekindkey + '"' + '}}'     

    proReq = json.dumps(json.loads(proReq))
    #print proReq    


     # Creating the custom group
    result=vrops.create_custom_group(proReq)
    #print json.dumps(result)
    







