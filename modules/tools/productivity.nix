_: {
  den.aspects.productivity.homeManager =
    { pkgs, ... }:
    {
      home = {
        packages = with pkgs; [
          gum
          jira-cli-go
          mermaid-cli
        ];
        sessionVariables = {
          #JIRA_AUTH_TYPE = "bearer";
        };
      };
    };
}
