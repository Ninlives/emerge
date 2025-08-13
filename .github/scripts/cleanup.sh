#!/usr/bin/env bash

printf "Before cleanup:\n\n%s\n\n%s\n\n" "$(df -h)" "$(free -h)"

BloatedPackagesWithServices=(\
    '^dotnet.*' \
    'finalrd' \
    'irqbalance' \
    '^libmono.*' \
    'man-db' \
    'manpages' \
    '^mono.*' \
    'multipath-tools' \
    '^moby.*' \
    '^packagekit.*' \
    '^php.*' \
    'podman' \
    'sphinxsearch' \
    'snapd' \
    'ufw'
)

BloatedPackages=(\
    '^.*-icon-theme' \
    'ant' \
    'apache2.*' \
    '^aspnetcore.*' \
    'azure-cli' \
    '^bcache.*' \
    'bolt' \
    'brotli' \
    'build-essential' \
    'buildah' \
    'byobu' \
    '^cpp.*' \
    '^clang.*' \
    'crun' \
    'containerd.io' \
    '^emacsen.*' \
    '^firebird.*' \
    'firefox' \
    '^fonts.*' \
    '^freetds.*' \
    'friendly-recovery' \
    '^gconf.*' \
    '^gfortran.*' \
    '^gir.*' \
    '^glib.*' \
    '^google.*' \
    '^gsettings.*' \
    '^gtk.*' \
    'htop' \
    '^hunspell.*' \
    'icu-devtools' \
    '^imagemagick.*' \
    '^java.*' \
    '^kotlin.*' \
    '^landscape.*' \
    '^libclang.*' \
    '^lld.*' \
    '^llvm.*' \
    '^mecab.*' \
    '^mercurial.*' \
    '^microsoft.*' \
    'motd-news-config' \
    '^msbuild.*' \
    '^mssql.*' \
    '^mysql.*' \
    '^nginx.*' \
    'nuget' \
    'odbcinst' \
    'packages-microsoft-prod' \
    'parallel' \
    'pastebinit' \
    'pollinate' \
    '^postgresql.*' \
    '^r-.*' \
    '^ruby.*' \
    'screen' \
    '^secureboot.*' \
    '^session-.*' \
    'shellcheck' \
    'skopeo' \
    'slirp4netns' \
    'snmp' \
    'subversion' \
    'sosreport' \
    'swig' \
    '^temurin.*' \
    'tmux' \
    'tnftp' \
    '^tex-.*' \
    'texinfo' \
    '^ttf-.*' \
    '^unixodbc.*' \
    '^update-.*' \
    'vim' \
    '^x11.*' \
    'xauth' \
    '^xorg.*' \
    '^upx.*' \
    'xfsprogs' \
    'xorriso' \
    'xtrans-dev' \
    'zerofree' \
    'zsync'
)

sudo apt purge --yes "${BloatedPackages[@]}" "${BloatedPackagesWithServices[@]}"
sudo apt autopurge --yes

BloatedPaths=(\
    '/usr/share/dotnet' \
    '/usr/share/swift' \
    '/usr/share/miniconda' \
    '/usr/share/gradle' \
    '/usr/share/sbt' \
    '/usr/local/' \
    '/opt' \
    '/snap' \
    '/var/snap' \
    '/var/lib/docker' \
    '/var/lib/mysql' \
    '/var/lib/gems' \
    '/etc/skel' \
    '/usr/lib/jvm' \
    '/usr/lib/google-cloud-sdk' \
    '/usr/lib/llvm-'* \
    '/usr/lib/dotnet' \
    '/usr/lib/firefox' \
    "$HOME/.rustup" \
    "$HOME/.cargo" \
    "$HOME/.dotnet"
)

for path in "${BloatedPaths[@]}";do
  sudo rm -fr "$path" &
done

wait

printf "After cleanup:\n\n%s\n\n%s\n\n" "$(df -h)" "$(free -h)"
