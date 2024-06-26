REPO_URL := https://github.com/back2nix/my-astronvim-config
REPO_DIR := my-astronvim-config


nix:
	sudo nixos-rebuild switch

# home:
# 	home-manager switch
#
# flake:
# 	home-manager switch --flake .

sync:
	rsync -avP \
		--exclude='private' \
		--exclude='presharedKeyFile' \
		--exclude='hardware-configuration.nix' \
		/etc/nixos/* nixos
	cd $(REPO_DIR) && make sync

push:
	git add -u && git commit -m "make push" && git push || (git pull --rebase && git push)
	cd $(REPO_DIR) && git add -u && git commit -m "make push" && git push || (git pull --rebase && git push)

pull:
	@if [ -d "$(REPO_DIR)" ]; then \
		echo "Обновление репозитория..."; \
		cd $(REPO_DIR) && git pull; \
		echo "Репозиторий обновлен."; \
	else \
		git clone $(REPO_URL) $(REPO_DIR); \
	fi

setup: pull
	rsync -avP $(REPO_DIR)/plugins ~/.config/nvim/lua/

pathelf:
	sudo ./pathelf.sh /root/.local/share/nvim/lazy/telescope-fzf-native.nvim/build/libfzf.so
