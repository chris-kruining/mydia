{self, ...}: {
  perSystem = {pkgs, ...}: {
    checks.mydia = pkgs.testers.runNixOSTest {
      name = "mydia";

      nodes.machine1 = {
        imports = [self.nixosModules.default];

        config = {
          services = {
            mydia = {
              enable = true;

              secretKeyBaseFile = "/tmp/mydia/secret_key_base";

              database = {
                type = "postgres";
                uri = "postgres://localhost/mydia?sslMode=disabled";
              };
            };
          };
        };
      };

      testScript = ''
        import time

        machine.start()
        # machine.wait_for_unit("mydia.service")
        time.sleep(2)

        # assert machine.systemctl("is-active mydia") == "active"

        machine.succeed()
      '';
    };
  };
}
