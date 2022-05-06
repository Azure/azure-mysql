import logging
import azure.functions as func
import mysql.connector
import ssl

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    crtpath = 'BaltimoreCyberTrustRoot.crt.pem'
    #crtpath = 'DigiCertGlobalRootCA.crt.pem'

    ctx = ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)

    # Connect to MySQL
    cnx = mysql.connector.connect(
        user="wsuser", 
        password='Solliance123', 
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