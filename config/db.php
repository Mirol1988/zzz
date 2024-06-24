<?php

return [
    'class' => 'yii\db\Connection',
    'dsn' => 'mysql:host='.getenv('MARIADB_HOST').';dbname='.getenv('MARIADB_DATABASE'),
    'username' => getenv('MARIADB_USER'),
    'password' => getenv('MARIADB_PASSWORD'),
    'charset' => 'utf8',

    // Schema cache options (for production environment)
    //'enableSchemaCache' => true,
    //'schemaCacheDuration' => 60,
    //'schemaCache' => 'cache',
];
