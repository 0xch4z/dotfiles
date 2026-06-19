_: {
  den.aspects.aws.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        awscli2
        awsume
        awsls
        eksctl
        s5cmd
      ];
    };
}
