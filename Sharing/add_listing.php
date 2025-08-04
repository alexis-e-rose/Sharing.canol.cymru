<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8" />

</head>


<body>
    
<?php 
$page = "add_listing";
include("includes/connect.inc");
include("includes/miscfunctions.inc");
include("includes/header.inc"); 


// this page is for a member to load an item for sale/loan

//echo 'thing_ID is '.$_POST["thing_ID"];
$this_thing_ID = isset($_POST["thing_ID"]) ? $_POST["thing_ID"] : 0;
// check if calling from itself

if (isset($_POST["checkword"]) && $_POST["checkword"] == "check") {
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
        // now update the table of where the item is visible
        
//echo '<br>num comms = '.$_POST["num_comms"];



        $query = 'delete from thing_community where thing_ID = '.$this_thing_ID;
        $result = $mysqli -> query($query);

for ( $i=1; $i<=$_POST["num_comms"]; $i++) {
        $temp3 = "comm".$i;
        $temp2 = $_POST[$temp3];
        if ($temp2>0 ) {
            $query = 'INSERT INTO thing_community ( thing_ID , community_ID ) VALUES ('.$this_thing_ID.' , '.$temp2.' )';
            $result = $mysqli -> query($query);
    
            //echo '<br>'.$query;
        }
}

        
        $query = "SELECT * FROM things WHERE thing_ID = ".$this_thing_ID;
        $result = $mysqli -> query($query);
        $record = $result -> fetch_assoc() ;
                
        $querycom = "SELECT * FROM thing_community WHERE 1 thing_ID = ".$this_thing_ID;
        $resultcom = $mysqli -> query($query);
        $recordcom = $result -> fetch_assoc() ;
        
        
        
        
} elseif ($this_thing_ID>0) {
    
        if (isset($_POST["edit"])) {
            $query = "SELECT * FROM things WHERE thing_ID = ".$this_thing_ID;
            $result = $mysqli -> query($query);
            $record = $result -> fetch_assoc() ; 
                
            //$querycom = "SELECT * FROM `thing_community` WHERE 1 thing_ID = ".$this_thing_ID;
            //$resultcom = $mysqli -> query($querycom);
            //$recordcom = $resultcom -> fetch_assoc() ; 
                
            
            
        } elseif ( isset($_POST["item_delete"]) ) {
            $query = "delete FROM things WHERE thing_ID = ".$this_thing_ID;
            $result = $mysqli -> query($query);
        } else {
            echo "you should not be here";
            exit;
        }
    }

    // Initialize $record for edit mode or set defaults for new items
    if ($this_thing_ID > 0 && !isset($record)) {
        // Load existing item for editing
        $query = "SELECT * FROM things WHERE thing_ID = ".$this_thing_ID;
        $result = $mysqli -> query($query);
        $record = $result -> fetch_assoc();
    }
    
    // Set defaults for new items
    if (!isset($record) || !$record) {
        $record = array(
            "thing_title" => "",
            "thing_price" => "",
            "thing_type" => 1,
            "thing_ratio" => 20,
            "thing_description" => "",
            "thing_image" => ""
        );
    

    
}
?>

				<FORM Name = "add_item" METHOD="POST" ACTION="add_listing.php">
					<TABLE>
						
						<?php
						
						$temp = $record["thing_ID"];

						if ( $temp  >1 ) {
    					    echo '<INPUT  NAME="thing_ID" TYPE="hidden" value="'.$temp.'">';
						} else {
						    echo '<INPUT  NAME="thing_ID" TYPE="hidden" value="0">';
						}
						
						echo cell2("Item title:",' <INPUT  NAME="thing_title" TYPE="text" SIZE=40 value="'.$record["thing_title"].'">');	     
						echo cell2("Full description:",'<INPUT  NAME="thing_description" TYPE="text" SIZE=40 value="'.$record["thing_description"].'">');	     
						
						
						$query = "select * from Categories";
						$result3 = $mysqli -> query($query);
						
						$temp = "";
						while ($record3 = $result3 -> fetch_assoc() ) {
						    if ($record["thing_type"] == $record3["category_ID"])  { $ch=" checked ";} else { $ch = ""; } 
						    $temp .= '<input type="radio" name="thing_type"  value="'.$record3["category_ID"].'" '.$ch.' >'.$record3["category_name"].' ';
						}
						echo cell2("","$temp");
						
						
						echo cell2("Price:",'£<input type="text" name="thing_price" value="'.$record["thing_price"].'">.00');
						
						$ch1 = $ch2 =$ch3 = $ch4 = "";
						if     ( $record["thing_ratio"]==20 )  { $ch1 = " checked "; } 
						elseif ( $record["thing_ratio"]==50  ) { $ch2 = " checked "; } 
						elseif ( $record["thing_ratio"]==75  ) { $ch3 = " checked "; } 
						elseif ( $record["thing_ratio"]==100 ) { $ch4 = " checked "; } 
						    
						$q1='<input type="radio" name="thing_ratio"  value="20"  '.$ch1.'  > 20%';
						$q2='<input type="radio" name="thing_ratio"  value="50"  '.$ch2.'  > 50%';
						$q3='<input type="radio" name="thing_ratio"  value="75"  '.$ch3.'  > 75%';
						$q4='<input type="radio" name="thing_ratio"  value="100" '.$ch4.'  > 100%';
						
						$q_all = $q1.$q2.$q3.$q4;
						
						echo cell2("% to the community fund:",$q_all);

						?>

						 <TR>
						 <TD VALIGN="top" >
							 Load an image
						 </TD>
						 <TD VALIGN="top">
                            <input type="file" id="imageUpload" name="thing_image" accept="image/*">
						 </TD>
						 </TR>

