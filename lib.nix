self @ { lib, inputs, constants, ... }:
let
  inherit (builtins) attrNames attrValues elemAt;
  inherit (constants) allPlatforms defaultNixpkgsConfig;
  inherit (lib) lists readFile mapAttrs strings;
  inherit (lists) foldl';
  inherit (strings) hasInfix replaceStrings;

  overlays = with self.overlays; [ all unstable ];
  machineList = attrValues self.machines;

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

  systemHomePrefix = {
    nixos = "/home";
    darwin = "/Users";
  };

  homeDirFor = { variant, user }:
    "${(systemHomePrefix.${variant})}/${user}";

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
      inherit (machine) hostname os system users variant wsl;

      user = elemAt users 0;
      userhost = "${user}@${hostname}";
      homeDir = homeDirFor { inherit user variant; };

      pkgs = pkgsFor system;
      homeManagerFactory = systemHomeManagerFactories.${variant};

      nixpkgsModule = nixpkgsModuleFactory { inherit system; };
      machineModule = ./machines/${hostname};
      homeModule = ./home/${userhost};
    in
    systemFactories.${variant} {
      specialArgs = {
        inherit inputs lib hostname os self machine homeDir;
        nixpkgs = inputs.nixpkgs;
      };
      modules = [
        nixpkgsModule
        machineModule
        homeManagerFactory {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit homeDir self; };
          home-manager.users.${user}.imports = [({config, lib, ...}: import homeModule {
            inherit user inputs config lib pkgs homeDir;
            nixpkgs = inputs.nixpkgs;
          })];
        }
      ] ++ lib.optionals wsl [
        inputs.wsl.nixosModules.wsl
      ];
    };

  # homeConfigurationFactory builds the given user's home configuration.
  homeConfigurationFactory = home:
    let
      inherit (home) variant system user userhost;

      homeDir = homeDirFor { inherit user variant; };
      homeUserModule = { home.username = "${user}"; };
      homeModule = ./home/${userhost};
      nixpkgsModule = { nixpkgs.config = defaultNixpkgsConfig; };

      pkgs = pkgsFor system;

      extraSpecialArgs = {
        inherit self home system user userhost homeDir;

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

  templateFile = { file, data }:
    let
      fileContent = readFile file;

      placeholders =
        map (name: "{{ " + name + " }}") (attrNames data);
      newValues =
        attrValues data;
    in
      replaceStrings placeholders newValues fileContent;
in
inputs.nixpkgs.lib.extend (_: _: {
  inherit pkgsFor systemFactories homeConfigurationFactory machineConfigurationFactory templateFile;

  # forAllSystems builds an attribute set for each platform.
  forAllPlatforms = lib.genAttrs allPlatforms;

  # filterHosts filters hosts by the given predicate.
  filterHosts = predicate: builtins.filter predicate machineList;

  # e.g. darwinConfigurations = <{ "${HOSTNAME}" = { ... } }>
  buildMachinesForOS = variant:
    let
      matchesOS = _: mach: mach.variant == variant;
      machines = lib.filterAttrs matchesOS self.machines;
    in
    mapAttrs (_: mach: mach.configuration) machines;

  # e.g. homeConfigurations = <{ "${USER}@${HOSTNAME}" = { ... } }>
  buildHomeConfigurations = {}:
    mapAttrs (_: home: home.configuration)
      (foldl' (acc: users: acc // users) {}
        (map (mach: mach.homes) (lib.attrValues self.machines)));
})
