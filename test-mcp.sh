#!/bin/bash
# Quick script to test MCP server calls

export GITLAB_API_URL=http://localhost:9080/api/v4
export GITLAB_PERSONAL_ACCESS_TOKEN=glpat-mcp-test-0a2fc6ad3a2409bac21ae404f07c8331bcb2cae7
export GITLAB_READ_ONLY_MODE=false
export USE_GITLAB_WIKI=true
export USE_PIPELINE=true

# Test: Search repositories
echo '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"search_repositories","arguments":{"search":"test"}}}' | node build/index.js 2>/dev/null | jq '.'
