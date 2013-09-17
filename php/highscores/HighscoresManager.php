<?php

class HighscoresManager{

	function postNewHighscore($facebookID, $track, $artist, $score, $difficulty, $realTrackName = "", $realArtistName = ""){
		include '../connectToDatabase.php';

		$sqlObject = mysql_query("SHOW TABLES LIKE 'highscore_" . $artist . "_" . $track . "_" . $difficulty . "';");
		if(mysql_num_rows($sqlObject) == 0){
			$sqlObject = mysql_query("CREATE TABLE highscore_" . $artist . "_" . $track . "_" . $difficulty . " (facebookID bigint(16) unsigned NOT NULL, score int(11) NOT NULL DEFAULT '0', UNIQUE KEY facebookID (facebookID));");
		}

		$sqlObject = mysql_query("SHOW TABLES LIKE 'user_plays_" . $facebookID . "';");
		if(mysql_num_rows($sqlObject) == 0){
			$sqlObject = mysql_query("CREATE TABLE user_plays_" . $facebookID . " (trackKey varchar(128) COLLATE latin1_german2_ci NOT NULL, artist varchar(64) COLLATE latin1_german2_ci NOT NULL, track varchar(64) COLLATE latin1_german2_ci NOT NULL, plays int(11) NOT NULL, lastUpdate timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP, UNIQUE KEY trackKey (trackKey));");
		}

		if(!$realTrackName || $realTrackName == ""){
			$realTrackName = $track;
			$realArtistName = $artist;
		}
		
		$sqlObject = mysql_query("INSERT INTO user_plays_" . $facebookID . " (trackKey, artist, track, plays, lastUpdate) VALUES ('" . $artist . "_" . $track . "', '" . $realArtistName . "', '" . $realTrackName . "', 1, CURRENT_TIMESTAMP) ON DUPLICATE KEY UPDATE plays = plays+1, lastUpdate = CURRENT_TIMESTAMP;");

		$sqlObject = mysql_query("INSERT INTO ab_trending (trackKey, artist, track, plays, lastUpdate) VALUES ('" . $artist . "_" . $track . "', '" . $realArtistName . "', '" . $realTrackName . "', 1, CURRENT_TIMESTAMP) ON DUPLICATE KEY UPDATE plays = plays+1, lastUpdate = CURRENT_TIMESTAMP;");

		$sqlObject = mysql_query("INSERT INTO highscore_" . $artist . "_" . $track . "_" . $difficulty . " (facebookID, score) VALUES (" . $facebookID . ", " . $score . ") ON DUPLICATE KEY UPDATE score = IF (score  < " . $score . ", " . $score . ", score);");
		$affectedRows = mysql_affected_rows();

		$sqlRanking = mysql_query("SELECT z.*, x.rank FROM highscore_" . $artist . "_" . $track . "_" . $difficulty . " z INNER JOIN (SELECT a.facebookID, a.score, @num := @num + 1 AS rank from highscore_" . $artist . "_" . $track . "_" . $difficulty . " a, (SELECT @num := 0) d order by a.score DESC) x ON z.facebookID = x.facebookID WHERE z.facebookID = " . $facebookID . "  LIMIT 1;");
		$ranking = mysql_fetch_assoc($sqlRanking);

		$highscoreObject['rank'] = intval($ranking['rank']);
		$highscoreObject['track'] = $track;
		$highscoreObject['artist'] = $artist;
		$highscoreObject['difficulty'] = $difficulty;
		$highscoreObject['score'] = $score;

		if($affectedRows > 0){
			$highscoreObject['newHighscore'] = 1;
		}
		else{
			$highscoreObject['newHighscore'] = 0;
		}

		return $highscoreObject;
	}

	function getRank($facebookID, $track, $artist, $score, $difficulty){
		include '../connectToDatabase.php';

		$sqlObject = mysql_query("SELECT z.*, x.rank FROM highscore_" . $artist . "_" . $track . "_" . $difficulty . " z INNER JOIN (SELECT a.facebookID, a.score, @num := @num + 1 AS rank from highscore_" . $artist . "_" . $track . "_" . $difficulty . " a, (SELECT @num := 0) d order by a.score DESC) x ON z.facebookID = x.facebookID WHERE z.facebookID = " . $facebookID . "  LIMIT 1;");
		return mysql_fetch_assoc($sqlObject);
	}

