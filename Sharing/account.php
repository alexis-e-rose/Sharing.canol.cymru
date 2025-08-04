<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8" />

</head>


<body></body>
    
<?php 
$page = "account";
include("includes/connect.inc");
include("includes/miscfunctions.inc");
include("includes/security_functions.inc");
include("includes/header.inc"); 


if ($_SESSION['member_ID']>0) {
    echo 'You are logged in as member '. $_SESSION['member_ID'].'<BR>';
    $query6 = "SELECT * FROM members WHERE member_ID = ".qq($_SESSION['member_ID']);
    $result6 = $mysqli -> query($query6);
    $member = $result6 -> fetch_assoc();
} else {
    end;
}

// this page is for callers to manage their account


if (isset($_POST["makegroup"]) && $_POST["makegroup"]=="Create group" ) {

    $query = 'insert into communities ( member_ID , community_name , password ) values ( '.$_SESSION['member_ID'].' , '.qq($_POST["groupname"]).' , '.qq($_POST["grouppassword"]).' )';    
    $result = $mysqli -> query($query);
    
    // now find what the community ID is
    $query = 'select * from communities where community_name = '.qq($_POST["groupname"]).' and member_ID = '.$_SESSION["member_ID"].'';
    $result = $mysqli -> query($query);
    $record = $result -> fetch_assoc() ;
    
    // and enter this in the communtiy to members table
    
    $query = 'INSERT INTO member_communities ( member_ID , community_ID ) VALUES ( '.qq($_SESSION["member_ID"]).' , '.qq($record["community_ID"]).')';
    $result = $mysqli -> query($query);
    
}

if (isset($_POST["deletegroup"]) && $_POST["deletegroup"]>0 ) {

    echo $query = 'delete from communities where community_ID = '.$_POST["deletegroup"];    
    $result = $mysqli -> query($query);

}


    $del1 = '<input type="submit" value="'.$record["community_ID"].'" name="deletegroup">';






// process this if the form has been submitted to save the selection of commiunitioes
// this section adds the member to the selected communities
if ($_POST['submitcount']=="Submit" ) {
    echo 'processing the form';
    for ($i=1; $i<=$_POST['rowcount']; $i++) {
        $varname="comm".$i; $varnameb="commb".$i;
        
        if ( isset($_POST[$varname]) ) {
            
            $query = 'select * from member_communities where member_ID = '.$_SESSION['member_ID'].' and community_ID = '.$_POST[$varname];
            $result = $mysqli -> query($query);
            $numrows = mysqli_num_rows($result);
            
            if ( $numrows > 0 ) {
                //echo "an entry already exists";
            } else {
                $query = "insert into member_communities ( member_ID, community_ID ) values ( '".$_SESSION['member_ID']."' , '".$_POST[$varname]."' )";
                $result = $mysqli -> query($query);
            }
        } else {
            $query = "delete from member_communities where member_ID = ".$_SESSION['member_ID']." and  community_ID = ".$_POST[$varnameb];
            $result = $mysqli -> query($query);
        }
    } 
}

// process this if this page has been called by the form on itself
// this section 
if ($_POST['submit2'] == "Re-save") {
    // SECURE VERSION - Password hashing and prepared statements
    
    // Secure input validation
    $fname = secure_input($_POST['fname'], 'string');
    $lname = secure_input($_POST['lname'], 'string');
    $email = secure_input($_POST['email'], 'email');
    $password = secure_input($_POST['pagespass'], 'string');
    $pcode = secure_input($_POST['pcode'], 'string');
    $member_id = secure_input($_SESSION['member_ID'], 'int');
    
    if (!$email || !$member_id) {
        echo '<br>Invalid email format or session. Please try again.';
    } else {
        // Hash password securely
        $hashed_password = secure_password_hash($password);
        
        // Secure update query with prepared statements
        $query = "UPDATE members SET member_fname = ?, member_lname = ?, member_email = ?, member_password = ?, member_pcode = ? WHERE member_ID = ?";
        $params = [$fname, $lname, $email, $hashed_password, $pcode, $member_id];
        
        if (secure_query($query, $params, 'execute')) {
            $_SESSION['member_email'] = $email;
            security_log("User profile updated: " . $email, 'INFO');
            //echo '<br>your email and password have been re-saved securely<br>';
        } else {
            echo '<br>Update failed. Please try again.';
            security_log("Profile update failed for user ID: " . $member_id, 'ERROR');
        }
    }
    $member = $result6 -> fetch_assoc();
} else {
	$passprompt = 1;
}

