#!/bin/bash

export GITLAB_API_URL=http://localhost:9080/api/v4
export GITLAB_PERSONAL_ACCESS_TOKEN=glpat-mcp-test-0a2fc6ad3a2409bac21ae404f07c8331bcb2cae7

PROJECT_ID="1"
MR_PROJECT_ID="2"

echo "=== GitLab MCP Tool Testing ==="
echo ""

# Helper function to call MCP tools
call_tool() {
    local tool_name=$1
    local args=$2
    local id=$((RANDOM))
    
    echo "{\"jsonrpc\":\"2.0\",\"id\":$id,\"method\":\"tools/call\",\"params\":{\"name\":\"$tool_name\",\"arguments\":$args}}" | \
        node build/index.js 2>/dev/null
}

# Test Issues
echo "--- Issues Management ---"

echo "✓ create_issue (already tested)"

echo -n "Testing list_issues... "
result=$(call_tool "list_issues" "{\"project_id\":\"$PROJECT_ID\"}")
if echo "$result" | jq -e '.result.content[0].text' > /dev/null 2>&1; then
    count=$(echo "$result" | jq -r '.result.content[0].text' | jq -r '.items | length')
    echo "✓ Found $count issue(s)"
else
    echo "✗ FAILED"
fi

echo -n "Testing get_issue... "
result=$(call_tool "get_issue" "{\"project_id\":\"$PROJECT_ID\",\"issue_iid\":\"1\"}")
if echo "$result" | jq -e '.result.content[0].text' > /dev/null 2>&1; then
    title=$(echo "$result" | jq -r '.result.content[0].text' | jq -r '.title')
    echo "✓ Retrieved: $title"
else
    echo "✗ FAILED"
fi

echo -n "Testing update_issue... "
result=$(call_tool "update_issue" "{\"project_id\":\"$PROJECT_ID\",\"issue_iid\":\"1\",\"description\":\"Updated description via MCP\"}")
if echo "$result" | jq -e '.result.content[0].text' > /dev/null 2>&1; then
    echo "✓ Issue updated"
else
    echo "✗ FAILED"
fi

echo -n "Testing create_issue_note... "
result=$(call_tool "create_issue_note" "{\"project_id\":\"$PROJECT_ID\",\"issue_iid\":\"1\",\"note_body\":\"This is a test comment via MCP\"}")
if echo "$result" | jq -e '.result.content[0].text' > /dev/null 2>&1; then
    echo "✓ Note added"
else
    echo "✗ FAILED"
fi

# Test Labels
echo ""
echo "--- Labels ---"

echo -n "Testing create_label... "
result=$(call_tool "create_label" "{\"project_id\":\"$PROJECT_ID\",\"name\":\"test-label\",\"color\":\"#FF0000\"}")
if echo "$result" | jq -e '.result.content[0].text' > /dev/null 2>&1; then
    echo "✓ Label created"
else
    echo "✗ FAILED"
fi

echo -n "Testing list_labels... "
result=$(call_tool "list_labels" "{\"project_id\":\"$PROJECT_ID\"}")
if echo "$result" | jq -e '.result.content[0].text' > /dev/null 2>&1; then
    count=$(echo "$result" | jq -r '.result.content[0].text' | jq -r 'length')
    echo "✓ Found $count label(s)"
else
    echo "✗ FAILED"
fi

# Test Files
echo ""
echo "--- File Operations ---"

echo -n "Testing get_file_contents... "
result=$(call_tool "get_file_contents" "{\"project_id\":\"$PROJECT_ID\",\"file_path\":\"README.md\",\"ref\":\"main\"}")
if echo "$result" | jq -e '.result.content[0].text' > /dev/null 2>&1; then
    echo "✓ File retrieved"
else
    echo "✗ FAILED"
fi

echo -n "Testing create_or_update_file... "
result=$(call_tool "create_or_update_file" "{\"project_id\":\"$PROJECT_ID\",\"file_path\":\"test.txt\",\"branch\":\"main\",\"content\":\"Test content from MCP\",\"commit_message\":\"Add test file via MCP\"}")
if echo "$result" | jq -e '.result.content[0].text' > /dev/null 2>&1; then
    echo "✓ File created"
