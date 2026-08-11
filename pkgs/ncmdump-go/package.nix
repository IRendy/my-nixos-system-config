{
  lib,
  buildGoModule,
  fetchFromGitea,
}:

buildGoModule rec {
  pname = "ncmdump-go";
  version = "1.7.5";

  # 1. 源码获取：使用 fetchFromGitea 指向私有/自建 Gitea 实例
  src = fetchFromGitea {
    domain = "git.taurusxin.com";
    owner = "taurusxin";
    repo = "ncmdump-go";
    rev = "v${version}";
    hash = "sha256-WqQYnb5URntk96xRISWARrfBrX4k/uF+HgRSknnCqzY=";
    # 建议添加: leaveDotGit = true; (如果构建过程需要 git 信息)
  };

  # 2. 依赖哈希：对应 vendor 目录的哈希值
  vendorHash = "sha256-SgbD6KfTxnUFmfr6Ngko0I5bDTp1a411DV9uGs0YQ58=";

  # 3. 构建环境配置
  # 使用 preBuild 替代 preVendor 来设置构建时的环境变量
  preBuild = ''
    export GOPROXY="https://goproxy.cn,direct"
    export GOSUMDB="off"
  '';

  # 4. CGO 由 buildGoModule 自动管理，不需要显式设置

  meta = {
    description = "转换网易云音乐 ncm 到 mp3 / flac (Go 版)";
    homepage = "https://git.taurusxin.com/taurusxin/ncmdump-go";
    license = lib.licenses.mit;
    mainProgram = "ncmdump-go";
    maintainers = [ "IRendy" ];
    platforms = lib.platforms.unix;
  };
}
