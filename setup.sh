echo "*****setting values from:$setup_file_env*****"
config_value_domain_url=$1/catalog/content/admin/icd/v1/configvaluedomain
apikey_username=$2
apikey=$3
privateservice=$4

service_url=$1/catalog/content/admin/icd/v1/services
echo service_url
arr=( $(find . -name 'service_*'$4'.json'))

##arr=( $(find . -name 'service_*.json') )

for i in ${arr[@]}
do

filepath=${i//\\//}

filepathlogo=$filepath

IFS='/' read -ra ADDR <<< "$filepath"
lastIndexOfFilepath=$(expr ${#ADDR[@]} - 1)
filename=${ADDR[$lastIndexOfFilepath]}
filenameWithoutExtension=$(echo $filename | cut -f 1 -d '.')

echo -e "\nUploading Catalog - "$filenameWithoutExtension
echo $filepath

filedet=$(cat $filepath)
#echo $filedet

curl -k -H "Content-Type: application/json" -H "Accept: application/json" -H "username:$apikey_username" -H "apikey:$apikey" -X POST -d  @"$filepath" "$service_url"

echo  $filepathlogo

if [[ $filepathlogo != *"Traditional_IT"*  ]]
then
echo -e "\n\nAdding Provider Logo - "$filenameWithoutExtension

logofilename="icd_logo.png"

if [ -e $(eval echo ./$logofilename) ]
then
	echo "Uploading logo file $logofilename"

	service_id=$(cat $filepath | grep -m1 id | awk '{print$2}' | sed -e 's/,//g' | tr -d '"')
	service_id=${service_id%$'\r'}

	logo_url=$(read_variable consume_hostname)/catalog/v3/admin/providers/icd/services/$service_id/images
	#echo $logo_url

	curl -k -H "Content-Type:multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW" -H "username:$apikey_username" -H "apikey:$apikey" -X POST -F "image=@$logofilename" "$logo_url"

else
	echo "No logo file found. Skipping logo upload."
fi	

fi

done