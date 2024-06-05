{config, ...}: {
  # OpenGL
  hardware.opengl = {
    # export LD_LIBRARY_PATH=/run/opengl-driver/lib/:$LD_LIBRARY_PATH
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    modesetting.enable = true;
    # powerManagement = false;
    # powerManagement.finegrained = false;
    powerManagement.enable = false;
    powerManagement.finegrained = false;

    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    # package = config.boot.kernelPackages.nvidiaPackages.production;
  };

  # nixpkgs.config.cudaSupport = true;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  # environment.systemPackages = with pkgs; [
  # ];
}
