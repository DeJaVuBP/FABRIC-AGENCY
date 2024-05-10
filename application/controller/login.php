<?php
session_start();
function verifyAccount($username, $password)
{
    $xml = simplexml_load_file("../../secret/manager.xml");

    foreach ($xml->account as $account) {
        if ($account->username == $username && $account->password == $password) {
            return true;
        }
    }

    return false;
}
if (isset($_GET["username"]) && isset($_GET["password"])) {
    if (verifyAccount($_GET["username"], $_GET["password"])) {
        $_SESSION["user"] = "admin";
        echo "OK";
    } else {
        session_destroy();
        echo "SAI TÀI KHOẢN HOẶC MẬT KHẨU";
    }
}