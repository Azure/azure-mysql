using System;
using System.Text;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Security.Cryptography;
using System.Threading.Tasks;

namespace ProxySQLMetricsIngest
{
	class LAWorkspace
	{
		// You can use an optional field to specify the timestamp from the data. 
		// If the time field is not specified, Azure Monitor assumes the time is the message ingestion time
		//public string TimeStampField { get; set; }

		// Update customerId to your Log Analytics workspace ID
		public string CustomerId { get; set; }

		// For sharedKey, use either the primary or the secondary Connected Sources client authentication key   
		public string SharedKey { get; set; }

		// LogName is name of the event type that is being submitted to Azure Monitor
		//public string LogName { get; set; }

		// An example JSON object, with key/value pairs
		//private readonly string  strJson = @"[{""DemoField1"":""DemoValue1"",""DemoField2"":""DemoValue2""},{""DemoField3"":""DemoValue3"",""DemoField4"":""DemoValue4""}]";

		public LAWorkspace(){
		}

		public void InjestLog(string strJsonPayload, string strLogName) {
			// Create a hash for the API signature
			var datestring = DateTime.UtcNow.ToString("r");
			var jsonBytes = Encoding.UTF8.GetBytes(strJsonPayload);
			string stringToHash = "POST\n" + jsonBytes.Length + "\napplication/json\n" + "x-ms-date:" + datestring + "\n/api/logs";
			string hashedString = BuildSignature(stringToHash, SharedKey);
			string signature = "SharedKey " + CustomerId + ":" + hashedString;

			PostData(signature, datestring, strJsonPayload, strLogName);
		}
		// Build the API signature
		public string BuildSignature(string message, string secret)
		{
			var encoding = new System.Text.ASCIIEncoding();
			byte[] keyByte = Convert.FromBase64String(secret);
			byte[] messageBytes = encoding.GetBytes(message);
			using (var hmacsha256 = new HMACSHA256(keyByte))
			{
				byte[] hash = hmacsha256.ComputeHash(messageBytes);
				return Convert.ToBase64String(hash);
			}
		}

		// Send a request to the POST API endpoint
		public void PostData(string signature, string date, string json, string logName)
		{
			try
			{
				string url = "https://" + CustomerId + ".ods.opinsights.azure.com/api/logs?api-version=2016-04-01";

				System.Net.Http.HttpClient client = new System.Net.Http.HttpClient();
				client.DefaultRequestHeaders.Add("Accept", "application/json");
				client.DefaultRequestHeaders.Add("Log-Type", logName);
				client.DefaultRequestHeaders.Add("Authorization", signature);
				client.DefaultRequestHeaders.Add("x-ms-date", date);
				client.DefaultRequestHeaders.Add("time-generated-field", date);

				System.Net.Http.HttpContent httpContent = new StringContent(json, Encoding.UTF8);
				httpContent.Headers.ContentType = new MediaTypeHeaderValue("application/json");
				Task<System.Net.Http.HttpResponseMessage> response =  client.PostAsync(new Uri(url), httpContent);

				System.Net.Http.HttpContent responseContent = response.Result.Content;
				string result = responseContent.ReadAsStringAsync().Result;
				Console.WriteLine("Return Result: " + result);
			}
			catch (Exception excep)
			{
				Console.WriteLine("API Post Exception: " + excep.Message);
			}
		}
	}
}
