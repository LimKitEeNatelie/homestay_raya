<?php
	error_reporting(0);
	if (!isset($_GET['userid'])) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die();
	}
	$userid = $_GET['userid'];
	include_once("dbconnect.php");
	$sqlloadhomestay = "SELECT * FROM tbl_homestay WHERE user_id = '$userid' ORDER BY homestay_date DESC";
	$result = $conn->query($sqlloadhomestay);
	if ($result->num_rows > 0) {
		$homestayarray["homestay"] = array();
		while ($row = $result->fetch_assoc()) {
			$prlist = array();
			$prlist['homestay_id'] = $row['homestay_id'];
			$prlist['user_id'] = $row['user_id'];
			$prlist['homestay_name'] = $row['homestay_name'];
			$prlist['homestay_desc'] = $row['homestay_desc'];
			$prlist['homestay_price'] = $row['homestay_price'];
			//$prlist['homestay_delivery'] = $row['homestay_delivery'];
			//$prlist['homestay_qty'] = $row['homestay_qty'];
			$prlist['homestay_state'] = $row['homestay_state'];
			$prlist['homestay_local'] = $row['homestay_local'];
			$prlist['homestay_lat'] = $row['homestay_lat'];
			$prlist['homestay_lng'] = $row['homestay_lng'];
			$prlist['homestay_date'] = $row['homestay_date'];
			array_push($homestayarray["homestay"],$prlist);
		}
		$response = array('status' => 'success', 'data' => $homestayarray);
    sendJsonResponse($response);
		}else{
		$response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
	}
	
	function sendJsonResponse($sentArray)
	{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
	}