#!/bin/bash -e

export TZ=${TZ:-"UTC"}
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

echo "date.timezone = ${TZ}"                                    | tee -a /etc/php/${PHP_VERSION}/cli/php.ini /etc/php/${PHP_VERSION}/embed/php.ini
echo "display_errors = ${php_ini_display_errors:=Off}"          | tee -a /etc/php/${PHP_VERSION}/cli/php.ini /etc/php/${PHP_VERSION}/embed/php.ini
echo "error_reporting = ${php_ini_error_reporting:=-1}"         | tee -a /etc/php/${PHP_VERSION}/cli/php.ini /etc/php/${PHP_VERSION}/embed/php.ini
echo "memory_limit=${php_ini_memory_limit:=12288M}"             | tee -a /etc/php/${PHP_VERSION}/cli/php.ini /etc/php/${PHP_VERSION}/embed/php.ini
echo "max_execution_time=${php_ini_max_execution_time:=300}"    | tee -a /etc/php/${PHP_VERSION}/cli/php.ini /etc/php/${PHP_VERSION}/embed/php.ini
echo "post_max_size=${php_ini_post_max_size:=20M}"              | tee -a /etc/php/${PHP_VERSION}/cli/php.ini /etc/php/${PHP_VERSION}/embed/php.ini
echo "upload_max_filesize=${php_ini_upload_max_filesize:=20M}"  | tee -a /etc/php/${PHP_VERSION}/cli/php.ini /etc/php/${PHP_VERSION}/embed/php.ini
echo "upload_tmp_dir=${upload_tmp_dir:='/var/tmp/'}"            | tee -a /etc/php/${PHP_VERSION}/cli/php.ini /etc/php/${PHP_VERSION}/embed/php.ini

# Migrations
docker-hooks.sh

