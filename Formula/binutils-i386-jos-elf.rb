class BinutilsI386JosElf < Formula

  # Modified version of Homebrew's binutils formula

  desc "FSF/GNU ld, ar, readelf, etc. for native development"
  homepage "https://www.gnu.org/software/binutils/binutils.html"
  url "https://ftp.gnu.org/gnu/binutils/binutils-2.30.tar.gz"
  mirror "https://ftpmirror.gnu.org/binutils/binutils-2.30.tar.gz"
  sha256 "8c3850195d1c093d290a716e20ebcaa72eda32abf5e3d8611154b39cff79e9ea"

  # No --default-names option as it interferes with Homebrew builds.

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--target=i386-jos-elf",
                          "--disable-werror"
    system "make"
    system "make", "install"
  end

  test do
    assert_match "main", shell_output("#{bin}/gnm #{bin}/gnm")
  end
end
