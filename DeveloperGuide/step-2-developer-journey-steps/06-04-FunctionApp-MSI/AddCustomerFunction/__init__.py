import logging
from os import access
import azure.functions as func
import mysql.connector
import ssl

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    from azure.identity import DefaultAzureCredential, AzureCliCredential, ChainedTokenCredential, ManagedIdentityCredential
    managed_identity = ManagedIdentityCredential()
    scope = "https://management.azure.com"
    token = managed_identity.get_token(scope)
    access_token = token.token

    crtpath = 'BaltimoreCyberTrustRoot.crt.pem'
    #crtpath = 'DigiCertGlobalRootCA.crt.pem'

    # Connect to MySQL
    cnx = mysql.connector.connect(
        user="mymsiuser", 
        password=access_token, 
        host="mysqldevSUFFIXflex.mysql.database.azure.com", 
        port=3306,
        ssl_ca=crtpath,
        tls_versions=['TLSv1.2']
    )

    logging.info(cnx)
    # Show databases
    cursor = cnx.cursor()
    cursor.execute("SHOW DATABASES")
    result_list = cursor.fetchall()
    # Build result response text
    result_str_list = []
    for row in result_list:
        row_str = ', '.join([str(v) for v in row])
        result_str_list.append(row_str)
    result_str = '\n'.join(result_str_list)
    return func.HttpResponse(
        result_str,
        status_code=200
    )