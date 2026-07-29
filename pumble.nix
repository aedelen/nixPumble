{ lib
, stdenv
, fetchurl
, dpkg
, autoPatchelfHook
, makeWrapper
, alsa-lib
, atk
, at-spi2-core
, cairo
, cups
, dbus
, expat
, fontconfig
, freetype
, gdk-pixbuf
, glib
, gtk3
, nspr
, nss
, pango
, libX11
, libXcomposite
, libXdamage
, libXext
, libXfixes
, libXrandr
, libXrender
, libXtst
, libxcb
, libxshmfence
, libdrm
, mesa
, systemd
, xdg-utils
}:

stdenv.mkDerivation rec {
  pname = "pumble-desktop";
  version = "1.4.6"; # Check pumble.com/apps for the latest version string

  src = fetchurl {
    url = "https://pumble.com/download/desktop/linux/Pumble-linux-${version}.deb";
    # Leave this placeholder string; we will let Nix tell us the real hash next
    hash = "sha256-wkt7LvgQzOH2KgQRQPQQZe2OVzYdKZ3fMjt1LUMt8uU=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    nspr
    nss
    pango
    libX11
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXrandr
    libXrender
    libXtst
    libxcb
    libxshmfence
    libdrm
    mesa
    systemd
  ];

  unpackPhase = "dpkg-deb -x $src .";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share
    cp -r usr/share/* $out/share/
    cp -r opt $out/opt

    # Make a symlink to the main binary so Nix adds it to your PATH
    ln -s $out/opt/Pumble/pumble-desktop $out/bin/pumble-desktop

    # Fix up the shortcut file to point to our newly linked path
    substituteInPlace $out/share/applications/pumble-desktop.desktop \
      --replace "/opt/Pumble/pumble-desktop" "$out/bin/pumble-desktop"

    runHook postInstall
  '';

  postFixup = ''
    # Tells the app how to launch default browsers when you click links
    wrapProgram $out/bin/pumble-desktop \
      --prefix PATH : ${lib.makeBinPath [ xdg-utils ]}
  '';

  meta = with lib; {
    description = "Pumble team collaboration and messaging app";
    homepage = "https://pumble.com";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
