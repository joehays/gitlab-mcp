# GitLab CE Test Environment Setup

This document describes the local GitLab CE instance for safely testing the MCP server.

## Overview

We're using a containerized GitLab CE instance to avoid any risk to your organization's GitLab. This gives us:
- Complete isolation
- Full admin access
- Ability to create/delete test data freely
- Airgapped testing capability

## Quick Start

### 1. Start GitLab CE

```bash
# Start GitLab CE container
docker compose -f docker-compose.test.yml up -d gitlab

# Monitor startup (takes 2-5 minutes)
docker compose -f docker-compose.test.yml logs -f gitlab

# Wait for "gitlab Reconfigured!" message
```

**Note**: GitLab CE initial startup takes 2-5 minutes. Be patient!

### 2. Access GitLab Web UI

Once GitLab is ready:

```bash
# Get the initial root password
docker exec -it gitlab-ce-test grep 'Password:' /etc/gitlab/initial_root_password

# Or view the full file
docker exec -it gitlab-ce-test cat /etc/gitlab/initial_root_password
```

**Access GitLab**:
- URL: http://localhost:9080
- Username: `root`
- Password: (from command above)

**IMPORTANT**: Change the root password immediately after first login!

### 3. Create Personal Access Token

1. Log in to GitLab web UI
2. Click on your avatar (top right) → **Edit Profile**
3. Left sidebar → **Access Tokens**
4. Create new token:
   - **Token name**: `MCP Server Test`
   - **Scopes**: Check `api` (full API access)
   - **Expiration date**: Set 30 days from now
