<?php
class UserManager{
	function getUser($facebookID){
		include '../connectToDatabase.php';

		$sqlObject = mysql_query("SELECT * FROM ab_users WHERE id = '$facebookID';");
		
		return mysql_fetch_assoc($sqlObject);
	}

	function createUser($facebookID, $name){
		include '../connectToDatabase.php';

		$sqlObject = mysql_query("INSERT INTO ab_users (id, name) VALUES ('$facebookID', '$name');");
		$sqlObject = mysql_query("SELECT * FROM ab_users WHERE id = '$facebookID';");
		
		return mysql_fetch_assoc($sqlObject);
	}
}



?>