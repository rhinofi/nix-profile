{
  description = "flakey-profile with system level deps needed by all devs at rhino.fi";

  inputs = {
    flakey-profile.url = "github:lf-/flakey-profile";
    nixpkgs.url = "github:nixos/nixpkgs?rev=b9014df496d5b68bf7c0145d0e9b0f529ce4f2a8";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, flakey-profile, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        nix = pkgs.nixVersions.nix_2_23;
      in
      {
        # Any extra arguments to mkProfile are forwarded directly to pkgs.buildEnv.
        #
        # Usage:
        # Switch to this flake:
        #   nix run .#profile.switch
        # Revert a profile change (note: does not revert pins):
        #   nix run .#profile.rollback
        # Build, without switching:
        #   nix build .#profile
        # Pin nixpkgs in the flake registry and in NIX_PATH, so that
        # `nix run nixpkgs#hello` and `nix-shell -p hello --run hello` will
        # resolve to the same hello as below [should probably be run as root, see README caveats]:
        #   sudo nix run .#profile.pin
        packages.profile = flakey-profile.lib.mkProfile {
          inherit pkgs;
          # Specifies things to pin in the flake registry and in NIX_PATH.
          pinned = { nixpkgs = toString nixpkgs; };
          paths = with pkgs; [
            nix
            direnv
            (nix-direnv.override { inherit nix; })
          ];
        };
      });
}

