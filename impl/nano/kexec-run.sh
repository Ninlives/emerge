#!@busybox@ sh

set -ex

INITRD_TMP=$('@busybox@' mktemp -d)

cd "$INITRD_TMP"
cleanup() {
  '@busybox@' rm -rf "$INITRD_TMP"
}
trap cleanup EXIT

# save the networking config for later use
'@ip@' --json addr > addrs.json

'@ip@' -4 --json route > routes-v4.json
'@ip@' -6 --json route > routes-v6.json

'@busybox@' find . | '@busybox@' cpio -o -H newc | '@busybox@' gzip -9 | '@busybox@' cat '@initrd@' - > "$INITRD_TMP/initrd"

if ! '@kexec@' --load '@bzImage@' \
  --kexec-syscall-auto \
  --initrd="$INITRD_TMP/initrd" --no-checks \
  --command-line "init=@init@ restore_routes.main_ip=@host@ @kernelParams@"; then
  '@busybox@' echo "kexec failed, dumping dmesg"
  '@busybox@' dmesg | tail -n 100
  exit 1
fi

# Disconnect our background kexec from the terminal
'@busybox@' echo "machine will boot into nixos in in 6s..."
if '@busybox@' test -e /dev/kmsg; then
  # this makes logging visible in `dmesg`, or the system consol or tools like journald
  exec > /dev/kmsg 2>&1
else
  exec > /dev/null 2>&1
fi
# We will kexec in background so we can cleanly finish the script before the hosts go down.
# This makes integration with tools like terraform easier.
'@busybox@' nohup '@busybox@' sh -c "'@busybox@' sleep 6 && '@kexec@' -e" &
