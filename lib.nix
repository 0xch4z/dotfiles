self@{
  lib,
  inputs,
  constants,
  ...
}:
let
  inherit (builtins)
    attrNames
    attrValues
    elemAt
    hasAttr
    ;
  inherit (constants) allPlatforms defaultNixpkgsConfig;
  inherit (lib)
    lists
    literalExpression
    types
    readFile
    mapAttrs
    strings
    mkOption
    ;
  inherit (lists) foldl';
  inherit (strings) hasInfix replaceStrings;

  machineList = attrValues self.machines;

  baseModules = [
    self.outputs.modules
    self.outputs.roles
  ];

  mkDesktopEnabledOption =
    config: description:
    mkOption {
      inherit description;
      type = types.bool;
      default = config.x.home.desktop.enable;
      defaultText = literalExpression "config.desktop.hyprland.enable";
    };

  mkEnabledOption =
    description:
    mkOption {
      inherit description;
      type = types.bool;
      default = true;
    };

  # determines whether the given system is darwin.
  isDarwin = system: hasInfix "darwin" system;

  # pkgsFor gets the packages for the given (platform) system.
  pkgsFor =
    system:
    let
      pkgs = if (isDarwin system) then inputs.nixpkgs-darwin else inputs.nixpkgs;
    in
    import pkgs {
      inherit system;
      config = {
        allowBroken = true;
        allowUnfree = true;
      };
      overlays = [ self.overlays ];
    };

  # systemFactories contain OS-specific system factories.
  # key: os
  systemFactories = {
    nixos = inputs.nixpkgs.lib.nixosSystem;
    darwin = inputs.darwin.lib.darwinSystem;
    linux =
      { modules, specialArgs }:
      inputs.system-manager.lib.makeSystemConfig {
        inherit modules specialArgs;
      };
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
    home = "/home";
    linux = "/home";
  };

  homeDirFor = { variant, user }: "${(systemHomePrefix.${variant})}/${user}";

  # variantSpecificSystemModules contain variant-specific system module lists.
  variantSpecificSystemModules = {
    nixos = [ ./modules/linux ];
    darwin = [ ./modules/darwin ];
    linux = [ ./modules/system-manager ];
  };

  osSpecificHomeModules = {
    linux = [ ];
    darwin = [
      # link applications to "/Applications" dir for macos
      inputs.mac-app-util.homeManagerModules.default
    ];
  };

  # nixpkgsModuleFactory
  nixpkgsModuleFactory =
    {
      system,
      config ? defaultNixpkgsConfig,
      hostPlatformAsString ? false,
      overlays ? [ self.overlays ],
    }:
    {
      nixpkgs.config = config;
      nixpkgs.hostPlatform =
        if hostPlatformAsString then
          system
        else
          {
            inherit system;
          };
      nixpkgs.overlays = overlays;
    };

  # machineConfigurationFactory builds the given machine's system configuration.
  machineConfigurationFactory =
    machine:
    let
      inherit (machine)
        hostname
        os
        system
        users
        variant
        wsl
        ;

      user = elemAt users 0;
      userhost = "${user}@${hostname}";
      homeDir = homeDirFor { inherit user variant; };

      nixpkgsModule = nixpkgsModuleFactory {
        inherit system;
        config =
          if variant == "linux" then
            builtins.removeAttrs defaultNixpkgsConfig [ "overlays" ]
          else
            defaultNixpkgsConfig;
        hostPlatformAsString = variant == "linux";
        overlays = lib.optionals (variant != "linux") [ self.overlays ];
      };
      machineModule = ./machines/${hostname};
      homeModule = ./home/${userhost};
      hasIntegratedHomeManager = hasAttr variant systemHomeManagerFactories;
      specialArgs = {
        inherit
          system
          inputs
          lib
          hostname
          os
          self
          machine
          homeDir
          user
          ;
        nixpkgs = inputs.nixpkgs;
      };
    in
    systemFactories.${variant} {
      inherit specialArgs;
      modules =
        variantSpecificSystemModules.${variant}
        ++ [
          nixpkgsModule
          machineModule
        ]
        ++ lib.optionals hasIntegratedHomeManager [
          systemHomeManagerFactories.${variant}
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit
                variant
                userhost
                homeDir
                self
                ;
            };
            home-manager.users.${user}.imports =
              baseModules
              ++ osSpecificHomeModules.${os}
              ++ [
                (
                  {
                    config,
                    lib,
                    pkgs,
                    ...
                  }:
                  import homeModule {
                    inherit
                      self
                      user
                      inputs
                      config
                      lib
                      pkgs
                      homeDir
                      ;
                    nixpkgs = inputs.nixpkgs;
                  }
                )
              ];
          }
        ]
        ++ lib.optionals (wsl && variant == "nixos") [
          inputs.wsl.nixosModules.wsl
        ];
    };

  # homeConfigurationFactory builds the given user's home configuration.
  homeConfigurationFactory =
    home:
    let
      inherit (home)
        variant
        system
        user
        userhost
        os
        ;

      homeDir = homeDirFor { inherit user variant; };
      homeUserModule = {
        home.username = "${user}";
      };
      homeModule = ./home/${userhost};
      nixpkgsModule = {
        nixpkgs.config = defaultNixpkgsConfig;
      };

      pkgs = pkgsFor system;

      extraSpecialArgs = {
        inherit
          self
          home
          system
          user
          userhost
          homeDir
          variant
          ;

        nixpkgs = inputs.nixpkgs;
      };
    in
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs extraSpecialArgs;
      modules =
        baseModules
        ++ osSpecificHomeModules.${os}
        ++ [
          nixpkgsModule
          homeUserModule
          homeModule
        ];
    };

  templateFile =
    { file, data }:
    let
      fileContent = readFile file;

      placeholders = map (name: "{{ " + name + " }}") (attrNames data);
      newValues = attrValues data;
    in
    replaceStrings placeholders newValues fileContent;