<?php						 
        //echo cell2("Make visible to these communities","");
        // now work out which communityies to make it visible in 
        // first find out which communities the member belongs to
        $query = "select * from member_communities where member_ID = ".$_SESSION["member_ID"];
        $result = $mysqli -> query($query);
        $row_cnt =mysqli_num_rows($result);
        $i=0;
        while ($record = $result -> fetch_assoc() ) {
            
            // find if this community is already one of those selected
            // $recordcom is the variable that contains the communities already stored in thing_community
            // $record is the variable that contains the community numbers that the member is a member of
            
            // so need to check that each entry in $record is already included in $recordcom
            
        $ch5 = "";    
        if ($this_thing_ID > 0 )    {
           $querycom = "SELECT * FROM thing_community WHERE thing_ID = ".$this_thing_ID;
            $resultcom = $mysqli -> query($querycom);
            while ( $recordcom = $resultcom -> fetch_assoc()  ) {
                if ( $recordcom["community_ID"] == $record["community_ID"]) { $ch5 = " checked ";}
            }
        }
            
            
            $i++;
            $query2 = "SELECT * FROM communities WHERE community_ID = ".$record["community_ID"];
            $result2 = $mysqli -> query($query2);
            $record2 = $result2 -> fetch_assoc() ;
            echo cell2("Make visible here",'<input type="checkbox" name="comm'.$i.'" '.$ch5.' value="'.$record["community_ID"].'">'.$record2["community_name"]);
        }
        echo cell2("",'<input type="hidden" name="num_comms" value="'.$i.'">');
        

?>
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
        echo '<table>';
        echo cell6("Title","Desc","Price","term","CF","Edit");
        $j=0;
        while ( $record3 = $result3 -> fetch_assoc()  ) {
          $j++; 
          $temp = $record3["thing_ID"];
          if ($record3["thing_type"]==1) { $type="loan"; $term=" per day"; } else { $type = "sale"; $term="";}

            $qq1 = '<FORM Name = "edit_item'.$j.'" METHOD="POST" ACTION="add_listing.php">';
            $qq1 .= '<INPUT  NAME="edit" TYPE="submit" value="Edit"  >';
            $qq2 = '<INPUT  NAME="item_delete"  TYPE="submit" value="Delete"  >';
            $qq2 .= '<INPUT  NAME="thing_ID" TYPE="hidden" value="'.$temp.'">';
          echo cell6(
            $record3["thing_title"]
            ,'£'.$record3["thing_price"]
            ,$term
            ,$record3["thing_ratio"].'%'
            ,$qq1
            ,$qq2);
            echo '	</FORM>';

            
        }
        echo '</table>';

        
        
?>
</body>
</html>
