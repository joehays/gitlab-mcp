#!/usr/bin/env ruby
# Create a personal access token for root user

user = User.find_by_username('root')
token_value = 'glpat-mcp-test-' + SecureRandom.hex(20)

token = user.personal_access_tokens.create!(
  name: 'MCP Server Test',
  scopes: [:api],
  expires_at: 30.days.from_now
)

token.set_token(token_value)
token.save!

puts token_value
