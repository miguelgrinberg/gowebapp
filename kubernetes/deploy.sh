#!/bin/bash

KUBECTL=$(which kubectl || true)
if [[ "$KUBECTL" == "" ]]; then
    echo Please install and configure kubectl for your cluster.
    exit 1
fi

if [[ ! -f gowebapp.yaml ]]; then
    echo Please make the gowebapp/kubernetes your current directory and try again.
    exit 1
fi

# there are two versions of the base64 utility, with different options
BASE64_TEST1=$(base64 -b 0 <<<"test" 2> /dev/null || true)
BASE64_TEST2=$(base64 -w 0 <<<"test" 2>/dev/null || true)
if [[ "$BASE64_TEST1" == "dGVzdAo=" ]]; then
    BASE64="base64 -b 0"
elif [[ "$BASE64_TEST2" == "dGVzdAo=" ]]; then
    BASE64="base64 -w 0"
else
    echo "Unknown base64 utility, don't know how to configure it for single line output."
    exit 1
fi

# mysql passwords
MYSQL_ROOT_PASSWORD=$(cat /dev/urandom | LC_CTYPE=C tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
MYSQL_APP_PASSWORD=$(cat /dev/urandom | LC_CTYPE=C tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
cat > mysql-secrets.yaml <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: mysql
type: Opaque
data:
  root: $(echo -n $MYSQL_ROOT_PASSWORD | $BASE64)
  app: $(echo -n $MYSQL_APP_PASSWORD | $BASE64)
EOF
$KUBECTL create -f ./mysql-secrets.yaml
rm mysql-secrets.yaml

# mysql
$KUBECTL create -f mysql-pv.yaml
$KUBECTL create -f mysql.yaml

printf "Waiting for core services to be up..."
TOTAL=$($KUBECTL get pods --no-headers | wc -l | xargs)
while true; do
    UP=$($KUBECTL get pods --no-headers | grep Running | wc -l | xargs)
    printf "\rWaiting for core services to be up... $UP/$TOTAL"
    if [[ "$TOTAL" == "$UP" ]]; then
        break
    fi
    sleep 5
done
printf "\n"
sleep 10

# initialize mysql database
MYSQL_POD=$($KUBECTL get pod -o custom-columns=name:.metadata.name | grep mysql)
$KUBECTL exec $MYSQL_POD -- mysqladmin --user=root --password="" password $MYSQL_ROOT_PASSWORD
sleep 10
$KUBECTL exec $MYSQL_POD -- mysql -e "CREATE USER IF NOT EXISTS 'gowebapp'@'%' IDENTIFIED BY '$MYSQL_APP_PASSWORD';GRANT ALL PRIVILEGES ON gowebapp.* TO 'gowebapp'@'%' IDENTIFIED BY '$MYSQL_APP_PASSWORD';FLUSH PRIVILEGES;"
$KUBECTL exec $MYSQL_POD -- mysql -e "$(cat ../config/mysql.sql)"

$KUBECTL create -f gowebapp.yaml
