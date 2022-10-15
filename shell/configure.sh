#!/usr/bin/env zsh

SHELL_INIT_PATH=$(dirname -- "$0")
mkdir -p $SHELL_INIT_PATH/source/

SHELL_ALIASES_PATH=$SHELL_INIT_PATH/source/.aliases.sh
SHELL_EXPORTS_PATH=$SHELL_INIT_PATH/source/.exports.sh
SHELL_FUNCTIONS_PATH=$SHELL_INIT_PATH/source/.functions.sh

echo "#!/usr/bin/env bash" >"$SHELL_ALIASES_PATH"
echo "#!/usr/bin/env bash" >"$SHELL_EXPORTS_PATH"
echo "#!/usr/bin/env bash" >"$SHELL_FUNCTIONS_PATH"

for f in "${DOTFILES}"/**/exports.sh; do
    {
        echo -e "\n###########################################################"
        echo -e "# $f"
        echo -e "###########################################################"
        grep -v "#\!/usr/bin" <"$f"
    } >>"$SHELL_EXPORTS_PATH"
done

for f in "${DOTFILES}"/**/functions.sh; do
    {
        echo -e "\n###########################################################"
        echo -e "# $f"
        echo -e "###########################################################"
        grep -v "#\!/usr/bin" <"$f"
    } >>"$SHELL_FUNCTIONS_PATH"
done

for f in "${DOTFILES}"/**/aliases.sh; do
    {
        echo -e "\n###########################################################"
        echo -e "# $f"
        echo -e "###########################################################"
        grep -v "#\!/usr/bin" <"$f"
    } >>"$SHELL_ALIASES_PATH"
done
