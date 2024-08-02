<?php
$host = '<your-host-name>';
$username = '<your-EntraID-username>';
$password = '<EntraID-access-token>';
$db_name = '<your-database-name>';

//Establish connection with Entra ID Access Token as password
$conn = mysqli_init();
mysqli_ssl_set($conn,NULL,NULL,"DigiCertGlobalRootCA.crt.pem",NULL,NULL);
mysqli_real_connect($conn, $host, $username, $password, $db_name, 3306, MYSQLI_CLIENT_SSL);
if (mysqli_connect_errno($conn)) {
    die('Failed to connect to MySQL: '.mysqli_connect_error());
}
printf("Connection Established.\n");

// Run the create table query
if (mysqli_query($conn, '
CREATE TABLE Products (
`Id` INT NOT NULL AUTO_INCREMENT ,
`ProductName` VARCHAR(200) NOT NULL ,
`Color` VARCHAR(50) NOT NULL ,
`Price` DOUBLE NOT NULL ,
PRIMARY KEY (`Id`)
);
')) {
    printf("Table Created.\n");
}

//Close the connection
mysqli_close($conn);
?>