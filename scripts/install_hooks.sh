#!/bin/sh
# Runs the privacy check before every commit and push.
cd "$(git rev-parse --show-toplevel)" || exit 1
printf '#!/bin/sh\npython3 scripts/check_private.py --staged\n' > .git/hooks/pre-commit
printf '#!/bin/sh\npython3 scripts/check_private.py\n' > .git/hooks/pre-push
chmod +x .git/hooks/pre-commit .git/hooks/pre-push
echo "Privacy hooks installed."
