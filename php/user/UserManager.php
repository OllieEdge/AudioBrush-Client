<?php
class UserManager{
	function getUser($facebookID){
		include '../connectToDatabase.php';

		$sqlObject = mysql_query("SELECT * FROM ab_users WHERE id = '$facebookID';");
		
		return mysql_fetch_assoc($sqlObject);
	}

	function createUser($facebookID, $name, $credits){
		include '../connectToDatabase.php';

		$sqlObject = mysql_query("INSERT INTO ab_users (id, name, credits) VALUES ('$facebookID', '$name', '$credits');");
		$sqlObject = mysql_query("SELECT * FROM ab_users WHERE id = '$facebookID';");
		
		return mysql_fetch_assoc($sqlObject);
	}

	function updateCredits($facebookID, $credits){
		include '../connectToDatabase.php';

		$sqlObject = mysql_query("UPDATE ab_users SET credits = '$credits' WHERE id = '$facebookID';");
		$sqlObject = mysql_query("SELECT * FROM ab_users WHERE id = '$facebookID';");
		
		return mysql_fetch_assoc($sqlObject);
	}

	function unlimitedPurchased($facebookID){
		include '../connectToDatabase.php';

		$sqlObject = mysql_query("UPDATE ab_users SET unlimited = 1 WHERE id = '$facebookID';");
		$sqlObject = mysql_query("SELECT * FROM ab_users WHERE id = '$facebookID';");
		
		return mysql_fetch_assoc($sqlObject);
	}
}



?>