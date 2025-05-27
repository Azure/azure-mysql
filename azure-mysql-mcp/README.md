# Azure Database for MySQL MCP Server (Preview)

A [Model Context Protocol (MCP)](https://modelcontextprotocol.io/introduction) Server that let’s your AI models talk to data hosted in Azure Database for MySQL according to the MCP standard! 

By utilizing this server, you can effortlessly connect any AI application that supports MCP to your MySQL flexible server (using either MySQL password-based authentication or Microsoft Entra authentication methods), enabling you to provide your business data as meaningful context in a standardized and secure manner.

This server exposes the following tools, which can be invoked by MCP Clients in your AI agents, AI applications or tools like Claude Desktop and Visual Studio Code:

- **List all databases** in your Azure Database for MySQL flexible server instance.
- **List all tables** in a database along with their schema information.
- **Execute read queries** to retrieve data from your database.
- **Insert or update records** in your database.
- **Create a new table or drop an existing table** in your database.
- **List Azure Database for MySQL flexible server configuration**, including its MySQL version, and compute and storage configurations. *
- Retrieve specific **server parameter values.** *
  
_*Available when using Microsoft Entra authentication method_

## Getting Started

### Prerequisites

- [Python](https://www.python.org/downloads/) 3.10 or above
- An Azure Database for MySQL flexible server instance with a database containing your business data. For instructions on creating a flexible instance, setting up a database, and connecting to it, please refer to this [quickstart guide](https://learn.microsoft.com/en-us/azure/mysql/flexible-server/quickstart-create-server-portal).
- An MCP Client application or tool such as [Claude Desktop](https://claude.ai/download) or [Visual Studio Code](https://code.visualstudio.com/download).

### Installation

1. Clone the `azure-mysql` repository:

    ```
    git clone https://github.com/Azure/azure-mysql.git
    cd azure-mysql
    cd azure-mysql-mcp
    ```

    Alternatively, you can download only the `azure_mysql_mcp.py` file to your working folder.

2.	Create a virtual environment:

    Windows cmd.exe:
  	```
    python -m venv azure-mysql-mcp-venv
    .\azure-mysql-mcp-venv\Scripts\activate.bat
    ```
    Windows Powershell:
  	```
    python -m venv azure-mysql-mcp-venv
    .\azure-mysql-mcp-venv\Scripts\Activate.ps1
    ```
    Linux and MacOS:
  	```
    python -m venv azure-mysql-mcp-venv
    source ./azure-mysql-mcp-venv/bin/activate 
    ```

4. Install the dependencies:

    ```
    pip install mcp[cli]
    pip install mysql-connector-python[binary]
    pip install azure-mgmt-mysql-flexible-server
    pip install azure-identity
    ```


### Use the MCP Server with Claude Desktop

1. In the Claude Desktop app, navigate to the "Settings" pane, select the "Developer" tab and click on "Edit Config".
2. Open the `claude_desktop_config.json` file and add the following configuration to the "mcpServers" section to configure the Azure Database for MySQL MCP server:

    ```json
    {
        "mcpServers": {
            "azure-mysql-mcp": {
                "command": "<path to the virtual environment>\\azure-mysql-mcp-venv\\Scripts\\python",
                "args": [
                    "<path to azure_mysql_mcp.py file>\\azure_mysql_mcp.py"
                ],
                "env": {
                    "MYSQLHOST": "<Fully qualified name of your Azure Database for MySQL instance>",
                    "MYSQLUSER": "<Your Azure Database for MySQL username>",
                    "MYSQLPASSWORD": "<Your password>"
                }
            }        
        }
    }
    ```
    **Note**: Here, we use password-based authentication to connect the MCP Server to Azure Database for MySQL for testing purposes only. However, we recommend using Microsoft Entra authentication. Please refer to [these instructions](#using-microsoft-entra-authentication-method) for guidance.
3. Restart the Claude Desktop app.
4. Upon restarting, you should see a hammer icon at the bottom of the input box. Selecting this icon will display the tools provided by the MCP Server.

You are now all set to start interacting with your data using natural language queries through Claude Desktop!

### Use the MCP Server with Visual Studio Code

1. In Visual Studio Code, navigate to "File", select "Preferences" and then choose "Settings".
2. Search for "MCP" and select "Edit in settings.json".
3. Add the following configuration to the "mcp" section of the `settings.json` file:

    ```JSON
    {
        "mcp": {
            "inputs": [],
            "servers": {
                "azure-mysql-mcp": {
                    "command": "<path to the virtual environment>\\azure-mysql-mcp-venv\\Scripts\\python",
                    "args": [
                        "<path to azure_mysql_mcp.py file>\\azure_mysql_mcp.py"
                    ],
                    "env": {
                        "MYSQLHOST": "<Fully qualified name of your Azure Database for MySQL instance>",
                        "MYSQLUSER": "<Your Azure Database for MySQL username>",
                        "MYSQLPASSWORD": "<Your password>"
                    }
                }
            }
        }
    }
    ```
    **Note**: Here, we use password-based authentication to connect the MCP Server to Azure Database for MySQL for testing purposes only. However, we recommend using Microsoft Entra authentication. Please refer to [these instructions](#using-microsoft-entra-authentication-method) for guidance.
4. Select the "Copilot" status icon in the upper-right corner to open the GitHub Copilot Chat window. 
5. Choose "Agent mode" from the dropdown at the bottom of the chat input box.
5. Click on "Select Tools" (hammer icon) to view the Tools exposed by the MCP Server.

You are now all set to start interacting with your data using natural language queries through VS Code!

## Using Microsoft Entra authentication method

To Microsoft Entra authentication method (recommended) to connect your MCP Server to Azure Database for MySQL, update the MCP Server configuration in `claude_desktop_config.json` file \(Claude Desktop\) and `settings.json` \(Visual Studio Code\) with the following code:

```json
"azure-mysql-mcp": {
    "command": "<path to the virtual environment>\\azure-mysql-mcp-venv\\Scripts\\python",
    "args": [
        "<path to azure_mysql_mcp.py file>\\azure_mysql_mcp.py"
    ],
    "env": {
        "MYSQLHOST": "<Fully qualified name of your Azure Database for MySQL instance>",
        "MYSQLUSER": "<Your Microsoft Entra ID username or the resource name of your Azure resource with a system-assigned identity or the identity name>",
        "AZURE_USE_AAD": "True",
        "AZURE_SUBSCRIPTION_ID": "<Your Azure subscription ID>",
        "AZURE_RESOURCE_GROUP": "<Your Resource Group that contains the Azure Database for MySQL instance>"
    }
}
```