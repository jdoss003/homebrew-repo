class QemuI386JosElf < Formula

  # Modified version of Homebrew's qemu formula

  desc "x86 and PowerPC Emulator"
  homepage "https://www.qemu.org/"
  url "https://download.qemu.org/qemu-2.11.1.tar.bz2"
  sha256 "d9df2213ceed32e91dab7bc9dd19c1af83f91ba72c7aeef7605dfaaf81732ccb"
  head "https://git.qemu.org/git/qemu.git"

  depends_on "gcc-i386-jos-elf" => :build
  depends_on "pkg-config" => :build
  depends_on "libtool" => :build
  depends_on "glib"
  depends_on "pixman"

  def install
    ENV["LIBTOOL"] = "glibtool"

    args = [
      "--prefix=#{prefix}",
      "--disable-kvm",
      "--disable-sdl",
      "--target-list=i386-softmmu x86_64-softmmu"
    ]

    system "./configure", *args
    system "make"
    system "make", "V=1", "install"
  end
end
