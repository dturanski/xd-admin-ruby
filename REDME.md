# XD Admin Ruby

A sample script that reads stream definitions and deployment properties from a Yaml file and securely invokes the REST API:

Example:

`$ xd-admin.rb --server localhost:9393 --username theuser --password aPassword --yaml streams.yml`

Note: if the streams already exist, you'll get a bad request error.
