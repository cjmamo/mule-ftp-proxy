require 'lib/mule-ftp-proxy/mule-ftp-proxy-driver'

driver  MuleFtpProxyDriver

#FTP hostname & port no. to which requests should be proxied to
driver_args 'localhost', 8021

#Port no. on which the FTP proxy will listen for requests
port  8000