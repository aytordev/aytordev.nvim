{...}: {
  perSystem = {config, ...}: {
    checks.build = config.packages.default;
  };
}
