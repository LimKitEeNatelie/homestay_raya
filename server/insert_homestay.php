<?php
	if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die();
	}
	include_once("dbconnect.php");
	$userid = $_POST['userid'];
    $prname= ucwords(addslashes($_POST['prname']));
	$prdesc= ucfirst(addslashes($_POST['prdesc']));
	$prprice= $_POST['prprice'];
    $state= addslashes($_POST['state']);
    $local= addslashes($_POST['local']);
    $lat= $_POST['lat'];
    $lng= $_POST['lng'];
    $image1= $_POST['image1'];
	$image2= $_POST['image2'];
	$image3= $_POST['image3'];
	
	$sqlinsert = "INSERT INTO `tbl_homestay`(`user_id`, `homestay_name`, `homestay_desc`, `homestay_price`,`homestay_state`, `homestay_local`, `homestay_lat`, `homestay_lng`) VALUES ('$userid','$prname','$prdesc',$prprice,'$state','$local','$lat','$lng')";
	
	try {
		if ($conn->query($sqlinsert) === TRUE) {
			$decoded_string = base64_decode($image1);
			$filename = mysqli_insert_id($conn);
			$path = '../assets/productimages/'.$filename.'.png';
			file_put_contents($path, $decoded_string);
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