{
  lib,
  stdenv,
  fetchurl,
  unzip,
}:

stdenv.mkDerivation (finalAttrs: {
  name = "ncmdump";
  version = "1.5.1";
  src = fetchurl {
    url = "https://github.com/taurusxin/ncmdump/releases/download/${finalAttrs.version}/ncmdump-${finalAttrs.version}-${
      if stdenv.isLinux then
        "linux-amd64"
      else if stdenv.isDarwin then
        "macos-arm64"
      else
        throw "Unsupported platform: ${stdenv.hostPlatform.system}"
    }.zip";

    sha256 =
      if stdenv.hostPlatform.isLinux then
        "sha256-J9m0DDwxJjtG46AAwTkFbuDgnWu5JAeTy58t7VeeLg8="
      else if stdenv.hostPlatform.isDarwin then
        "sha256-WyiIuKU+eoF6ddTnnIcoQON/IAsIOU7DtDcEMDRzOcQ="
      else
        "";

  };

  nativeBuildInputs = [ unzip ];

  unpackPhase = ''
    unzip $src
  '';

  installPhase = ''
    mkdir -p $out/bin
    install -m 755 ncmdump $out/bin/
  '';

  meta = {
    description = "转换网易云音乐 ncm 到 mp3 / flac. Convert Netease Cloud Music ncm files to mp3/flac files.";
    homepage = "https://github.com/taurusxin/ncmdump";
    license = lib.licenses.mit;
    mainProgram = "ncmdump";
    maintainers = [ "IRendy" ];
    # maintainers = with lib.maintainers; [
    # ];
    platforms = with lib.platforms; [
      unix
      darwin
    ];
  };
})
