<?php
$con = mysql_connect("db469179190.db.1and1.com","dbo469179190","ps1ps2xbox");

if (!$con)
{
	return(2);
}

mysql_select_db("db469179190", $con);
?>
