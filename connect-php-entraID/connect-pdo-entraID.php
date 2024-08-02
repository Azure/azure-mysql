<?php
$username = '<your-Entra-ID-username>';
$password = '<Entra-ID-access-token>';

$options = array(
    PDO::MYSQL_ATTR_SSL_CA => 'DigiCertGlobalRootCA.crt.pem'
);

$header_array = array(
    'Metadata: true'
);

/* Acquiring Access Token by providing managed identity using HTTP - https://learn.microsoft.com/entra/identity/managed-identities-azure-resources/how-to-use-vm-token */
$clientID = "<client-ID-of-managed-identity>";
$url = "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fossrdbms-aad.database.windows.net&client_id=".$clientID;
$crl = curl_init();
curl_setopt_array($crl, [CURLOPT_URL => $url, CURLOPT_RETURNTRANSFER => true, CURLOPT_HEADER => false, CURLOPT_HTTPHEADER => $header_array]);
$result = json_decode(curl_exec($crl));
$pass = $result->access_token;

/* Connecting to Azure DB for MySQL using the Access Token as Password */

try{
    $db = new PDO('mysql:host=<your-host-name>;port=3306;dbname=<your-database-name>', $username, $pass, $options);
    echo "Connection Established with Entra ID\n";
    $sql = "SHOW DATABASES;";
    try {
        $stmt = $db->query($sql);
        $result = $stmt->fetchall(PDO::FETCH_ASSOC);
        print_r($result);
        unset($stmt);
    } 
    catch (PDOException $e) {
        echo "Failed to run the simple query (user-assigned).\n";
    }
    unset($conn);
}
catch (PDOException $e)
{
    echo "Could not connect with Entra ID\n";
    print_r($e->getMessage());
}

?>