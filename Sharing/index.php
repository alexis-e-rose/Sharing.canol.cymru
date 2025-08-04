<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8" />
</head>
<body>
Welcome to Sharing.Canol.Cymru<br>

<?php
$page = "index";
include("includes/miscfunctions.inc");
include("includes/connect.inc");

if (isset($_POST["Login"]) && $_POST["Login"]=="Login"){ include("includes/login_process.inc");};
if (isset($_GET['logout']) && $_GET['logout']==1)     { include("includes/logout_process.inc");}


include("includes/header2.inc"); 


if (isset($_GET["showlogin"]) && $_GET["showlogin"]==1 )  { include("includes/login_form.inc");}

?>


<?php

//$result -> free_result();
//$mysqli -> close();
?>


</body>
</html>
