<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8" />

</head>


<body>
    
<?php 
$page = "create_private";
include("includes/connect.inc");
include("includes/miscfunctions.inc");
include("includes/header.inc"); 


// this page is for a member to create a private group




if ( isset($_SESSION["member_ID"]) ) {
    echo 'You are logged in as member '. $_SESSION['member_ID'].'<BR><br>';
} else {
    echo "you cannot access this page";
    end;
}


echo $query = "SELECT * FROM member_communities WHERE member_ID = ".qq($_SESSION["member_ID"]);
        echo '<BR>';

$result =  $result = $mysqli -> query($query);
$rowcount=mysqli_num_rows($result);

if ( $rowcount == 0) {
    echo 'You are not a member of any groups yet<br>';
} else {
    
    while ($record = $result -> fetch_assoc() ) {
        echo $query2 = "SELECT * FROM `communities` WHERE community_ID = ".qq($record["community_ID"]);
        echo '<BR>';
    }
    
    
}






end;

//echo 'thing_ID is '.$_POST["thing_ID"];
$this_thing_ID = $_POST["thing_ID"];


// check if calling from itself

if ($_POST["checkword"] == "check") {
    if ( $_POST["thing_ID"] == 0) {
            $query = " INSERT INTO things (thing_title, thing_price, thing_type, thing_ratio, thing_description, thing_member_ID,  thing_image) ".
                " VALUES ( ".
                qq($_POST["thing_title"]).", ".
                qq($_POST["thing_price"]).", ".          
                qq($_POST["thing_type"]).", ".
                qq($_POST["thing_ratio"]).", ".
                qq($_POST["thing_description"]).", ".                 
                qq($_SESSION["member_ID"]).", ".         
                qq($_POST["thing_image"])." )";
                
                $result = $mysqli -> query($query);
        
                $query2 = "SELECT thing_ID FROM things WHERE 1 order by thing_ID DESC";
                $result2 = $mysqli -> query($query2); $record2 = $result2 -> fetch_assoc() ;
                $this_thing_ID = $record2["thing_ID"];
        
        } else {
            $this_thing_ID = $_POST["thing_ID"];
            $query = " update things set ".
                " thing_description = ".qq($_POST["thing_description"])." ,". 
                " thing_price       = ".qq($_POST["thing_price"])." ,". 
                " thing_type        = ".qq($_POST["thing_type"])." ,". 
                " thing_ratio       = ".qq($_POST["thing_ratio"])." ,".    
                " thing_title       = ".qq($_POST["thing_title"])." ". 
                " where thing_ID = ".qq($this_thing_ID)." ";
            
            $result = $mysqli -> query($query);
            //echo '<br>You have just altered item number '.$this_thing_ID.'<br>';

        }
        //echo ' <be> this thing ID is '.$this_thing_ID;
        //echo '<BR><BR>';
        $query = "SELECT * FROM things WHERE thing_ID = ".$this_thing_ID;
        $result = $mysqli -> query($query);
        $record = $result -> fetch_assoc() ;
} elseif ($this_thing_ID>0) {
    
        $query = "SELECT * FROM things WHERE thing_ID = ".$this_thing_ID;
        $result = $mysqli -> query($query);
        $record = $result -> fetch_assoc() ; 
    
}
?>

				<FORM Name = "add_item" METHOD="POST" ACTION="add_listing.php">
					<TABLE>
						 <TR>
						 <TD VALIGN="top" >
							 Item title:
						 </TD>
						 <TD VALIGN="top">
							 <INPUT  NAME="thing_title" TYPE="text" SIZE=40 value="<?php echo $record["thing_title"] ?>">
							     
							     
						<?php
						
						$temp = $record["thing_ID"];
						//echo $temp;
						
						
						if ( $temp  >1 ) {
						    echo '<INPUT  NAME="thing_ID" TYPE="hidden" value="'.$temp.'">';
						} else {
						    echo '<INPUT  NAME="thing_ID" TYPE="hidden" value="0">';
						}
						?>

							     
						 </TD>
						 </TR>
						 
						 <TR>
						 <TD VALIGN="top" >
							 Full description:
						 </TD>
						 <TD VALIGN="top">
							 <INPUT  NAME="thing_description" TYPE="text" SIZE=40 value="<?php echo $record["thing_description"] ?>">
						 </TD>
						 </TR>


						 <TR>
						 <TD VALIGN="top" >
							 Loan or sale
						 </TD>
						 <TD VALIGN="top">
							 <input type="radio" name="thing_type"  value="1" checked > For loan
							 <input type="radio" name="thing_type"  value="2"> For sale
						 </TD>
						 </TR>


						 <TR>
						 <TD VALIGN="top" >
							 Price
						 </TD>
						 <TD VALIGN="top">
							 <input type="text" name="thing_price" value="<?php echo $record["thing_price"] ?>">
						 </TD>
						 </TR>

						 <TR>
						 <TD VALIGN="top" >
							 Percent to the community fund
						 </TD>
						 <TD VALIGN="top">
							 <input type="radio" name="thing_ratio"  value="20" <?php if ( $record["thing_ratio"]==20 ) { echo " checked "; }    ?>   > 20%
							 <input type="radio" name="thing_ratio"  value="50" <?php if ( $record["thing_ratio"]==50 ) { echo " checked "; }    ?>   > 50%
							 <input type="radio" name="thing_ratio"  value="75" <?php if ( $record["thing_ratio"]==75 ) { echo " checked "; }    ?>   > 75%
							 <input type="radio" name="thing_ratio"  value="100" <?php if ( $record["thing_ratio"]==100 ) { echo " checked "; }    ?>   > 100%
						 </TD>
						 </TR>

						 <TR>
						 <TD VALIGN="top" >
							 Load an image
						 </TD>
						 <TD VALIGN="top">
                            <input type="file" id="imageUpload" name="thing_image" accept="image/*">
						 </TD>
						 </TR>

						 <TR>
						 <TD VALIGN="top" >

						 </TD>
						 <TD VALIGN="top">
                            <input type="hidden" name="checkword" value="check">
						 </TD>
						 </TR>

						 </TD>
						 <TD VALIGN="top"></td><td>
							 <INPUT TYPE="SUBMIT" VALUE="Save" name="Submit">
						 </TD>
						 </TR>
					 </TABLE>
					 </form>

<?php 
// now list all your other listings

    echo '<BR><BR>Your other listings are: <BR>';

        $query3 = "select * from things where thing_member_ID = ".qq($_SESSION["member_ID"]);

        $result3 = $mysqli -> query($query3);
        echo '<FORM Name = "edit_item" METHOD="POST" ACTION="add_listing.php">';
        echo '<table>';
        echo '<tr><td>Edit</td><td>Title</td><td>Desc</td><td>price ?</td><td>Amount to CF</td></tr>';
        while ( $record3 = $result3 -> fetch_assoc()  ) {
          $temp = $record3["thing_ID"];
           echo '<tr><td><INPUT  NAME="thing_ID" TYPE="submit" value="'.$temp.'"></td><td>'.$record3["thing_title"].'</td><td>'.$record3["thing_description"].'</td><td>'.$record3["thing_price"].'</td><td>'.$record3["thing_ratio"].'%</td></tr>';

        }
        echo '</table>';
        echo '	</FORM>';

        
        
?>
</body>
</html>
