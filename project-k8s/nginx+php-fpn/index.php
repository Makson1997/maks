<?php
$ip = getenv('MY_POD_IP') ?: $_SERVER['SERVER_ADDR'];
echo "<h1>My pod IP is: $ip</h1>";

