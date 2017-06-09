<?php
/*
try{
 $con =new PDO("mysql:host=localhost;dbname=test","root","root");
 echo"ok...";

}catch(PDOException $e){

  echo $e->getMessage();
}
*/

  $con = new mysqli("127.0.0.1","root","root");

  if($con->connect_error){
    die("fail....".$con->connect_error);
    }else{

      echo "ok....";
   }

