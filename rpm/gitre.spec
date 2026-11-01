
Name:           gitre
Version:        1.2
Release:        1%{?dist}
Summary:        CLI tool for monitoring local Git repositories

License:        GPL-3.0-only
URL:            https://github.com/naplon74/gitRE
Source0:        https://github.com/naplon74/gitRE/archive/refs/heads/copr.tar.gz

BuildArch:      noarch

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
gitRE is a command-line application that scans local Git repositories
and displays their status, including branch information, uncommitted
changes, and commits ahead or behind their remote branches.

%prep
%autosetup -n gitRE-copr

%build
# No compilation required.

%check
bash -n src/git_re.sh
python3 -m py_compile src/output.py

%install
install -Dpm 0755 src/git_re.sh \
    %{buildroot}%{_libexecdir}/gitre/git_re.sh

install -Dpm 0644 src/output.py \
    %{buildroot}%{_libexecdir}/gitre/output.py

mkdir -p %{buildroot}%{_bindir}

cat > %{buildroot}%{_bindir}/gitRE <<'EOF'
#!/bin/sh
exec %{_libexecdir}/gitre/git_re.sh "$@"
EOF

chmod 0755 %{buildroot}%{_bindir}/gitRE

%files
%{_bindir}/gitRE
%{_libexecdir}/gitre/git_re.sh
%{_libexecdir}/gitre/output.py

%changelog
* Sun Nov 01 2026 Naplon <naplon@example.com> - 1.2-1
- Initial RPM release
