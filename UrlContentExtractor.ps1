param (
    [int]$Port = 8181
)

try
{
	# Define the HTTP listener
	$listener = [System.Net.HttpListener]::new()
	$listener.Prefixes.Add("http://*:$Port/extract/")
	$listener.Start()
	Write-Output "Listening on http://localhost:$Port/extract/"
	
	while ($true) {
		
        try {
            # Wait for an incoming request
            $context = $listener.GetContext()
			
			$request = $context.Request
            $response = $context.Response
			$response.ContentType = "application/json"
			
			# Read the URL from the query string
			$url = $request.QueryString["url"]
			$escapedUrl = [System.Security.SecurityElement]::Escape($url)
			#Write-Output $escapedUrl
			
			
			
			if (![string]::IsNullOrEmpty($escapedUrl)) {
				
				# Execute Trafilatura tool
				$trafilaturaCommand = "trafilatura -u `"$escapedUrl`""

				# Create a new process to run the trafilatura command
				$process = New-Object System.Diagnostics.Process
				$process.StartInfo = New-Object System.Diagnostics.ProcessStartInfo
				$process.StartInfo.FileName = "cmd.exe"
				$process.StartInfo.Arguments = "/c $trafilaturaCommand"
				$process.StartInfo.RedirectStandardOutput = $true
				$process.StartInfo.RedirectStandardError = $true
				$process.StartInfo.UseShellExecute = $false
				$process.StartInfo.CreateNoWindow = $true
				$process.StartInfo.StandardOutputEncoding = [System.Text.Encoding]::UTF8

				# Start the process and wait for it to exit
				$process.Start() | Out-Null
				$process.WaitForExit()

				# Read the standard output and standard error
				$output = $process.StandardOutput.ReadToEnd()
				$errorOutput = $process.StandardError.ReadToEnd()

				if ($process.ExitCode -ne 0) {
					# Return the error as JSON
					$errorResponse = @{
						status = "error"
						message = $errorOutput
					}
					$responseString = $errorResponse | ConvertTo-Json
					$response.StatusCode = 500
				} else {
					# Return the output as JSON
					$responseData = @{
						status = "success"
						data = $output
					}
					$responseString = $responseData | ConvertTo-Json
					$response.StatusCode = 200
					
					#Write-Output $responseString
				}
				
				# Write the metrics to the response
				$buffer = [System.Text.Encoding]::UTF8.GetBytes($responseString)
				$response.ContentLength64 = $buffer.Length
				$response.OutputStream.Write($buffer, 0, $buffer.Length)
				$response.OutputStream.Close()
			} else {
				# Return an error if no URL is provided
				$errorResponse = @{
					status = "error"
					message = "No URL provided"
				}
				$responseString = $errorResponse | ConvertTo-Json
				$response.StatusCode = 400
				
				$buffer = [System.Text.Encoding]::UTF8.GetBytes($errorResponse)
				$response.ContentLength64 = $buffer.Length
				$response.OutputStream.Write($buffer, 0, $buffer.Length)
				$response.OutputStream.Close()
			}
		}
		catch {
            Write-Error "Error processing request: $_"
			break;
        }
	}
	
}catch {
    Write-Error "Failed to start HTTP listener: $_"
} finally {
    if ($listener) {
        $listener.Stop()
        $listener.Close()
    }
}
