<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8" />
  <title>Search Items - Sharing Canol Cymru</title>
</head>


<body>
    
<?php 
$page = "search";
include("includes/connect.inc");
include("includes/miscfunctions.inc");
include("includes/security_functions.inc");
include("includes/booking_functions.inc");
include("includes/notification_functions.inc");
include("includes/header.inc"); 

// this page is for a member to search the database
    echo '<table><form name="search" action="search.php" method="post">';
    $keywords_value = isset($_POST["keywords"]) ? $_POST["keywords"] : '';
echo cell2("search keywords",'<input type="text" name="keywords" value="'.$keywords_value.'">');

$item_type = isset($_POST["item_type"]) ? $_POST["item_type"] : 1;
if ( $item_type==1){
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
    // SECURE VERSION - Prepared statements
    $item_id = secure_input($_POST["item_ID"], 'int');
    
    if ($item_id) {
        $query = 'SELECT * FROM things WHERE thing_ID = ?';
        $record = secure_query($query, [$item_id], 'one');
    } else {
        $record = false;
    }
    
    if ($record) {
    if ($record["thing_type"]==1) { $type="loan"; $term=" per day"; } else {$type = "sale"; $term="";}

    echo '<table>';
    echo cell2("Item",$record["thing_title"]);
    echo cell2("Description",$record["thing_description"]);
        echo cell2("type",$type);
        echo cell2("Price",'£'.$record["thing_price"].$term);
        echo '</table>';
    }
}

echo '<BR><BR>Other items you can view:<br><br>';

echo '<table><form name="listofitems" method="post" action="search.php">';
echo cell6("<b>Short description</b>","<b>Terms</b>","<b>Price</b>","<b>Owner</b>","<b>Details</b>","<b>Actions</b>");
if (isset($_POST["search"])) {

    if ( $_POST["item_type"]==1){
        $temp_type = " and thing_type = 1 ";
    } elseif ($_POST["item_type"]==2) {
         $temp_type = " and thing_type = 2 ";
    } else {
        $temp_type = "";
    }


    // SECURE VERSION - Prepared statements for search
    $keywords = secure_input($_POST["keywords"], 'string');
    $member_id = secure_input($_SESSION["member_ID"], 'int');
    
    // Build secure query with proper parameterization
    $query = 'SELECT DISTINCT things.*, members.member_fname, members.member_lname 
              FROM things, thing_community, member_communities, members 
              WHERE things.thing_ID = thing_community.thing_ID 
              AND member_communities.community_ID = thing_community.community_ID 
              AND things.thing_member_ID = members.member_ID
              AND member_communities.member_ID = ? 
              AND thing_title LIKE ?';
    
    $params = [$member_id, "%$keywords%"];
    
    // Add type filter if specified
    if ($temp_type) {
        $query .= ' AND thing_type = ?';
        $item_type = secure_input($_POST["item_type"], 'int');
        $params[] = $item_type;
    }
    
    $query .= ' ORDER BY things.thing_create_date DESC';
    $results = secure_query($query, $params);
    $temp = 0;
    foreach ($results as $record) {
        if ($record["thing_ID"]==$temp ) {
            // this line is a duplicate
        } else {
            if ($record["thing_type"]==1) { $type="loan"; $term=" per day"; } else {$type = "sale"; $term="";}
            
            // More details button
            $button1 = '<button name="item_ID"  value="'.$record["thing_ID"].'">More details</button>';
            $button3 = '<input type="hidden" name="keywords" value="'.$_POST["keywords"] .'">'; 
            $button4 = '<input type="hidden" name="item_type" value="'.$_POST["item_type"] .'">'; 
            $button5 = '<input type="hidden" name="search" value="'.$_POST["search"] .'">';
            $details_button = $button1.$button3.$button4.$button5;
            
            // Action buttons
            $action_buttons = '';
            if ($record["thing_type"] == 1 && $record["thing_member_ID"] != $_SESSION["member_ID"]) {
                // This is a loan item and not owned by current user - show booking button
                $action_buttons = '<a href="request_booking.php?thing_id='.$record["thing_ID"].'" style="background-color: #008000; color: white; padding: 4px 8px; text-decoration: none; font-size: 12px;">📅 Book Item</a>';
            } elseif ($record["thing_type"] == 2) {
                // This is a sale item
                $action_buttons = '<span style="color: #0066cc; font-size: 12px;">💰 For Sale</span>';
            } elseif ($record["thing_member_ID"] == $_SESSION["member_ID"]) {
                // This is user's own item
                $action_buttons = '<span style="color: #808080; font-size: 12px;">Your item</span>';
            }
            
            $owner_name = $record["member_fname"].' '.$record["member_lname"];
            
            echo '<tr>';
            echo '<td>'.$record["thing_title"].'</td>';
            echo '<td>'.$type.'</td>';
            echo '<td>£'.$record["thing_price"].$term.'</td>';
            echo '<td>'.$owner_name.'</td>';
            echo '<td>'.$details_button.'</td>';
            echo '<td>'.$action_buttons.'</td>';
            echo '</tr>';
        }
        $temp = $record["thing_ID"];
    }
}
echo '</form></table>';



   
    
?>
</body>
</html>
