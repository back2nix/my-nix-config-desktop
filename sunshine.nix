{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.services.sunshine;
in {
  options.services.sunshine = {
    enable = mkEnableOption "sunshine";

    package = mkPackageOption pkgs "sunshine" {};

    user = mkOption {
      default = "root";
      type = with types; uniq string;
      description = ''Name of the user.'';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.sunshine
    ];

    security.wrappers.sunshine = {
      owner = "root";
      group = "root";
      capabilities = "cap_sys_admin+p";
      source = "${pkgs.sunshine}/bin/sunshine";
    };

    systemd.user.services = {
      sunshine = {
        Unit.Description = "Sunshine is a Game stream host for Moonlight.";
        Service.ExecStart = "${cfg.package}/bin/sunshine";
        # Service.CapabilityBoundingSet = ["CAP_SYS_ADMIN"];
        Install.WantedBy = ["graphical-session.target"];
      };
    };
  };
}