in
inputs.nixpkgs.lib.extend (
  _: _: {
    inherit
      isDarwin
      pkgsFor
      systemFactories
      homeConfigurationFactory
      machineConfigurationFactory
      templateFile
      mkEnabledOption
      mkDesktopEnabledOption
      ;

    # forAllSystems builds an attribute set for each platform.
    forAllPlatforms = lib.genAttrs allPlatforms;

    # filterHosts filters hosts by the given predicate.
    filterHosts = predicate: builtins.filter predicate machineList;

    buildMachinesForOSBySystem =
      variant:
      let
        matchesOS = _: mach: mach.variant == variant;
        machines = lib.filterAttrs matchesOS self.machines;
      in
      foldl' (
        acc: mach:
        acc
        // {
          ${mach.system} = (acc.${mach.system} or { }) // {
            ${mach.hostname} = mach.configuration;
          };
        }
      ) { } (attrValues machines);

    # e.g. darwinConfigurations = <{ "${HOSTNAME}" = { ... } }>
    buildMachinesForOS =
      variant:
      let
        matchesOS = _: mach: mach.variant == variant;
        machines = lib.filterAttrs matchesOS self.machines;
      in
      mapAttrs (_: mach: mach.configuration) machines;

    # e.g. homeConfigurations = <{ "${USER}@${HOSTNAME}" = { ... } }>
    buildHomeConfigurations =
      { }:
      mapAttrs (_: home: home.configuration) (
        foldl' (acc: users: acc // users) { } (map (mach: mach.homes) (lib.attrValues self.machines))
      );

    # produces flakes for every machine and standalone home keyed by system for
    # eval in CI.
    buildChecks =
      let
        machineChecks = map (mach: {
          inherit (mach) system;
          name = "${mach.variant}-${mach.hostname}";
          drv =
            if mach.variant == "linux" then
              mach.configuration
            else
              mach.configuration.config.system.build.toplevel;
        }) machineList;
      in
      foldl' (
        acc: check:
        acc
        // {
          ${check.system} = (acc.${check.system} or { }) // {
            ${check.name} = check.drv;
          };
        }
      ) { } machineChecks;
  }
)
