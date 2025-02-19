self @ { lib, inputs, constants, ... }:
let
  inherit (builtins) elemAt;
  inherit (constants) allPlatforms defaultNixpkgsConfig;
  inherit (lib) attrsets lists mapAttrs strings;
  inherit (lists) foldl';
  inherit (strings) hasInfix;

  overlays = with self.overlays; [ all unstable ];
  machineList = builtins.attrValues self.machines;

  # pkgsFor gets the packages for the given (platform) system.
  pkgsFor = system:
    let
      isDarwin = hasInfix "darwin" system;
      pkgs = if isDarwin then inputs.nixpkgs-darwin else inputs.nixpkgs;
    in
      import pkgs { inherit system overlays; };

  # systemFactories contain OS-specific system factories.
  # key: os
  systemFactories = {
    nixos = inputs.nixpkgs.lib.nixosSystem;
    darwin = inputs.darwin.lib.darwinSystem;
  };

  # systemHomeManagerFactories contain OS-specific home-manager factories.
  # key: os
  systemHomeManagerFactories = {
    nixos = inputs.home-manager.nixosModules.home-manager;
    darwin = inputs.home-manager.darwinModules.home-manager;
  };

  # osSpecificSystemModules contain OS-specific module lists.
  # key: os
  osSpecificSystemModules = {
    nixos  = [];
    darwin = [
      # link applications to "/Applications" dir for macos
      inputs.mac-app-util.homeManagerModules.default
    ];
  };

  osSpecificHomeModules = {
    nixos  = [];
    darwin = [];
  };

  ## machineHomeModuleFactory builds the home module for a machine based on the
  ## defined user.
  #machineHomeModuleFactory = machine:
  #  let
  #    inherit (machine) hostname os system users;

  #    # TODO: multi-user setup here
  #    user = elemAt users 0;
  #    pkgs = pkgsFor system;

  #    userHost = "${user}@${hostname}";
  #    homeModule = ./home/${userHost};
  #    sharedHomeModules = osSpecificHomeModules.${os};
  #    homeManagerFactory = systemHomeManagerFactories.${os};
  #  in
  #      homeManagerFactory {
  #        home-manager.useGlobalPkgs = true;
  #        home-manager.useUserPackages = true;
  #        #home-manager.sharedModules = sharedHomeModules;
  #        home-manager.users.${user}.imports = [({config, lib, ...}: import homeModule {
  #          inherit config lib inputs pkgs users;
  #        })];
  #      };


  # nixpkgsModuleFactory
  nixpkgsModuleFactory = {
      system,
      config ? defaultNixpkgsConfig,
    }: {
      nixpkgs.config = config;
      nixpkgs.hostPlatform = {
        inherit system;
      };
    };

  # machineConfigurationFactory builds the given machine's system configuration.
  machineConfigurationFactory = machine:
    let
      inherit (machine) hostname os system users;

      user = elemAt users 0;
      userhost = "${user}@${hostname}";

      pkgs = pkgsFor system;
      homeManagerFactory = systemHomeManagerFactories.${os};

      nixpkgsModule = nixpkgsModuleFactory { inherit system; };
      machineModule = ./machines/${hostname};
      homeModule = ./home/${userhost};
    in
    systemFactories.${os} {
      specialArgs = {
        inherit lib hostname os self machine;
        nixpkgs = inputs.nixpkgs;
      };
      modules = [
        nixpkgsModule
        machineModule
        homeManagerFactory {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${user}.imports = [({config, lib, ...}: import homeModule {
            inherit user inputs config lib pkgs;
            nixpkgs = inputs.nixpkgs;
          })];
        }
      ];
    };

  # homeConfigurationFactory builds the given user's home configuration.
  homeConfigurationFactory = home:
    let
      inherit (home) system user userhost;

      homeUserModule = { home.username = "${user}"; };
      homeModule = ./home/${userhost};
      nixpkgsModule = { nixpkgs.config = defaultNixpkgsConfig; };

      pkgs = pkgsFor system;

      extraSpecialArgs = {
        inherit self home system user userhost;

        nixpkgs = inputs.nixpkgs;
      };
    in
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs extraSpecialArgs;
      modules = [
        nixpkgsModule
        homeUserModule
        homeModule
      ];
    };
in
inputs.nixpkgs.lib.extend (_: _: {
  inherit pkgsFor systemFactories homeConfigurationFactory machineConfigurationFactory;

  # forAllSystems builds an attribute set for each platform.
  forAllPlatforms = lib.genAttrs allPlatforms;

  # filterHosts filters hosts by the given predicate.
  filterHosts = predicate: builtins.filter predicate machineList;

  # e.g. darwinConfigurations = <{ "${HOSTNAME}" = { ... } }>
  buildMachinesForOS = os:
    let
      matchesOS = _: mach: mach.os == os;
      machines = lib.filterAttrs matchesOS self.machines;
    in
    mapAttrs (_: mach: mach.configuration) machines;

  # e.g. homeConfigurations = <{ "${USER}@${HOSTNAME}" = { ... } }>
  buildHomeConfigurations = {}:
    mapAttrs (_: home: home.configuration)
      (foldl' (acc: users: acc // users) {}
        (map (mach: mach.homes) (lib.attrValues self.machines)));
})
