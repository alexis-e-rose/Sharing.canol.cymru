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

// this page is for a member to search the database
    echo '<table><form name="search" action="search.php" method="post">';
    echo cell2("search keywords",'<input type="text" name="keywords" value="'.$_POST["keywords"].'">');   
    
    if ( $_POST["item_type"]==1){
            echo cell2("",'<select name="item_type"><option value="2">For sale</option><option value="1" selected>For loan</option><option value="3">Either</option></select>');    
    } elseif ($_POST["item_type"]==2) {
             echo cell2("",'<select name="item_type"><option value="2" selected>For sale</option><option value="1">For loan</option><option value="3">Either</option></select>');    
    } else {
            echo cell2("",'<select name="item_type"><option value="2">For sale</option><option value="1">For loan</option><option value="3" selected>Either</option></select>');    
    }
        echo cell2("",'<input type="submit" name="search" value="Search">');    
    echo '</form></table>';
    


// now show the details of the selected item
    echo "This is the detailed description:";
if (isset($_POST["item_ID"])) {
    
    $query = 'select * from things where thing_ID = '.qq($_POST["item_ID"]);
    $result = $mysqli -> query($query);
    $record = $result -> fetch_assoc();
    if ($record["thing_type"]==1) { $type="loan"; $term=" per day"; } else {$type = "sale"; $term="";}

    echo '<table>';
    echo cell2("Item",$record["thing_title"]);
    echo cell2("Description",$record["thing_description"]);
    echo cell2("type",$type);
    echo cell2("Price",'£'.$record["thing_price"].$term);
    echo '</table>';
}

echo '<BR><BR>Other items you can view:<br><br>';

echo '<table><form name="listofitems" method="post" action="search.php">';
echo cell3("<b>Short description</b>","<b>Terms</b>","<b>Price</b>");
if (isset($_POST["search"])) {

    if ( $_POST["item_type"]==1){
        $temp_type = " and thing_type = 1 ";
    } elseif ($_POST["item_type"]==2) {
         $temp_type = " and thing_type = 2 ";
    } else {
        $temp_type = "";
    }


    $query = 'select distinct * from things, thing_community, member_communities where things.thing_ID = thing_community.thing_ID and member_communities.community_ID = thing_community.community_ID '.
            ' and member_communities.member_ID = '.$_SESSION["member_ID"].' and thing_title like "%'.$_POST["keywords"].'%" '.$temp_type;    
    $result = $mysqli -> query($query);
    $temp = 0;
    while ( $record = $result -> fetch_assoc()) {
        if ($record["thing_ID"]==$temp ) {
            // this line is a duplicate
        } else {
            if ($record["thing_type"]==1) { $type="loan"; $term=" per day"; } else {$type = "sale"; $term="";}
            
            $button1 = '<button name="item_ID"  value="'.$record["thing_ID"].'">More details</button>';
            $button3 = '<input type="hidden" name="keywords" value="'.$_POST["keywords"] .'">'; 
            $button3 = '<input type="hidden" name="item_type" value="'.$_POST["item_type"] .'">'; 
            $button4 = '<input type="hidden" name="search" value="'.$_POST["search"] .'">';
            $button = $button1.$button3.$button4;
            echo cell5($record["thing_title"],$type,'£'.$record["thing_price"],$term,$button);
        }
        $temp = $record["thing_ID"];
    }
}
echo '</form></table>';



   
    
?>
</body>
</html>
