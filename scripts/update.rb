require 'net/http'
require 'uri'

SOURCE_URL = 'https://raw.githubusercontent.com/FQrabbit/SSTap-Rule/refs/heads/master/rules/Discord-All.rules'
OUTPUT = File.expand_path('../discord-voice-ip.list', __dir__)
MANUAL_EXTRA = File.expand_path('../manual-extra-cidrs.txt', __dir__)

body = Net::HTTP.get(URI(SOURCE_URL))
cidrs = body.scan(/\b(?:\d{1,3}\.){3}\d{1,3}\/\d{1,2}\b/)
if File.exist?(MANUAL_EXTRA)
  cidrs.concat(File.read(MANUAL_EXTRA).scan(/\b(?:\d{1,3}\.){3}\d{1,3}\/\d{1,2}\b/))
end
cidrs = cidrs.uniq
raise 'no CIDR entries parsed' if cidrs.empty?

content = [
  '# Discord voice IP CIDR rules for Surge',
  "# Source: #{SOURCE_URL}",
  "# Generated: #{Time.now.utc.strftime('%Y-%m-%dT%H:%M:%SZ')}",
  *cidrs.map { |cidr| "IP-CIDR,#{cidr},no-resolve" }
].join("\n") + "\n"

File.write(OUTPUT, content)
puts "Updated #{OUTPUT} with #{cidrs.length} CIDR entries"
