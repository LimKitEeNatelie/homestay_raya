<?php
	if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die();
	}
	include_once("dbconnect.php");
	$userid = $_POST['userid'];
	$homestayid = $_POST['homestayid'];
  $prname= ucwords(addslashes($_POST['prname']));
	$prdesc= ucfirst(addslashes($_POST['prdesc']));
	$prprice= $_POST['prprice'];
 // $delivery= $_POST['delivery'];
  //$qty= $_POST['qty'];
  
	$sqlupdate = "UPDATE `tbl_homestay` SET `homestay_name`='$prname',`homestay_desc`='$prdesc',`homestay_price`='$prprice' WHERE `homestay_id` = '$homestayid' AND `user_id` = '$userid'";
	
  try {
		if ($conn->query($sqlupdate) === TRUE) {
			$response = array('status' => 'success', 'data' => null);
			sendJsonResponse($response);
		}
		else{
			$response = array('status' => 'failed', 'data' => null);
			sendJsonResponse($response);
		}
	}
	catch(Exception $e) {
		$response = array('status' => 'failed', 'data' => null);
		sendJsonResponse($response);
	}
	$conn->close();
	
	function sendJsonResponse($sentArray)
	{
    header('Content-Type= application/json');
    echo json_encode($sentArray);
	}
?>