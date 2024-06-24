#!/bin/bash -e

[[ -z "$MIGRATIONS" ]] || { echo "Migrations.."; php ./console.php migrate --interactive=0 ; }
printenv | grep -v 'UB_MARIADB_HOST|UB_MARIADB_PORT|UB_MARIADB_DATABASE|UB_MARIADB_USER|UB_MARIADB_PASSWORD|REDIS_HOST|REDIS_PORT|REDIS_INDEX|TELEGRAM_TOKEN|SCRAM_URL|IP|PORT|USERNAME|PASSWORD' > /etc/environment
#cron
