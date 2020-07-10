using System;
using System.Data;
using MySql.Data.MySqlClient;
using System.Text;
using System.Timers;

namespace ProxySQLMetricsIngest
{
    class Program
    {
        static MySqlConnection conn = null;
        static PSMetrics proxySQLMetrics = null;
        static LAWorkspace logAnalyticsWorkspace = null;
        static string[] strTables;
        static PSLogs proxySQLLogs = null;

        static void Main(string[] args)
        {           
           try
            {
                //input the connection string
                Console.WriteLine("Please input the the ProxySQL Admin Interface connection string like server=xxx;userid=xxx;password=xx;database=xxxx");
                string cs = Console.ReadLine();
                conn ??= new MySqlConnection(cs);
                conn.Open();
                Console.WriteLine($"MySQL version : {conn.ServerVersion}");
                proxySQLMetrics ??= new PSMetrics(conn);

                //input the workspace information
                Console.WriteLine("Please go to Logistic-Analytics-Workspace advanced setting, to copy Workspace-ID and Primary-Key");
                Console.WriteLine("Workspace ID:");
                string strWorkspaceID = Console.ReadLine();
                Console.WriteLine("Primary Key:");
                string strPrimaryKey = Console.ReadLine();

                logAnalyticsWorkspace ??= new LAWorkspace
                {
                    CustomerId = strWorkspaceID,
                    SharedKey = strPrimaryKey                    
                };

                proxySQLLogs = new PSLogs(@"/var/lib/proxysql", @"proxysql.log");

                strTables = new string[] {
                    "stats_memory_metrics",
                    "stats_mysql_commands_counters",
                    "stats_mysql_connection_pool",
                    "stats_mysql_errors",
                    "stats_mysql_free_connections",
                    "stats_mysql_global",
                    "stats_mysql_gtid_executed",
                    "stats_mysql_prepared_statements_info",
                    "stats_mysql_processlist",
                    "stats_mysql_query_digest",
                    "stats_mysql_query_rules",
                    "stats_mysql_users",
                    "stats_proxysql_servers_checksums",
                    "stats_proxysql_servers_metrics",
                    "stats_proxysql_servers_status"
                };

                var aTimer = new Timer(60000); //1 Minute
                aTimer.Elapsed += OnTimedEvent;
                aTimer.AutoReset = true;
                aTimer.Enabled = true;

                Console.WriteLine("\nPress the Enter key to exit the application...");
                Console.WriteLine("The application started at {0}", DateTime.Now.ToString());
                Console.ReadLine();
                aTimer.Stop();
                aTimer.Dispose();
                conn?.Close();

                Console.WriteLine("Terminating the application...");

            } catch (Exception e)
            {
                Console.WriteLine(e);
            }
        }

        private static void OnTimedEvent(Object source, ElapsedEventArgs e)
        {
            Console.WriteLine("The Elapsed event was raised at {0:HH:mm:ss.fff}", e.SignalTime);

            for (int i = 0; i < strTables.Length; i++)
            {
                string strTableName = strTables[i];
                string strPayload = proxySQLMetrics.GetJsonPayload(strTableName);
                if (strPayload.Length > 1)
                {
                    logAnalyticsWorkspace.InjestLog(strPayload, strTableName);
                }
            }

            string strErrLogs = proxySQLLogs.GetJsonPayload();
            if (strErrLogs != null)
            {
                logAnalyticsWorkspace.InjestLog(strErrLogs, "PSLogs");
            }
        }
    }
}
