# Surge Discord Voice Rules

A Surge rule set for Discord voice IP CIDR ranges.

## Usage

Add this to the `[Rule]` section of your Surge profile:

```ini
RULE-SET,https://raw.githubusercontent.com/jfmoe/surge-discord-voice-rules/main/discord-voice-ip.list,Discord
```

The rule set only contains IP CIDR rules. The policy name is intentionally kept in your local Surge profile.

Source: https://raw.githubusercontent.com/FQrabbit/SSTap-Rule/refs/heads/master/rules/Discord-All.rules

Manually captured IPs that are missing from the upstream source live in `manual-extra-cidrs.txt` and are merged during updates.
