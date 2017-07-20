#!/bin/sh

# generate a config file for the app
cat > config/config.json <<EOF
{
	"Database": {
		"Type": "${DB_TYPE:=Bolt}",
		"Bolt": {		
 			"Path": "${DB_NAME:=gowebapp.db}"
  		},
		"MongoDB": {
			"URL": "${DB_HOST:=127.0.0.1}",
			"Database": "${DB_NAME:=gowebapp}"
		},
		"MySQL": {
			"Username": "${DB_USER:=root}",
			"Password": "${DB_PASSWORD}",
			"Name": "${DB_NAME:=gowebapp}",
			"Hostname": "${DB_HOST:=127.0.0.1}",
			"Port": ${DB_PORT:=3306},
			"Parameter": "?parseTime=true"
		}
	},
	"Email": {
		"Username": "",
		"Password": "",
		"Hostname": "",
		"Port": 25,
		"From": ""
	},
	"Recaptcha": {
		"Enabled": false,
		"Secret": "",
		"SiteKey": ""
	},
	"Server": {
		"Hostname": "",
		"UseHTTP": true,
		"UseHTTPS": false,
		"HTTPPort": 80,
		"HTTPSPort": 443,
		"CertFile": "tls/server.crt",
		"KeyFile": "tls/server.key"
	},
	"Session": {
		"SecretKey": "@r4B?EThaSEh_drudR7P_hub=s#s2Pah",
		"Name": "gosess",
		"Options": {
			"Path": "/",
			"Domain": "",
			"MaxAge": 28800,
			"Secure": false,
			"HttpOnly": true
		}
	},
	"Template": {
		"Root": "base",
		"Children": [
			"partial/menu",
			"partial/footer"
		]
	},
	"View": {
		"BaseURI": "/",
		"Extension": "tmpl",
		"Folder": "template",
		"Name": "blank",
		"Caching": true
	}
}
EOF

# run the app
exec ./gowebapp
