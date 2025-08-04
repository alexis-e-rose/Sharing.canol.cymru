<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8" />
</head>
<body></body>
    
<?php 
$page = "joingroup";
include("includes/connect.inc");
include("includes/miscfunctions.inc");
include("includes/header.inc"); 


if ($_SESSION['member_ID']>0) {
    echo 'You are logged in as member '. $_SESSION['member_ID'].'<BR>';
    $query6 = "SELECT * FROM members WHERE member_ID = ".qq($_SESSION['member_ID']);
    $result6 = $mysqli -> query($query6);
    $member = $result6 -> fetch_assoc();
} else {
    end;
}

// this page is for callers to join a private group and manage their private groups

if (isset($_POST["joingroup"]) ) {
    $query = 'select * from members where member_email = '.qq($_POST["groupemail"]);
    $result = $mysqli -> query($query);
    $record = $result -> fetch_assoc();
    
    // now the member_ID of hte group adminisstrator is $record["member_ID"]
    $admin =  $record["member_ID"];
    
    // now find the ID of the group
    
    $query = 'select * from communities where member_ID = '.$record["member_ID"].' and password = '.qq($_POST["grouppassword"]);
    $result = $mysqli -> query($query);
    $record = $result -> fetch_assoc();
    
    // now the ID of the group is $record["community_ID"], so add this to the list of communities and membners
    $groupID = $record["community_ID"];
    
    $query = 'INSERT INTO member_communities (member_ID, community_ID) VALUES ( '.qq($_SESSION['member_ID']).' , '.qq($groupID).' )';
    $result = $mysqli -> query($query);
    
}

echo "<br>Type the email address of the group administrator and the password you have been given";
echo '<form name="joingroup" action="joingroup.php" method="post"><table>';
    echo cell2("Group email",'<input type="text" name="groupemail">');
    echo cell2("Password",'<input type="text" name="grouppassword">');
    echo cell2("",'<input type="submit" name="joingroup" value="Join group">');
echo '<form></table>';


// NOW list all the groups you are part of

    echo "These are all the groups you are a member of <br>";

    $query = 'select * from member_communities where member_ID = '.qq($_SESSION['member_ID']);
    $result = $mysqli -> query($query);
    echo '<table>';
    while ( $record = $result -> fetch_assoc() ) {
        
        $query2='select * from communities where community_ID = '.qq($record["community_ID"]);
        $result2 = $mysqli -> query($query2);
        $record2 = $result2 -> fetch_assoc();

        echo cell2($record2["community_name"],"");
        
    }
    echo '</table>';




?>
</body>
</html>
