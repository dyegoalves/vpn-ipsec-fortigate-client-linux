#!/bin/bash
# Build RPM via container (funciona em Bazzite/Fedora Atomic sem rpmbuild local)
set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SPEC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/SPECS/vpn-ipsec-client.spec"

echo "Build RPM em container Fedora..."
podman run --rm \
  -v "$PROJECT_ROOT:/workspace:z" \
  -w /workspace \
  fedora:41 bash -c "
    dnf install -y -q rpm-build python3 2>&1 | tail -1
    mkdir -p /root/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
    cp /workspace/packaging/rpm/SPECS/vpn-ipsec-client.spec /root/rpmbuild/SPECS/
    rpmbuild -bb /root/rpmbuild/SPECS/vpn-ipsec-client.spec 2>&1 | tail -5
    find /root/rpmbuild/RPMS -name '*.rpm' -exec cp {} /workspace/packaging/ \;
  "

echo "RPM criado: $(ls -t "$PROJECT_ROOT"/packaging/*.rpm 2>/dev/null | head -1)"
