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

if ($_POST["Login"]=="Login"){ include("includes/login_process.inc");};
if ( $_GET['logout']==1)     { include("includes/logout_process.inc");}


include("includes/header2.inc"); 


if ($_GET["showlogin"]==1 )  { include("includes/login_form.inc");}

?>


<?php

//$result -> free_result();
//$mysqli -> close();
?>


</body>
</html>
