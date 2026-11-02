Name:           gitre
Version:        1.3
Release:        1%{?dist}
Summary:        CLI tool for monitoring local Git repositories

License:        GPL-3.0-or-later
URL:            https://github.com/naplon74/gitRE
Source0:        https://github.com/naplon74/gitRE/archive/refs/heads/copr.tar.gz

BuildArch:      noarch

BuildRequires:  python3

Requires:       bash
Requires:       git
Requires:       jq
Requires:       python3
Requires:       python3-rich
Requires:       coreutils
Requires:       findutils
Requires:       grep
Requires:       gawk

%description
gitRE is a cli that scans local Git repositories
and displays their status, uncommitted
changes, and commits ahead or behind their remote branches.

%prep
%autosetup -n gitRE-copr

%build
# No compilation required.

%check
bash -n src/git_re.sh
bash -n src/main.sh
python3 -m py_compile src/output.py

%install
install -Dpm 0755 src/git_re.sh \
    %{buildroot}%{_libexecdir}/gitre/git_re.sh

install -Dpm 0755 src/main.sh \
    %{buildroot}%{_libexecdir}/gitre/main.sh

install -Dpm 0755 src/output.py \
    %{buildroot}%{_libexecdir}/gitre/output.py

install -Dpm 0644 LICENSE \
    %{buildroot}%{_licensedir}/%{name}/LICENSE

mkdir -p %{buildroot}%{_bindir}

cat > %{buildroot}%{_bindir}/gitRE <<'EOF'
#!/bin/sh
exec %{_libexecdir}/gitre/git_re.sh "$@"
EOF

chmod 0755 %{buildroot}%{_bindir}/gitRE

%files
%{_bindir}/gitRE
%{_libexecdir}/gitre/main.sh
%{_libexecdir}/gitre/output.py
%license %{_licensedir}/%{name}/LICENSE
%doc README.md

%changelog
* Mon Nov 02 2026 Naplon <naplon@ik.me.com> - 1.3-1
- Added new cli

* Sun Nov 01 2026 Naplon <naplon@ik.me.com> - 1.2-1
- Initial RPM release
