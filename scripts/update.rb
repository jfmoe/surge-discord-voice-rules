require 'net/http'
require 'uri'
require 'yaml'

DISCORD_SOURCE_URL = 'https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Surge/Discord/Discord.list'
VOICE_SOURCE = File.expand_path('../discord-voice-ip.yaml', __dir__)
VOICE_OUTPUT = File.expand_path('../DiscordVoice.list', __dir__)
DISCORD_OUTPUT = File.expand_path('../Discord.list', __dir__)
CIDR_PATTERN = /\A(?:\d{1,3}\.){3}\d{1,3}\/(?:[0-9]|[1-2][0-9]|3[0-2])\z/

def fetch_text(url)
  response = Net::HTTP.get_response(URI(url))
  raise "failed to fetch #{url}: HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

  response.body
end

def normalize_cidrs(values)
  values.map(&:to_s).map(&:strip).reject(&:empty?).each do |cidr|
    raise "invalid CIDR in discord-voice-ip.yaml: #{cidr}" unless cidr.match?(CIDR_PATTERN)

    octets = cidr.split('/').first.split('.').map(&:to_i)
    raise "invalid IPv4 address in discord-voice-ip.yaml: #{cidr}" if octets.any? { |octet| octet > 255 }
  end.uniq.sort_by { |cidr| [cidr.split('/').first.split('.').map(&:to_i), cidr.split('/').last.to_i] }
end

def rule_lines(text)
  text.lines.map(&:strip).reject { |line| line.empty? || line.start_with?('#') }
end

discord_text = fetch_text(DISCORD_SOURCE_URL)
discord_rules = rule_lines(discord_text)
raise 'no Discord rules parsed from upstream' if discord_rules.empty?

voice_config = YAML.load_file(VOICE_SOURCE)
voice_cidrs = normalize_cidrs(Array(voice_config.fetch('cidrs')))
raise 'no voice CIDRs found in discord-voice-ip.yaml' if voice_cidrs.empty?

voice_rules = voice_cidrs.map { |cidr| "IP-CIDR,#{cidr},no-resolve" }

content = [
  '# NAME: DiscordVoice',
  '# SOURCE: discord-voice-ip.yaml',
  "# UPDATED: #{Time.now.utc.strftime('%Y-%m-%dT%H:%M:%SZ')}",
  "# IP-CIDR: #{voice_rules.length}",
  "# TOTAL: #{voice_rules.length}",
  *voice_rules
].join("\n") + "\n"

File.write(VOICE_OUTPUT, content)

combined_rules = (discord_rules + voice_rules).uniq
combined_content = [
  '# NAME: Discord',
  "# SOURCE: #{DISCORD_SOURCE_URL}",
  '# VOICE-SOURCE: discord-voice-ip.yaml',
  "# UPDATED: #{Time.now.utc.strftime('%Y-%m-%dT%H:%M:%SZ')}",
  "# TOTAL: #{combined_rules.length}",
  *combined_rules
].join("\n") + "\n"

File.write(DISCORD_OUTPUT, combined_content)
puts "Updated #{DISCORD_OUTPUT} with #{discord_rules.length} upstream rule(s) and #{voice_rules.length} voice rule(s)"
puts "Updated #{VOICE_OUTPUT} with #{voice_rules.length} voice rule(s)"
