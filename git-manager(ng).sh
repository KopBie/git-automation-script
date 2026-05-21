#!/bin/bash
# Move to the directory where this script is located
cd "$(dirname "$0")"

# Colors for display
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

header() {
    clear
    echo "========================================="
    echo "    (GIT MANAGER) PUSH FILES TO GITHUB   "
    echo "========================================="
    if [ -d ".git" ]; then
        CURRENT_REPO=$(git remote get-url origin 2>/dev/null)
        BRANCH=$(git branch --show-current)
        echo -e "Active Repo : ${GREEN}${CURRENT_REPO:-No remote repository linked}${NC}"
        echo -e "Branch      : ${GREEN}${BRANCH}${NC}"
    else
        echo -e "Status      : ${RED}Git is not initialized in this folder${NC}"
    fi
    echo "-----------------------------------------"
}

while true; do
    header
    echo "CHOOSE AN OPTION:"
    echo "1. Link / Change Remote Repository"
    echo "2. Push / Upload Changes"
    echo "3. Delete Files / Folders on GitHub"
    echo "4. Exit"
    echo "-----------------------------------------"
    read -p "Enter your choice (1-4): " menu

    case $menu in
        1)
            header
            echo "--- REPOSITORY SETTINGS / CONFIGURATION ---"
            read -p "Proceed with this process? (y/n): " confirm
            [[ "$confirm" != "y" ]] && continue

            if [ ! -d ".git" ]; then
                git init -q
                git branch -M main
            fi

            read -p "Enter new GitHub Repository URL: " repo_url
            if [ -z "$repo_url" ]; then
                echo "URL is empty, returning to menu..."
            else
                git remote remove origin 2>/dev/null
                git remote add origin "$repo_url"
                
                # Check if Git identity is configured
                if [ -z "$(git config user.name)" ]; then
                    read -p "Enter your GitHub Username: " gh_name
                    read -p "Enter your GitHub Email: " gh_email
                    git config user.name "$gh_name"
                    git config user.email "$gh_email"
                fi
                echo "Successfully linked!"
            fi
            sleep 1
            ;;

        2)
            header
            echo "--- PUSH / UPLOAD CHANGES ---"
            if [ ! -d ".git" ] || ! git remote | grep -q "origin"; then
                echo -e "${RED}ERROR: Folder is not linked to a Repo. Choose Option 1 first.${NC}"
                read -p "Press [Enter] to return..."
                continue
            fi

            echo "Syncing with GitHub..."
            git pull origin $(git branch --show-current) --no-rebase 2>/dev/null
            
            git add .
            echo ""
            echo "--- STAGED FILES READY TO PUSH ---"
            git status --short
            echo "-----------------------------"
            read -p "Commit message (leave empty for automatic): " msg
            [ -z "$msg" ] && msg="Update task: $(date +'%d-%m-%Y %H:%M')"
            
            read -p "Push changes now? [y/n]: " push_confirm
            if [[ "$push_confirm" == "n" ]]; then
                echo "Push operation cancelled."
            else
                git commit -m "$msg"
                if git push origin $(git branch --show-current); then
                    echo -e "${GREEN}SUCCESS: Changes pushed successfully.${NC}"
                else
                    echo -e "${RED}FAILED: An error occurred during push.${NC}"
                fi
            fi
            read -p "Press [Enter] to return..."
            ;;

        3)
            header
            echo "--- DELETE FILES / FOLDERS ON GITHUB ---"
            if [ ! -d ".git" ]; then
                echo -e "${RED}ERROR: Git is not initialized here.${NC}"
                read -p "Press [Enter] to return..."
                continue
            fi

            echo "Syncing latest data..."
            git pull origin $(git branch --show-current) --no-rebase -q 2>/dev/null
            
            items=(*)
            echo "Current directory contents:"
            echo "0. [CANCEL]"
            echo "A. [WIPE ALL REPOSITORY CONTENTS]"
            for i in "${!items[@]}"; do
                echo "$((i+1)). ${items[$i]}"
            done
            echo "-----------------------------------------"
            read -p "Select a number or type 'A' for all: " choice
            
            if [[ "$choice" == "0" ]]; then
                continue
            elif [[ "$choice" == "A" || "$choice" == "a" ]]; then
                header
                echo "!!! WARNING: DELETING ALL REPOSITORY CONTENTS !!!"
                echo "1. Delete from GitHub Only (Keep local files safe)"
                echo "2. Total Wipe (Delete from both local and GitHub)"
                echo "0. Cancel"
                read -p "Select deletion mode: " all_mode
                
                case $all_mode in
                    1)
                        git rm -r --cached .
                        git commit -m "Cleanup: Remove all files from GitHub"
                        git push origin $(git branch --show-current)
                        echo "GitHub repository cleared."
                        ;;
                    2)
                        read -p "Are you sure you want to delete EVERYTHING locally & remotely? (y/n): " final_confirm
                        if [[ "$final_confirm" == "y" ]]; then
                            git rm -rf .
                            git commit -m "Wipe: Delete entire repository content"
                            git push origin $(git branch --show-current)
                            echo "All files have been permanently deleted."
                        else
                            echo "Operation cancelled."
                        fi
                        ;;
                    *) echo "Cancelled.";;
                esac
            elif [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#items[@]}" ]; then
                target="${items[$((choice-1))]}"
                echo "Target: $target"
                echo "Mode: 1. GitHub Only | 2. Total Wipe | 0. Cancel"
                read -p "Your choice: " mode
                
                case $mode in
                    1)
                        git rm -r --cached "$target"
                        git commit -m "Remove $target from GitHub"
                        git push origin $(git branch --show-current)
                        echo "Successfully removed from GitHub."
                        ;;
                    2)
                        git rm -r "$target"
                        git commit -m "Permanently delete $target"
                        git push origin $(git branch --show-current)
                        echo "Successfully deleted permanently."
                        ;;
                    *) echo "Cancelled.";;
                esac
            else
                echo "Invalid option."
            fi
            read -p "Press [Enter] to return..."
            ;;

        4)
            header
            read -p "Are you sure you want to exit? (y/n): " exit_confirm
            if [[ "$exit_confirm" == "y" ]]; then
                echo "Exiting..."
                exit 0
            fi
            ;;

        *)
            echo "Option not available."
            sleep 1
            ;;
    esac
done
