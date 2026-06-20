# Surge Discord Rules

Surge rule sets for Discord and manually maintained Discord voice IP CIDR ranges.

## Usage

Add this to the `[Rule]` section of your Surge profile:

```ini
RULE-SET,https://raw.githubusercontent.com/jfmoe/surge-discord-voice-rules/main/Discord.list,Discord
```

## Rule Sets

- `Discord.list`: blackmatrix7's Surge Discord rules plus the local Discord voice IP rules.
- `DiscordVoice.list`: only the local Discord voice IP rules.

## Maintenance

Discord domain rules are synced daily from:

https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Surge/Discord/Discord.list

To add or update Discord voice IPs, edit `discord-voice-ip.yaml`, then run:

```bash
ruby scripts/update.rb
```
