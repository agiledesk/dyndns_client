require 'net/https'
require 'uri' 

hostname = "your_hostname"
username = 'your_username'
password = 'your_password'

external_ip=''
uri = URI.parse('http://checkip.dyndns.org:8245')
Net::HTTP.new(uri.host,uri.port).start { |http|
 http.request_get('/') { |resp|
   # The response looks like:
   #
   # Current IP Address: 81.155.100.200
   #
   external_ip = resp.read_body.gsub(/[^:]*: ([^<]*)<.*$/,"\\1")
   external_ip = external_ip.gsub(/\n/,'')
 }
}
p Time.new.strftime("%Y-%m-%d %H:%M:%S")
p "Current IP Address: #{external_ip}"

# perform the update
# This header is required by dyndns.org
headers = {
 "User-Agent" => "My Server - #{__FILE__} - 1.0" 
}

uri = URI.parse('http://members.dyndns.org/')
http = Net::HTTP.new(uri.host, uri.port)
# switch on SSL
#http.use_ssl = true if uri.scheme == "https"
# suppress verification warning
#http.verify_mode = OpenSSL::SSL::VERIFY_NONE

req = Net::HTTP::Get.new("/nic/update?hostname=#{hostname}&myip=#{external_ip}&wildcard=OFF&mx=OFF", headers)
# authentication details
req.basic_auth username, password
resp = http.request(req)
# print out the response for the update
p "Update result: #{resp.body}"

