<?php
/*
try{
 $con =new PDO("mysql:host=mysql;dbname=test","root","123456");
 echo"ok...";

}catch(PDOException $e){

  echo $e->getMessage();
}
*/

  $con = new mysqli("mysql","root","123456");

  if($con->connect_error){
      die("connect fail".$con->connect_error);
  }else{
      echo "connect success!";
  }

