import pytest


def test_vagrant_user(host):
    assert host.user("vagrant").exists
    assert host.user("vagrant").group == "vagrant"


def test_python_package(host):
    assert host.package("python3").is_installed
    assert host.package("python3").version.startswith("3.10")


@pytest.mark.parametrize(
    "packagename", [("ansible"), ("ansible-lint"), ("Jinja2"), ("pytest"), ("pytest-testinfra"), ("yamllint")]
)
def test_ansible_package(host, packagename):
    assert host.pip.check().rc == 0
    ansi_packages = host.pip.get_packages()
    assert packagename in ansi_packages
