using System;
//using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Text.Json.Serialization;

namespace ProxySQLMetricsIngest
{
    class PSLogs
    {
        private string _strLogFilePath;
        private string _strLogFileDir;
        private string _strLogFileName;
        private long _lastReadPos = 0;

        public PSLogs(string strLogFileDir, string strLogFileName)
        {
            _strLogFilePath = strLogFileDir + @"/" + strLogFileName;
            if (File.Exists(_strLogFilePath))
            {
                _strLogFileDir = strLogFileDir;
                _strLogFileName = strLogFileName;
            }
            else
            {
                Console.WriteLine("ProxySQL Log File: {0} does not exist!", _strLogFilePath);
                _strLogFilePath = null;
                _strLogFileDir = null;
                _strLogFileName = null;
            }
        }

        /*
         * TODO: It does not add support for the log rotation monitoring by FileSystemWatcher
         * it is simple version now to try pick up the error logs. If log rotated, the seek 
         * will fail, just handle it to reset the pos to zero.
         */

        public string GetJsonPayload()
        {
            if (_strLogFilePath == null)
                return null;

            try
            {
                using var fileStream = new FileStream(_strLogFilePath, FileMode.Open, FileAccess.Read, FileShare.ReadWrite);
                fileStream.Seek(_lastReadPos, SeekOrigin.Begin);
                Console.WriteLine("File Postion {0}", _lastReadPos);
                using StreamReader sr = new StreamReader(fileStream);
                if (sr.EndOfStream)
                {
                    return null; //the file stream is empty, so return NULL;
                }

                var jsonString = new StringBuilder();
                jsonString.Append("[");

                string s;
                while ((s = sr.ReadLine()) != null)
                {
                    _lastReadPos = fileStream.Position;
                    if (s.Contains("[ERROR]"))
                    {
                        jsonString.Append("{");
                        jsonString.Append(string.Format("\"{0}\":\"{1}\"", "Log", s));
                        jsonString.Append("},");
                    }
                }
                jsonString.Remove(jsonString.Length - 1, 1);
                jsonString.Append("]");
                if (jsonString.ToString() == "]")
                {
                    return null;
                }
                else
                {
                    Console.WriteLine(jsonString.ToString());
                    return jsonString.ToString();
                }
            } catch (Exception e)
            {
                Console.WriteLine(e);
                _lastReadPos = 0; //ToDo: It may not handle all corner case
                return null;
            }            
        }
    }
}