else
    echo "✗ FAILED"
fi

echo -n "Testing get_repository_tree... "
result=$(call_tool "get_repository_tree" "{\"project_id\":\"$PROJECT_ID\"}")
if echo "$result" | jq -e '.result.content[0].text' > /dev/null 2>&1; then
    count=$(echo "$result" | jq -r '.result.content[0].text' | jq -r 'length')
    echo "✓ Found $count file(s)"
else
    echo "✗ FAILED"
fi

# Test Branches
echo ""
echo "--- Branches ---"

echo -n "Testing create_branch... "
result=$(call_tool "create_branch" "{\"project_id\":\"$MR_PROJECT_ID\",\"branch\":\"test-branch\",\"ref\":\"main\"}")
if echo "$result" | jq -e '.result.content[0].text' > /dev/null 2>&1; then
    echo "✓ Branch created"
else
    echo "✗ FAILED"
fi

# Test Commits
echo ""
echo "--- Commits ---"

echo -n "Testing list_commits... "
result=$(call_tool "list_commits" "{\"project_id\":\"$PROJECT_ID\"}")
if echo "$result" | jq -e '.result.content[0].text' > /dev/null 2>&1; then
    count=$(echo "$result" | jq -r '.result.content[0].text' | jq -r 'length')
    echo "✓ Found $count commit(s)"
else
    echo "✗ FAILED"
fi

# Test Merge Requests
echo ""
echo "--- Merge Requests ---"

echo -n "Testing create_merge_request... "
result=$(call_tool "create_merge_request" "{\"project_id\":\"$MR_PROJECT_ID\",\"source_branch\":\"test-branch\",\"target_branch\":\"main\",\"title\":\"Test MR from MCP\"}")
if echo "$result" | jq -e '.result.content[0].text' > /dev/null 2>&1; then
    mr_iid=$(echo "$result" | jq -r '.result.content[0].text' | jq -r '.iid')
    echo "✓ MR #$mr_iid created"
    echo "$mr_iid" > /tmp/test_mr_iid.txt
else
    echo "✗ FAILED"
fi

if [ -f /tmp/test_mr_iid.txt ]; then
    MR_IID=$(cat /tmp/test_mr_iid.txt)
    
    echo -n "Testing list_merge_requests... "
    result=$(call_tool "list_merge_requests" "{\"project_id\":\"$MR_PROJECT_ID\"}")
    if echo "$result" | jq -e '.result.content[0].text' > /dev/null 2>&1; then
        count=$(echo "$result" | jq -r '.result.content[0].text' | jq -r '.items | length')
        echo "✓ Found $count MR(s)"
    else
        echo "✗ FAILED"
    fi
    
    echo -n "Testing get_merge_request... "
    result=$(call_tool "get_merge_request" "{\"project_id\":\"$MR_PROJECT_ID\",\"merge_request_iid\":\"$MR_IID\"}")
    if echo "$result" | jq -e '.result.content[0].text' > /dev/null 2>&1; then
        title=$(echo "$result" | jq -r '.result.content[0].text' | jq -r '.title')
        echo "✓ Retrieved: $title"
    else
        echo "✗ FAILED"
    fi
fi

# Test Projects
echo ""
echo "--- Projects ---"

echo -n "Testing get_project... "
result=$(call_tool "get_project" "{\"project_id\":\"$PROJECT_ID\"}")
if echo "$result" | jq -e '.result.content[0].text' > /dev/null 2>&1; then
    name=$(echo "$result" | jq -r '.result.content[0].text' | jq -r '.name')
    echo "✓ Retrieved: $name"
else
    echo "✗ FAILED"
fi

echo -n "Testing list_projects... "
result=$(call_tool "list_projects" "{}")
if echo "$result" | jq -e '.result.content[0].text' > /dev/null 2>&1; then
    count=$(echo "$result" | jq -r '.result.content[0].text' | jq -r '.items | length')
    echo "✓ Found $count project(s)"
else
    echo "✗ FAILED"
fi

echo ""
echo "=== Test Summary ==="
echo "Basic tool testing complete. See evaluation-results.md for details."

