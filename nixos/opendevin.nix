{
  config,
  pkgs,
  opts,
  ...
}: {
  # Настройка сетевого экрана для интерфейса tailscale0
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [11434 18080 3000];

  # Включение поддержки Docker и NVIDIA
  # hardware.opengl.driSupport32Bit = true;
  virtualisation.docker.enableNvidia = true;

  virtualisation.oci-containers = {
    backend = "docker";

    containers = {
      ollama = {
        image = "ollama/ollama";
        ports = ["11434:11434"];
        volumes = [
          "/home/bg/.ollama:/root/.ollama"
        ];
        extraOptions = [
          "--network=host"
          "--gpus=all"
        ];
        # environment = {
        # OLLAMA_MODEL_PREF = "llama3";
        # OLLAMA_MODELS = "/home/bg/.ollama/models";
        # };
        autoStart = true;
      };

      opendevin = {
        image = "ghcr.io/opendevin/opendevin:main";
        autoStart = true;
        environment = {
          SANDBOX_USER_ID = "1000";
          SANDBOX_TYPE = "exec";
          PERSIST_SANDBOX = "true";
          LITELLM_DROP_PARAMS = "true";
          # LLM_API_KEY = "ollama";
          # LLM_BASE_URL = "http://host.docker.internal:11434";
          # LLM_BASE_URL = "https://api.mistral.ai/v1/fim/completions";
          WORKSPACE_MOUNT_PATH = "/home/bg/Documents/code/github.com/back2nix/nix/test/opendevin/workspace";
        };
        extraOptions = [
          "--tty"
          "--network=host"
          "--add-host=host.docker.internal:host-gateway"
        ];
        volumes = [
          "/home/bg/Documents/code/github.com/back2nix/nix/test/opendevin/workspace:/opt/workspace_base"
          "/var/run/docker.sock:/var/run/docker.sock"
        ];
        ports = [
          "3000:3000"
        ];
      };
    };
  };
}
