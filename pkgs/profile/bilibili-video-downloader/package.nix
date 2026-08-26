{
  lib,
  stdenv,
  fetchFromGitHub,
  nodejs,
  pnpm_10,
  fetchPnpmDeps,
  pnpmConfigHook,
  cargo-tauri,
  rustPlatform,
  openssl,
  pkg-config,
  glib-networking,
  libayatana-appindicator,
  webkitgtk_4_1,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  version = "0.2.1";
  pname = "bilibili-video-downloader";

  src = fetchFromGitHub {
    owner = "lanyeeee";
    repo = "bilibili-video-downloader";
    rev = "v${finalAttrs.version}";
    hash = "sha256-VaZQs48K6Oh8mKpDvcbPAy8ud9nl8zytdv6c0OoSQYs=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_10;
    hash = "sha256-O2ZBk//OgkaG+HBAwuXQRkZbzYcr5705cOKwUooSDFg=";
    fetcherVersion = 3;
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    sourceRoot = "source/src-tauri";
    name = "${finalAttrs.pname}-${finalAttrs.version}";
    hash = "sha256-ICZtSWDWho3UVTMVb4CfAbOSopKXyQEJ/A15BGBLdr0=";
  };

  nativeBuildInputs = [
    cargo-tauri.hook
    nodejs
    pnpm_10
    pnpmConfigHook
    rustPlatform.cargoSetupHook
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    glib-networking
    libayatana-appindicator
    webkitgtk_4_1
  ];

  cargoRoot = "src-tauri";
  buildAndTestSubdir = "src-tauri";

  postInstall = ''
    desktop="$out/share/applications/bilibili-video-downloader.desktop"
    sed -i \
      -e 's/^Name=.*/Name=Bilibili Video Downloader/' \
      -e 's/^Comment=.*/Comment=Download videos from Bilibili/' \
      -e 's/^Categories=$/Categories=Network;AudioVideo;/' \
      "$desktop"
  '';
  meta = {
    description = "哔哩哔哩 bilibili B站 视频 下载器，图形界面 + nfo刮削 + 广告标记 + 字幕下载 + 弹幕下载，轻松将视频加入emby等媒体库";
    homepage = "https://github.com/lanyeeee/bilibili-video-downloader";
    license = lib.licenses.mit;
    mainProgram = "bilibili-video-downloader";
    platforms = lib.platforms.all;
    maintainers = [ "IRendy" ];
  };
})
