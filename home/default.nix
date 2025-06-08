{ lib, ... }:
let
  inherit (builtins) readDir toPath toJSON trace;
  inherit (lib) attrNames filterAttrs lists strings;
  inherit (lists) foldl';
  inherit (strings) hasInfix;

  # each subdirectory is a "home"
  homeModules = attrNames
    (filterAttrs (name: type: type == "directory" && hasInfix "@" name)
        (readDir (toPath ./.)));

  userHosts = map
    (pair: {
      user = builtins.elemAt pair 0;
      host = builtins.elemAt pair 1;
    })
      (map (userHostStr: lib.strings.splitString "@" userHostStr) homeModules);

  hostUsersMap =
    let
      m = foldl' (acc: {user, host}: acc // {
        ${host} = (acc.${host} or []) ++ [user];
      }) {} userHosts;
    in
      trace "hostUsersMap => ${toJSON m}" m;
in
  hostUsersMap
