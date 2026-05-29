<?php
return [
  'paths' => ['api/*', 'sanctum/csrf-cookie', 'storage/*'],
  'allowed_methods' => ['*'],
  'allowed_origins' => ['*'], // em produção troque por ['http://seu-front:porta']
  'allowed_headers' => ['*'],
  '.htaccess' => false,
  'exposed_headers' => [],
  'max_age' => 0,
  'supports_credentials' => false,
];