?>
				<FORM Name = "loginform" METHOD="POST" ACTION="account.php">
					<TABLE ALIGN="left" BORDER=0 CELLSPACING=0 CELLPADDING=4 WIDTH="400" >
						 <?php
						 echo cell2("Enter your first name:",'<INPUT  NAME="fname" TYPE="text" SIZE=20 value ='.qq($member["member_fname"]    ).'>');
						 echo cell2("Enter your last name: ", '<INPUT  NAME="lname" TYPE="text" SIZE=20 value ='.qq($member["member_lname"]   ).'>');
						 echo cell2("Enter your postcode:  ",'<INPUT  NAME="pcode"     TYPE="text" SIZE=20 value ='.qq($member["member_pcode"]    ).'>');
						 echo cell2("Enter your email:     ",'<INPUT  NAME="email"     TYPE="text" SIZE=20 value ='.qq($member["member_email"]    ).'>');
						 echo cell2("Create your password: ",'<INPUT  NAME="pagespass" TYPE="text" SIZE=20 value ='.qq($member["member_password"]).'>');
						 echo cell2(" ",'<INPUT TYPE="SUBMIT" VALUE="Re-save" name="submit2">');
						 ?>
					 </TABLE>
				</FORM>
			<BR clear="all">
<?php

// THIS IS THE FORM FOR SELECTING WHICH COMMUNITY TO BELONG TO       
        
        echo '<br> You can register as a member of the following communities:';
    
        $pcode5 = substr($member["member_pcode"],0,5)."*";
        $pcode6 = substr($member["member_pcode"],0,6)."*";
        $pcode7 = substr($member["member_pcode"],0,7)."*";
        $pcode8 = substr($member["member_pcode"],0,8);

        $query = "SELECT * FROM community_postcode WHERE community_postcode ='".$pcode5."' or community_postcode ='".$pcode6."' or community_postcode ='".$pcode7."' or community_postcode ='".$pcode8."'";
                echo '<br>';
        $result = $mysqli -> query($query);  
        $row_cnt =mysqli_num_rows($result);

        
        echo '<table><FORM Name = "choosecommunity" METHOD="POST" ACTION="account.php">';
        
        for ( $i=1; $i<=$row_cnt; $i++ ) {
            $record = $result -> fetch_assoc();
            $query2 = 'select * from communities where community_ID = '.$record["community_ID"];
            $result2 = $mysqli -> query($query2) ;      $record2 = $result2 -> fetch_assoc() ;
            
       
       
            $query6 = 'select * from member_communities where member_ID = '.qq($_SESSION["member_ID"]).' and community_ID = '.qq($record["community_ID"]);
            $result6 = $mysqli -> query($query6);
            $row6 = mysqli_num_rows($result6);

            $temp3 = "comm".$i; $temp3b = "commb".$i;
            if ($row6>0){ $ch6=' checked="true" ' ; } else { $ch6= ""; }
            $temp1 = '<INPUT NAME="'.$temp3.'" value="'.$record2["community_ID"].'" TYPE="checkbox" '.$ch6.' ><INPUT NAME="'.$temp3b.'" value="'.$record2["community_ID"].'" TYPE="hidden" >';
            $temp2 = qq($record2["community_name"]);
            
            echo cell3("",$temp2,$temp1);
        }
        echo cell2('<input type="hidden" name="rowcount" value="'.$row_cnt.'">','<input name="submitcount" type="submit" value="Submit">');
        
        echo '</FORM></table>';


echo '<br>';
echo '<br> Create a private group';

echo '<table><form name="createprivategroup" method="post" action="account.php">';
echo cell2("Group name",'<input type="text" name="groupname">');   
echo cell2("Group password",'<input type="text" name="grouppassword">');   
echo cell2('','<input type="submit" name="makegroup" value="Create group" >');   

echo '</form></table>';


// now list my private groups

echo '<br>These are my existing private groups';
$query = "select * from communities where member_ID = ".$_SESSION['member_ID'];
$result = $mysqli -> query($query);
echo '<table><form name="editgroups" action="account.php" method="post">';
while ($record = $result -> fetch_assoc() ) {
    
    $del1 = '<input type="submit" value="'.$record["community_ID"].'" name="deletegroup">';
    echo cell3($record["community_name"],$record["password"],$del1);
}
echo '</form></table>';




?>
</body>
</html>
