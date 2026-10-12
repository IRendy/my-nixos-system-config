{
  yazi = {
    mgr.sort_by = "natural";
    tasks.image_bound = [
      0
      0
    ];
  };
  keymap = {
    mgr.prepend_keymap = [
      # {
      #   desc = "Enter the child directory, or open the file";
      #   on = "l";
      #   run = "plugin smart-enter";
      # }
      {
        desc = "run lazygit";
        on = [
          "g"
          "i"
        ];
        run = "plugin lazygit";
      }
      {
        desc = "run mount";
        on = [
          "M"
          "m"
        ];
        run = "plugin mount";
      }
      {
        desc = "baidu pan panel";
        on = [
          "B"
          "b"
        ];
        run = "plugin baidu -- panel";
      }
      {
        desc = "upload to baidu pan";
        on = [
          "B"
          "u"
        ];
        run = "plugin baidu -- upload";
      }
      {
        desc = "download from baidu pan";
        on = [
          "B"
          "d"
        ];
        run = "plugin baidu -- download";
      }
      {
        desc = "baidu pan account";
        on = [
          "B"
          "a"
        ];
        run = "plugin baidu -- account";
      }
      # {
      #   desc = "Open SSHFS options";
      #   on = [ "M" "s" ];
      #   run = "plugin sshfs -- menu";
      # }
    ];
  };
  theme = { };
}
