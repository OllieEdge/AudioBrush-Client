<?php

$params = array();
if(count($_GET) > 0) {
    $params = $_GET;
} else {
    $params = $_POST;
}
// defaults
// if($params['object'] == "") $params['object'] = "";
// if($params['url'] == "") $params['url'] = "";
// if($params['title'] == "") $params['title'] = "";
// if($params['image'] == "") $params['image'] = "";
// if($params['description'] == "") $params['description'] = "";

?>



<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
	<title></title>
	<head prefix="og: http://ogp.me/ns# fb: http://ogp.me/ns/fb# audiobrush: http://ogp.me/ns/fb/audiobrush#">

		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>

		<meta property="fb:app_id" content="243433722461339" /> 
		<meta property="og:type"   content="audiobrush:<?php echo $params['ABobject']; ?>" /> 
		<meta property="og:url"    content="http://audiobrush.com/opengraph/highscore.php?object=<?php echo $params['ABtype']; ?>&title=<?php echo $params['ABtitle']; ?>&image=<?php echo $params['ABimage']; ?>&description=<?php echo $params['ABdescription']; ?>"/>
		<meta property="og:title"  content="<?php echo $params['ABtitle']; ?>" /> 
		<meta property="og:image"  content="<?php echo $params['ABimage']; ?>" /> 
		<meta property="og:description"  content="<?php echo $params['ABdescription']; ?>" /> 
	</head>
	<body>

<?php echo $params['title']; ?>

	</body>
</html>