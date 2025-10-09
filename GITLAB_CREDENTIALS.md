# GitLab CE Test Instance - Credentials

**IMPORTANT**: These are credentials for the LOCAL TEST INSTANCE ONLY.
This is NOT your organization's GitLab.

## Access Information

- **URL**: http://localhost:9080
- **Username**: `root`
- **Password**: `z15rXI8I0IFk8Ri6+CGGRCJ7V1m8GI06yjf7Q/vGaTg=`

## Next Steps

1. **Access GitLab Web UI**:
   - Open http://localhost:9080 in your browser
   - Login with root credentials above

2. **Personal Access Token** (ALREADY CREATED):
   - Token: `glpat-mcp-test-0a2fc6ad3a2409bac21ae404f07c8331bcb2cae7`
   - Name: `MCP Server Test`
   - Scopes: `api`
   - Expires: 30 days from now
   - **Already saved in .env file** ✓

3. **Configuration Complete**:
   - .env file is already configured
   - Ready to test MCP server!

4. **Create test repositories** (via Web UI):
   - test-repo-1 (basic testing)
   - test-repo-2 (multi-project testing)
   - test-repo-3 (additional use cases)

## GitLab Services Status

All services are running:
- gitaly ✓
- gitlab-kas ✓
- gitlab-workhorse ✓
- nginx ✓
- postgresql ✓
- puma ✓
- redis ✓
- sidekiq ✓
- sshd ✓

## Security Note

This password will be automatically deleted after 24 hours. Change it in the UI if you need longer access.
