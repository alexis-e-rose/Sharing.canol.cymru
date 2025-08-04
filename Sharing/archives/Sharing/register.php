<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8" />

</head>


<body></body>
    
<?php 
$page = "register";
include("includes/connect.inc");
include("includes/miscfunctions.inc");
include("includes/header2.inc"); 

if (isset($_SESSION['member_ID']) && $_SESSION['member_ID'] > 0 ) {
    $query = "select * from members where member_ID = ".$_SESSION['member_ID'];
    $result = $mysqli -> query($query);
    $member = $result -> fetch_assoc();
    echo 'You are logged in as '. $member['member_fname'].'<BR>';
    
}
//$result -> free_result();
//$mysqli -> close();

// this page is for callers to enter a name and password


$pagespass = $_POST['pagespass'];
//$member_email = $_POST['email'];


// process this if the form has been submitted to save the selection of commiunities

if ($_POST['submitcount']=="Submit" ) {
    //echo 'processing the form';
    //echo '<BR>'.$_POST['submitcount'];
    //echo '<BR>'.$_POST['rowcount'];
    //echo 'You are logged in as member '. $_SESSION['member_ID'].'<BR>';
    //echo '<BR>';
    
    for ($i=1; $i<=$_POST['rowcount']; $i++) {
        $varname = "comm".$i;
        $query = "insert into member_communities ( member_ID, community_ID ) values ( '".$_SESSION['member_ID']."' , '".$_POST[$varname]."' )";
        $result = $mysqli -> query($query);
    } 
}

// process this if this page has been called by the form on itself
if ($_POST['submit2'] == "Register") {


    // first check if the email is already registered
    $query5 = "select * from members where member_email = ".qq($_POST['email']);
    $result5 = $mysqli -> query($query5);
    $numrows =mysqli_num_rows($result5);
    if ( $numrows > 0 ) {
        echo 'This email address is already registered. login with your existing account';
        end;
    }


    $temp2 = $_POST['pagespass'];
    $query = "INSERT INTO members (`member_fname`, `member_email`, `member_password`, `member_lname`, `member_pcode`) VALUES ('".$_POST['fname']."', '".$_POST['email']."', '".$temp2."', '".$_POST['lname']."', '".$_POST['pcode']."')";

    $result = $mysqli -> query($query);
    echo '<br>your email and password have been registered<br>';
    $_SESSION['member_email'] = $_POST['email'];
    
    
    $query3 = 'select * from members where member_email = "'.$_POST['email'].'"';
    $resulttemp = $mysqli -> query($query3);
    $recordtemp = $resulttemp -> fetch_assoc();
    
    
    $_SESSION['member_email'] = $_POST['email'];
    $_SESSION['member_ID'] = $recordtemp["member_ID"];
    //echo 'setting session member ID to '.  $_SESSION['member_ID'];

    echo '<BR>You are logged in as '.$recordtemp["member_fname"];
    echo '<br> You can register as a member of the following communities:<br>';

        $pcode5 = substr($_POST["pcode"],0,5)."*"; $pcode6 = substr($_POST["pcode"],0,6)."*"; $pcode7 = substr($_POST["pcode"],0,7)."*"; $pcode8 = substr($_POST["pcode"],0,8);

        $query = "SELECT * FROM community_postcode WHERE community_postcode ='".$pcode5."' or community_postcode ='".$pcode6."' or community_postcode ='".$pcode7."' or community_postcode ='".$pcode8."'";

        $result = $mysqli -> query($query);  
        $row_cnt = $result->num_rows;

        //echo 'There are '.$row_cnt.' results <br>';
       
       
// THIS IS THE FORM FOR SELECTING WHICH COMMUNITY TO BELONG TO       
        
        echo '<FORM Name = "choosecommunity" METHOD="POST" ACTION="register.php">';
        
        for ( $i=1; $i<=$row_cnt; $i++ ) {
        
            $record = $result -> fetch_assoc();
            $query2 = "select * from communities where community_ID = ".$record["community_ID"]."";
            $result2 = $mysqli -> query($query2) ;
            $record2 = $result2 -> fetch_assoc() ;
            //echo 'Row    '.$i.'   ' ;
            echo $record2["community_ID"];
            echo ' <INPUT NAME="comm'.$i.'" value="'.$record["community_ID"].'" TYPE="checkbox" >';
            echo ' <input type="hidden" name="rowcount" value="'.$row_cnt.'">';
            echo ' <input type="hidden" name="memberID" value="'.$row_cnt.'">';

            
            echo ' '.$record2["community_name"].'<br>';
        }
        echo ' <input name="submitcount" type="submit" value="Submit">';
        echo '</fORM>';


} else {
	$passprompt = 1;
}

if (isset($_SESSION["member_ID"])) {

    echo 'You are now a member of these communities <BR>';
    
    $query = "select * from member_communities where member_ID = ".$_SESSION["member_ID"];
    $result = $mysqli -> query($query) ;
    while ($record = $result -> fetch_assoc() ) {
        
        $query2 = "select * from communities where community_ID = ".$record['community_ID']."";
        $result2 = $mysqli -> query($query2) ;
        $record2 = $result2 -> fetch_assoc();
        echo $record2["community_name"].'<BR>';
        
    }

}




if (!isset(	$_SESSION['member_email'])){

?>


<TABLE CELLPADDING=0 CELLSPACING=0 BORDER=0 WIDTH=100%>

	<TR>
		<TD WIDTH=50>&nbsp;

		</TD>

		<TD ALIGN=left CLASS="bodytext">
			<BR><BR>

				<FORM Name = "loginform" METHOD="POST" ACTION="register.php">
					<TABLE ALIGN="left" BORDER=0 CELLSPACING=0 CELLPADDING=4 WIDTH="400" >

						 <TR>
						 <TD VALIGN="top" >
							 Enter your first name:
						 </TD>
						 <TD VALIGN="top">
							 <INPUT  NAME="fname" TYPE="text" SIZE=20>
							 <BR><BR>
						 </TD>
						 </TR>

						 <TR>
						 <TD VALIGN="top" >
							 Enter your last name:
						 </TD>
						 <TD VALIGN="top">
							 <INPUT  NAME="lname" TYPE="text" SIZE=20>
							 <BR><BR>
						 </TD>
						 </TR>

						 <TR>
						 <TD VALIGN="top" >
							 Enter your post code:
						 </TD>
						 <TD VALIGN="top">
							 <INPUT  NAME="pcode" TYPE="text" SIZE=20>
							 <BR><BR>
						 </TD>
						 </TR>


						 <TR>
						 <TD VALIGN="top" >
							 Enter your email address here:
						 </TD>
						 <TD VALIGN="top">
							 <INPUT  NAME="email" TYPE="text" SIZE=20>
							 <BR><BR>
						 </TD>
						 </TR>

						 <TR>
						 <TD VALIGN="top" >
							 Enter your password here:
						 </TD>
						 <TD VALIGN="top">
							 <INPUT  NAME="pagespass" TYPE="PASSWORD" SIZE=20>
							 <BR><BR>
						 </TD>
						 </TR>
						 <TR>
						 <TD VALIGN="top" >

						 </TD>
						 <TD VALIGN="top">
							 <INPUT TYPE="SUBMIT" VALUE="Register" name="submit2">
						 </TD>
						 </TR>
					 </TABLE>
				</FORM>
			<BR clear="all">

	<BR><BR>
	</TD>
	</TR>
</TABLE>

<?php
}
?>

</body>
</html>
