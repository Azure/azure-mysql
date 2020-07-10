using System;
using System.Collections.Generic;
using System.Text;
using MySql.Data.MySqlClient;

namespace ProxySQLMetricsIngest
{
    class PSMetrics
    {
        // Connection to ProxySQL Admin Interface
        private MySqlConnection _connection = null;

        public PSMetrics(MySqlConnection connection)
        {
            _connection = connection;
        }
        // Use Database;
        public void UseDatabase (string strDBName)
        {
           using var command = _connection?.CreateCommand();
           command.CommandText = string.Format("Use {0};", strDBName);
           command.ExecuteNonQuery();
        }

        // Get Payload in Json format after retrive Metrics from ProxySQL Admin Stats Tables
        public string GetJsonPayload(string strTableName) 
        {
            using var command = _connection?.CreateCommand();
            command.CommandText = string.Format("SELECT * FROM {0};", strTableName);
            Console.WriteLine(command.CommandText);
            using var reader = command.ExecuteReader();

            // Print the ColumnName and DataType for each column.
            for (int i = 0; i < reader.FieldCount; i++)
            {
                Console.WriteLine(string.Format("Column {0} name: {1} type {2}", i, reader.GetName(i), reader.GetFieldType(i)));
            }

            if (!reader.HasRows)
            {
                Console.WriteLine("Table is empty!!!");
                return "";
            }

            var jsonString = new StringBuilder();

            jsonString.Append("[");

            while (reader.Read())
            {
                jsonString.Append("{");
                for (int i = 0; i < reader.FieldCount; i++)
                {
                    jsonString.Append(string.Format("\"{0}\":", reader.GetName(i)));
                    switch (reader.GetFieldType(i).Name)
                    {
                        case "Int32":
                            jsonString.Append(reader.GetInt32(i));
                            break;
                        case "Int64":
                            jsonString.Append(reader.GetInt64(i));
                            break;
                        case "Double":
                            jsonString.Append(reader.GetDouble(i));
                            break;
                        case "String":
                            jsonString.Append("\"" + reader.GetString(i) + "\"");
                            break;
                        case "Single":
                        case "Decimal":
                            //ToDo and just alert now:
                            throw new NotImplementedException();
                            //break;
                    }
                    if (i < (reader.FieldCount - 1))
                    {
                        jsonString.Append(",");
                    }
                }
                jsonString.Append("},");
            }
            jsonString.Remove(jsonString.Length - 1, 1);
            jsonString.Append("]");
            Console.WriteLine(jsonString.ToString());
            return jsonString.ToString(); 
        }
    }
}
