<?php
// this processses the logout form
echo 'Logging out';

    unset($_POST['pagespass']);
    unset($_SESSION['member_email']);
    unset($_SESSION['member_ID']);
?>