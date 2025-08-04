<?php
// this function  adds double quote marks to any string. It in addition removes commas from numbers formated with grouped thousands
	function qq($str) {
		
		//if ( ereg("[0-9]{0,3}(,([0-9]{3}))*,[0-9]{3}$",$str) ) {
		//
		//	$str=str_replace(",","",$str);
		//	
		//}
		
		$str = str_replace("'","&#39;",$str);
		$str = str_replace('"',"&#34;",$str);
		$str = trim($str);
		
		return '"'.$str.'"';
	}
	
	
	
// this function puts the contents into a table cell

    function cell2($str1,$str2) {
            $strcell = '<tr><td width="200">'.$str1.'</td><td>'.$str2.'</td></tr>';
            return  $strcell;
    }    
    
    function cell3($str1,$str2,$str3) {
            $strcell = '<tr><td width="200">'.$str1.'</td><td>'.$str2.'</td><td>'.$str3.'</td></tr>';
            return  $strcell;
    }    
    
    function cell4($str1,$str2,$str3,$str4) {
            $strcell = '<tr><td width="200">'.$str1.'</td><td>'.$str2.'</td><td>'.$str3.'</td><td>'.$str4.'</td></tr>';
            return  $strcell;
    }    
    
    function cell5($str1,$str2,$str3,$str4,$str5) {
            $strcell = '<tr><td width="200">'.$str1.'</td><td>'.$str2.'</td><td>'.$str3.'</td><td>'.$str4.'</td><td>'.$str5.'</td></tr>';
            return  $strcell;
    }
	
    function cell6($str1,$str2,$str3,$str4,$str5,$str6) {
            $strcell = '<tr><td width="200">'.$str1.'</td><td>'.$str2.'</td><td>'.$str3.'</td><td>'.$str4.'</td><td>'.$str5.'</td><td>'.$str6.'</td></tr>';
            return  $strcell;
    }



    function qecho($str1,$str2) {
        return '<br>'.$str1.' '.$str2 ;
    }

?>