5. Click **Create personal access token**
6. **Copy the token immediately** (you won't see it again!)

### 4. Configure MCP Server

```bash
# Update .env file
cat > .env <<EOF
GITLAB_API_URL=http://localhost:9080/api/v4
GITLAB_TOKEN=your-token-from-step-3
GITLAB_READ_ONLY_MODE=false
USE_GITLAB_WIKI=true
USE_PIPELINE=true
GITLAB_PROJECT_ACCESS_LEVEL=50
SSE=false
STREAMABLE_HTTP=false
EOF
```

**Important**: Since GitLab is at `localhost:9080`, use this URL for MCP server API calls.

### 5. Create Test Repositories

#### Option A: Via Web UI

1. Go to http://localhost:9080
2. Click **New project** → **Create blank project**
3. Create these test projects:
   - `test-repo-1` (for basic testing)
   - `test-repo-2` (for multi-project testing)
   - `test-repo-3` (for additional use case testing)

#### Option B: Via GitLab API (after MCP is working)

```bash
# Test API connection
curl -H "PRIVATE-TOKEN: your-token" http://localhost:9080/api/v4/projects

# Create test project
curl -X POST -H "PRIVATE-TOKEN: your-token" \
  "http://localhost:9080/api/v4/projects" \
  -d "name=test-repo-1&visibility=private"
```

### 6. Test MCP Server

```bash
# Test MCP server initialization
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0.0"}}}' | \
  node build/index.js

# Should return JSON with server capabilities and available tools
```

## Test Data Setup

### Recommended Test Data Structure

For comprehensive MCP testing, create:

**Project: `test-repo-1`**
- 5-10 test issues (with various labels, milestones)
- 2-3 test merge requests
- Some files in repository (README.md, test files)
- 2-3 wiki pages
- A simple .gitlab-ci.yml for pipeline testing

**Project: `test-repo-3`**
- Additional use case testing
- Issues for: feature requests, bug reports, enhancements
- Labels: `bug`, `enhancement`, `documentation`
- Milestone: `Evaluation`

### Sample .gitlab-ci.yml for Pipeline Testing

```yaml
# test-repo-1/.gitlab-ci.yml
stages:
  - test
  - build

test-job:
  stage: test
  script:
    - echo "Running tests..."
    - sleep 5
    - echo "Tests passed!"

build-job:
  stage: build
  script:
    - echo "Building..."
    - sleep 3
    - echo "Build complete!"
```

## Managing the Test Environment

### Start/Stop/Restart

```bash
# Start GitLab
docker compose -f docker-compose.test.yml up -d gitlab

# Stop GitLab
docker compose -f docker-compose.test.yml stop gitlab

# Restart GitLab
docker compose -f docker-compose.test.yml restart gitlab

# View logs
docker compose -f docker-compose.test.yml logs -f gitlab
```

### Check Health

```bash
# Check if GitLab is ready
docker exec -it gitlab-ce-test gitlab-ctl status

# Check specific service
docker exec -it gitlab-ce-test gitlab-ctl status puma

# Health check via API
curl http://localhost:9080/-/health
```

### Reset Environment (Clean Slate)

```bash
# Stop and remove everything
docker compose -f docker-compose.test.yml down -v

# This deletes ALL data including:
# - All projects, issues, MRs
# - All users (except root)
# - All configuration
# - All logs

# Start fresh
docker compose -f docker-compose.test.yml up -d gitlab
```

## Troubleshooting

### GitLab won't start

```bash
# Check logs
docker compose -f docker-compose.test.yml logs gitlab

# Check container status
docker ps -a | grep gitlab

# Check disk space (GitLab needs several GB)
df -h
```

### Can't access http://localhost:9080

```bash
# Check port binding
docker ps | grep 9080

# Check if GitLab is ready
docker exec -it gitlab-ce-test gitlab-ctl status

# Wait longer - initial startup takes 2-5 minutes
```

### Forgot root password

```bash
# Get initial password
docker exec -it gitlab-ce-test cat /etc/gitlab/initial_root_password

# Or reset via GitLab Rails console (advanced)
docker exec -it gitlab-ce-test gitlab-rails console
# In console: user = User.find_by(username: 'root')
#             user.password = 'new_password'
#             user.password_confirmation = 'new_password'
#             user.save!
```

### MCP can't connect to GitLab

```bash
# Test API from host
curl http://localhost:9080/api/v4/version

# Test API with token
curl -H "PRIVATE-TOKEN: your-token" http://localhost:9080/api/v4/projects

# Check .env configuration
cat .env

# Make sure GITLAB_API_URL is http://localhost:9080/api/v4
```

### Out of disk space

GitLab CE can use 5-10GB of disk space. To check:

```bash
# Check volume sizes
docker system df -v

# Clean up if needed
docker volume prune
docker system prune
```

## Resource Usage

**Expected resource consumption**:
- **Disk**: 5-10 GB (mostly in `gitlab-data` volume)
- **Memory**: 2-4 GB RAM (reduced from default 8GB via config)
- **CPU**: 2-4 cores during startup, 1-2 during normal operation

**To reduce resources further**, edit `docker-compose.test.yml`:
- Reduce `puma['worker_processes']`
- Reduce `sidekiq['max_concurrency']`
- Reduce `postgresql['shared_buffers']`

## Next Steps After Setup

1. ✅ GitLab CE running
2. ✅ Root password obtained
3. ✅ Personal access token created
4. ✅ Test projects created
5. ⏳ **Test MCP server** → See README.EVALUATION.md
6. ⏳ **Evaluate all 40+ tools**
7. ⏳ **Document findings**

## Cleanup After Evaluation

When done with evaluation:

```bash
# Stop and remove everything (including data)
docker compose -f docker-compose.test.yml down -v

# Remove images (optional - saves disk space)
docker rmi gitlab/gitlab-ce:latest
```

## Network Configuration

GitLab and MCP server are on the same Docker network (`gitlab-mcp-net`). This allows:
- MCP server to reach GitLab at `http://gitlab.local` (from within containers)
- Host to reach GitLab at `http://localhost:9080`

**When running MCP on host** (recommended): Use `http://localhost:9080/api/v4`
**When running MCP in container**: Use `http://gitlab.local/api/v4`
