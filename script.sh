# 1. Setup upstream remote
          git remote add upstream https://github.com/hayagreevan-presidio/upstream-sync-test-upstream.git
          git fetch upstream main

            git checkout upstream-main
          # 2. Check if upstream is ahead of our main
          # This compares the local main branch with the fetched upstream branch
          LOCAL_HASH=$(git rev-parse HEAD)
          UPSTREAM_HASH=$(git rev-parse upstream/main)

          if [ "$LOCAL_HASH" = "$UPSTREAM_HASH" ]; then
            echo "No changes found. Skipping PR creation."
            echo "has_changes=false" 
          elif $(gh pr list --repo github.com/hayagreevan-v/upstream-sync-test-fork -s open -S "Merge from Upstream main"); then
            echo "Already an open PR exists"
          else
            echo "New commits detected in upstream."
            echo "has_changes=true" 
            
            
            # 4. Merge upstream into the new branch
            # We use --no-ff to ensure a merge commit exists for the PR
            git merge upstream/main --no-edit
            
            # 5. Push the branch to your fork
            git push origin upstream-main
            
            # 6. Use GitHub CLI to create the PR
            gh pr create \
              --repo github.com/hayagreevan-v/upstream-sync-test-fork \
              --title "Merge from Upstream" \
              --body "This is an automated PR to sync changes from upstream repo." \
              --base main \
              --head upstream-main
          fi