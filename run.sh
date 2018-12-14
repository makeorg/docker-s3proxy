#!/bin/sh

# get all env, filter s3proxy config and create properties file
for config in $(env | grep '^S3PROXY'); do
  var=$(echo $config | cut -f1 -d'=')
  value=$(echo $config | cut -f2 -d'=')
  # convert S3PROXY_property_complete__name___1 to property.complete_name-1
  key=$(echo $var | sed 's/^S3PROXY_//g' | tr '_' '.' | sed 's/\.\.\./-/g' | \
    sed 's/\.\./_/g')
  echo "$key=$value" >> s3proxy.properties
done

./s3proxy --properties s3proxy.properties
