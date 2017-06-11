<?php
/*
try{
 $con =new PDO("mysql:host=mysql;dbname=test","root","root");
 echo"ok...";

}catch(PDOException $e){

  echo $e->getMessage();
}
*/

  $con = new mysqli("mysql","root","root");

  if($con->connect_error){
    die("fail....".$con->connect_error);
    }else{

      echo "ok....";
   }

