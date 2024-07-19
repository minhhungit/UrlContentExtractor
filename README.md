# Url Content Extractor

This PowerShell script creates an HTTP listener that accepts requests to extract content from a URL using the Trafilatura tool.

## Usage
To use this script, simply run it in PowerShell and specify the port number you want to use (default is 8181):
```
.\UrlContentExtractor.ps1 -Port 8181
```

Once the script is running, you can send an HTTP request to `http://localhost:8181/extract/` with a url query string parameter set to the URL you want to extract content from. For example:

```
http://localhost:8181/extract/?url=https://example.com
```

The script will execute the [Trafilatura tool](https://trafilatura.readthedocs.io/en/latest/) and return the extracted content in JSON format.

## Response Format
The script returns a JSON response with the following format:
```json
{
  "status": "success",
  "data": "<extracted content>"
}
```
If an error occurs, the script returns a JSON response with the following format:
```json
{
  "status": "error",
  "message": "<error message>"
}
```
## Error Handling
The script catches any errors that occur during the execution of the Trafilatura tool and returns a JSON response with a 500 status code. If no URL is provided, the script returns a JSON response with a 400 status code.

## Dependencies
This script requires the Trafilatura tool to be installed on the system.

## License
This script is licensed under the MIT License. See the LICENSE file for details.

## Contributing
Contributions are welcome! If you find any issues or want to improve the script, please open a pull request.
