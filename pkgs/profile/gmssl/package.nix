{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gmssl";
  version = "3.2.0";

  src = fetchFromGitHub {
    owner = "guanzhi";
    repo = "GmSSL";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Endiai566hjhUdz5B0nYdzggaFirHFncIlw7JD7smsY=";
  };

  buildInputs = [ cmake ];
  meta = {
    description = "支持国密SM2/SM3/SM4/SM9/SSL的密码工具箱";
    homepage = "https://github.com/guanzhi/GmSSL";
    platforms = lib.platforms.all;
    maintainers = [ "IRendy" ];
  };
})
