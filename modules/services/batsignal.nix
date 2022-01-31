{ config, lib, pkgs, ... }:

let

  cfg = config.services.batsignal;

in
{
  meta.maintainers = [ lib.maintainers.amesgen ];

  options.services.batsignal = {
    enable = lib.mkEnableOption "batsignal, a lightweight battery daemon";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.batsignal;
      defaultText = lib.literalExpression "pkgs.batsignal";
      description = "batsignal package to use.";
    };

    extraOptions = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "-w" "10" ];
      description = ''
        Extra command-line arguments to pass to <command>batsignal</command>.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      (lib.hm.assertions.assertPlatform "services.batsignal" pkgs
        lib.platforms.linux)
    ];

    systemd.user.services.batsignal = {
      Unit = {
        Description = "Lightweight battery daemon";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/batsignal"
          + lib.optionalString (cfg.extraOptions != [ ])
          (" " + lib.escapeShellArgs cfg.extraOptions);
        Restart = "always";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
