#!/bin/bash

echo "*****setting values from:$setup_file_env*****"
service_url=$1/catalog/content/icd/v1/services
username=$2
apikey=$3
deleteservice=$4

arr=( $(find $parentDirectory -name 'service_*'$4'.json') )
#arr=( $(find $parentDirectory -name 'service_*.json'))

cataloglist=$(curl -k -H "Accept: application/json" -H "username:$username" -H "apikey:$apikey" -X GET "$service_url")

cataloglist=$(echo $cataloglist | tr -d ' ')

ids=$(python -c 'import json;
data = (json.dumps('$(echo $cataloglist)'));
data=json.loads(data)
id = []
for data in data :
	data = data["id"]
	id.append(str(data))
print (id)
	')
	
for i in ${ids[@]}
do

id=$(echo $i | tr -d '[''' |  tr -d '['']' | sed -e 's/,//g'  | tr -d '"' | sed 's/'\''//g')

service_url=$1/catalog/content/admin/icd/v1/services/$id
echo $service_url

echo -e "\nDeleting catalog " $id
curl -k -H "Content-Type: application/json" -H "Accept: application/json" -H "username:$username" -H "apikey:$apikey" -X DELETE "$service_url"

done