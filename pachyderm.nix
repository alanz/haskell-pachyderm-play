
{ lib, fetchFromGitHub, buildGoPackage }:

buildGoPackage rec {
  name = "pachyderm-${version}";
  # version = "1.6.9";
  # version = "1.7.0";
  version = "ee9870ef03fe1efbe6aba9b1107b28cd9615cf83";
  # rev = "v${version}";
  rev = "${version}";

  goPackagePath = "github.com/pachyderm/pachyderm";
  subPackages = [ "src/server/cmd/pachctl" ];

  # % nix-prefetch-git --no-deepClone --quiet https://github.com/pachyderm/pachyderm.git 1f85028125a82852328179741e51a068a5cfb08d
  # {
  # "url": "https://github.com/pachyderm/pachyderm.git",
  # "rev": "1f85028125a82852328179741e51a068a5cfb08d",
  # "date": "2018-04-10T15:55:46-07:00",
  # "sha256": "1v7qx306ln3f7mb3lfwsn25lsk2m7hcymc80hf4x1qc2ja4f52cb",
  # "fetchSubmodules": true
  # }


  # % nix-prefetch-git --no-deepClone --quiet https://github.com/pachyderm/pachyderm.git 53ec324422732aa2ca79015ffaac97c043f16257
  # {
  #   "url": "https://github.com/pachyderm/pachyderm.git",
  #   "rev": "53ec324422732aa2ca79015ffaac97c043f16257",
  #   "date": "2018-04-13T17:51:56-07:00",
  #   "sha256": "0f4zx6nzl77facn63iz0x9lh9gasikx6dz92r76kd1gawzjadxnz",
  #   "fetchSubmodules": true
  # }

  src = fetchFromGitHub {
    inherit rev;
    owner = "pachyderm";
    repo = "pachyderm";
    # sha256 = "1v7qx306ln3f7mb3lfwsn25lsk2m7hcymc80hf4x1qc2ja4f52cb";
    # sha256 = "0f4zx6nzl77facn63iz0x9lh9gasikx6dz92r76kd1gawzjadxnz";
    # sha256 = "1wjwn5i4mpwgwhh76wf8r7y5h0dh352kvkbcras6fvxmr0fqpk65";
    sha256 = "1f4ckq6fi49vmghil9x1lqcvsb2pvaxmwg4n86c9mnwaswdzrrji";
  };

  meta = with lib; {
    description = "Containerized Data Analytics";
    homepage = https://github.com/pachyderm/pachyderm;
    license = licenses.asl20;
    maintainers = with maintainers; [offline];
  };
}
