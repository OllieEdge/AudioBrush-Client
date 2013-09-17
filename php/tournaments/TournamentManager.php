<?php

class TournamentManager{
	function getCurrentTournament(){
		include '../connectToDatabase.php';

		//$sqlObject = mysql_query("SELECT * FROM ab_tournaments WHERE NOW() BETWEEN activeDate AND endDate;");

		$sqlObject = mysql_query("SELECT * FROM ab_tournaments");

		$tournamentData = mysql_fetch_assoc($sqlObject);

		return $tournamentData;
	}
	function getCurrentLeader($tournamentID){
		include '../connectToDatabase.php';

		$leader = 0;

		$sqlObject = mysql_query("SHOW TABLES LIKE 'tournament_" . $tournamentID . "';");
		if(mysql_num_rows($sqlObject) != 0){
			$sqlObject = mysql_query("SELECT * FROM tournament_" . $tournamentID . " ORDER BY score DESC limit 1;");
			$leader = mysql_fetch_assoc($sqlObject);
			$sqlObject = mysql_query("SELECT * FROM ab_users WHERE id = " . $leader['facebookID'] . " limit 1;");
			$leaderDetails = mysql_fetch_assoc($sqlObject);
			$leader['name'] = $leaderDetails['name'];
		}
		
		return $leader;
	}

	function postNewHighscore($facebookID, $tournamentID, $score){
		include '../connectToDatabase.php';

		$sqlObject = mysql_query("SHOW TABLES LIKE 'tournament_" . $tournamentID . "';");
		if(mysql_num_rows($sqlObject) == 0){
			$sqlObject = mysql_query("CREATE TABLE tournament_" . $tournamentID . " (facebookID bigint(16) unsigned NOT NULL, score int(11) NOT NULL DEFAULT '0', UNIQUE KEY facebookID (facebookID));");
		}

		if(!$realTrackName || $realTrackName == ""){
			$realTrackName = $track;
			$realArtistName = $artist;
		}

		$sqlObject = mysql_query("INSERT INTO tournament_" . $tournamentID . " (facebookID, score) VALUES (" . $facebookID . ", " . $score . ") ON DUPLICATE KEY UPDATE score = IF (score  < " . $score . ", " . $score . ", score);");
		$affectedRows = mysql_affected_rows();

		$sqlRanking = mysql_query("SELECT z.*, x.rank FROM tournament_" . $tournamentID . " z INNER JOIN (SELECT a.facebookID, a.score, @num := @num + 1 AS rank from tournament_" . $tournamentID . " a, (SELECT @num := 0) d order by a.score DESC) x ON z.facebookID = x.facebookID WHERE z.facebookID = " . $facebookID . "  LIMIT 1;");
		$ranking = mysql_fetch_assoc($sqlRanking);

		$highscoreObject['rank'] = intval($ranking['rank']);
		$highscoreObject['score'] = $score;

		if($affectedRows > 0){
			$highscoreObject['newHighscore'] = 1;
		}
		else{
			$highscoreObject['newHighscore'] = 0;
		}

		return $highscoreObject;
	}

}
?>