	function getFriendScores($track, $artist, $difficulty, $results, $friends){
		include '../connectToDatabase.php';

		if(sizeof($friends) > 0){
			$queryString = "SELECT * FROM highscore_" . $artist . "_" . $track . "_" . $difficulty . " WHERE facebookID = " . $friends[0] . " ";
			for($i = 1; $i < sizeof($friends); $i++){
				$queryString .= "OR facebookID = " . $friends[$i] . " ";
			}
			$queryString .= "ORDER BY score DESC LIMIT " . $results . ";";
		}
		else{
			return array();
		}
		$sqlObject = mysql_query($queryString);

		$leaderboard = array();

		if($sqlObject){
			while($row = mysql_fetch_assoc($sqlObject)){
				$sqlName = mysql_query("SELECT name FROM ab_users WHERE id = " . $row['facebookID'] . ";");
				$sqlRank = mysql_query("SELECT z.*, x.rank FROM highscore_" . $artist . "_" . $track . "_" . $difficulty . " z INNER JOIN (SELECT a.facebookID, a.score, @num := @num + 1 AS rank from highscore_" . $artist . "_" . $track . "_" . $difficulty . " a, (SELECT @num := 0) d order by a.score DESC) x ON z.facebookID = x.facebookID WHERE z.facebookID = " . $row['facebookID'] . "  LIMIT 1;");
				$name = mysql_fetch_assoc($sqlName);
				$rank = mysql_fetch_assoc($sqlRank);
				$row['rank'] = $rank['rank'];
				$row['name'] = $name['name'];
				$leaderboard[] = $row;
			}
		}

		return $leaderboard;
	}

	function getTopX($track, $artist, $difficulty, $results){
		include '../connectToDatabase.php';

		$sqlObject = mysql_query("SELECT * FROM highscore_" . $artist . "_" . $track . "_" . $difficulty . " ORDER BY score DESC LIMIT " . $results . ";");

		$leaderboard = array();
		$rank = 0;
		if($sqlObject){
			while($row = mysql_fetch_assoc($sqlObject)){
				$sqlName = mysql_query("SELECT name FROM ab_users WHERE id = " . $row['facebookID'] . ";");
				$name = mysql_fetch_assoc($sqlName);
				$row['name'] = $name['name'];
				$rank++;
				$row['rank'] = $rank;
				$leaderboard[] = $row;
			}
		}

		return $leaderboard;
	}

	function getLatestTracks($amountToGet){
		include '../connectToDatabase.php';

		$sqlObject = mysql_query("SELECT * FROM ab_trending ORDER BY lastUpdate DESC limit " . $amountToGet . ";");
		$results = array();
		if($sqlObject){
			while($row = mysql_fetch_assoc($sqlObject)){
				$results[] = $row;
			}
		}
		return $results;
	}

	function getPopularTracks($amountToGet){
		include '../connectToDatabase.php';

		$sqlObject = mysql_query("SELECT * FROM ab_trending ORDER BY plays DESC limit " . $amountToGet . ";");
		$results = array();
		if($sqlObject){
			while($row = mysql_fetch_assoc($sqlObject)){
				$results[] = $row;
			}
		}

		return $results;
	}

	function getFriendsTracks($friends, $searchCriteria = NULL){
		include '../connectToDatabase.php';

		$results = array();
		for($i = 0; $i < sizeof($friends); $i++){
			$sqlObject = mysql_query("SHOW TABLES LIKE 'user_plays_" . $friends[$i] . "';");
			if(mysql_num_rows($sqlObject) > 0){
				if($searchCriteria == NULL){
					$sqlObject = mysql_query("SELECT * FROM user_plays_" . $friends[$i] . " ORDER BY plays DESC LIMIT 15;");
					if(mysql_num_rows($sqlObject) > 0){
						while($row = mysql_fetch_assoc($sqlObject)){
							$results[] = $row;
						}
					}
				}
				else{
					for($s = 0; $s < sizeof($searchCriteria); $s++){
						$sqlObject = mysql_query("SELECT * FROM user_plays_" . $friends[$i] . " WHERE (artist LIKE '%" . $searchCriteria[$s] . "%' OR track LIKE '%". $searchCriteria[$s] . "%') ORDER BY plays DESC LIMIT 15;");
						if(mysql_num_rows($sqlObject) > 0){
							while($row = mysql_fetch_assoc($sqlObject)){
								$results[] = $row;
							}
						}
					}
				}
				
			}
		}
		return $results;
	}

	function searchForListings($searchCriteria){
		include '../connectToDatabase.php';

		$search = array();

		for($i = 0; $i < sizeof($searchCriteria); $i++){
			$sqlObject = mysql_query("SELECT * FROM ab_trending WHERE (artist LIKE '%" . $searchCriteria[$i] . "%' OR track LIKE '%". $searchCriteria[$i] . "%') ORDER BY plays DESC LIMIT 50;");
			if(mysql_num_rows($sqlObject) > 0){
				while($row = mysql_fetch_assoc($sqlObject)){
					$search[] = $row;
				}
			}
		}

		return $search;
	}

}

?>