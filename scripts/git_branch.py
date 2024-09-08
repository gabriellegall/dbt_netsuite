import subprocess
import re

def get_git_branch():
    try:
        # Run 'git rev-parse --abbrev-ref HEAD' to get the current branch name
        branch_name = subprocess.check_output(['git', 'rev-parse', '--abbrev-ref', 'HEAD']).strip().decode('utf-8')
        
        # Replace any character not in the allowed set with '_'
        normalized_branch_name = re.sub(r'[^a-zA-Z0-9]', '_', branch_name)

        return normalized_branch_name
    
    except subprocess.CalledProcessError:
        return "no_git_repo"

if __name__ == "__main__":
    branch = get_git_branch()
    print(branch)
