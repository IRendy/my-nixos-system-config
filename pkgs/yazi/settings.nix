{
  yazi = {
    mgr.sort_by = "natural";
    tasks.image_bound = [0 0];
  };
  keymap = {
    mgr.prepend_keymap = [
      {
        desc = "Enter the child directory, or open the file";
        on = "l";
        run = "plugin smart-enter";
      }
      {
        desc = "run lazygit";
        on = [ "g" "i" ];
        run = "plugin lazygit";
      }
      {
        desc = "run mount";
        on = [ "M" "m" ];
        run = "plugin mount";
      }
      # {
      #   desc = "Open SSHFS options";
      #   on = [ "M" "s" ];
      #   run = "plugin sshfs -- menu";
      # }
    ];
  };
  theme = {};
  vfs = {
    my-server1 = {
      host = "server1";
      port = 22;
      user = "sftpuser";
    };
  };
}
