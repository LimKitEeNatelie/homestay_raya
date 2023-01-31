<?php
	error_reporting(0);
	include_once("dbconnect.php");
	$search  = $_GET["search"];
	$results_per_page = 10;
	$pageno = (int)$_GET['pageno'];
	$page_first_result = ($pageno - 1) * $results_per_page;
	
	if ($search =="all"){
			$sqlloadproduct = "SELECT * FROM tbl_homestay ORDER BY homestay_date DESC";
	}else{
		$sqlloadproduct = "SELECT * FROM tbl_homestay WHERE homestay_name LIKE '%$search%' ORDER BY homestay_date DESC";
	}
	
	$result = $conn->query($sqlloadproduct);
	$number_of_result = $result->num_rows;
	$number_of_page = ceil($number_of_result / $results_per_page);
	$sqlloadproduct = $sqlloadproduct . " LIMIT $page_first_result , $results_per_page";
	$result = $conn->query($sqlloadproduct);
	
	if ($result->num_rows > 0) {
		$homestaysarray["homestays"] = array();
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
			array_push($homestaysarray["homestays"],$prlist);
		}
		$response = array('status' => 'success', 'numofpage'=>"$number_of_page",'numberofresult'=>"$number_of_result",'data' => $homestaysarray);
    sendJsonResponse($response);
		}else{
		$response = array('status' => 'failed','numofpage'=>"$number_of_page", 'numberofresult'=>"$number_of_result",'data' => null);
    sendJsonResponse($response);
	}
	
	function sendJsonResponse($sentArray)
	{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
	}