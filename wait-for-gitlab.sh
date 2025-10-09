#!/bin/bash
# Wait for GitLab to be ready

echo "Waiting for GitLab to start (this takes 2-5 minutes)..."
echo ""

MAX_ATTEMPTS=60
ATTEMPT=0

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    ATTEMPT=$((ATTEMPT + 1))

    # Check if container is running
    if ! docker ps | grep -q gitlab-ce-test; then
        echo "❌ GitLab container is not running!"
        exit 1
    fi

    # Try to hit the health endpoint
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:9080/-/health 2>/dev/null)

    if [ "$HTTP_CODE" = "200" ]; then
        echo ""
        echo "✅ GitLab is ready!"
        echo ""
        echo "Next steps:"
        echo "1. Get root password: docker exec -it gitlab-ce-test grep 'Password:' /etc/gitlab/initial_root_password"
        echo "2. Access GitLab: http://localhost:9080"
        echo "3. Login with username 'root' and the password from step 1"
        echo "4. Create a Personal Access Token (see TESTING.md for details)"
        echo ""
        exit 0
    fi

    # Show progress
    echo -n "."
    sleep 5
done

echo ""
echo "⚠️  Timeout waiting for GitLab. Check logs with:"
echo "   docker compose -f docker-compose.test.yml logs gitlab"
exit 1
