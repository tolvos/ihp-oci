# Shortcut for updating Nix in the container
alias update-nix="rm -rf ~/.cache/* && nix build"

# If flake has been updated, make sure our symlinks reflect the latest nix profile.
# Otherwise, just source the existing profile as the nix installer would.
if [ ! -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
  for profile in /nix/store/*-profile; do
  	if [ -f "$profile/etc/profile.d/nix.sh" ] && [ -f "$profile/bin/nix" ]; then
  	  ln -sfn "$profile" "$HOME/.local/state/nix/profiles/profile"
  	  . "$profile/etc/profile.d/nix.sh"
  	  break
  	fi
  done
else
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi
eval "$(direnv hook bash)"
