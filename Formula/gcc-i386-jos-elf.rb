class GccI386JosElf < Formula

  # Modified version of Homebrew's gcc formula

  desc "GNU compiler collection"
  homepage "https://gcc.gnu.org/"
  revision 1
  head "svn://gcc.gnu.org/svn/gcc/trunk"

  stable do
    url "https://ftp.gnu.org/gnu/gcc/gcc-7.3.0/gcc-7.3.0.tar.xz"
    mirror "https://ftpmirror.gnu.org/gcc/gcc-7.3.0/gcc-7.3.0.tar.xz"
    sha256 "832ca6ae04636adbb430e865a1451adf6979ab44ca1c8374f61fba65645ce15c"
  end

  depends_on "gmp"
  depends_on "libmpc"
  depends_on "mpfr"
  depends_on "binutils-i386-jos-elf"

  def install
    args = [
      "--prefix=#{prefix}",
      "--target=i386-jos-elf",
      "--disable-werror",
      "--disable-libssp",
      "--disable-libmudflap",
      "--disable-multilib",
      "--with-newlib",
      "--without-headers",
      "--with-gmp=#{Formula["gmp"].opt_prefix}",
      "--with-mpfr=#{Formula["mpfr"].opt_prefix}",
      "--with-mpc=#{Formula["libmpc"].opt_prefix}",
      "--enable-languages=c",
    ]

    mkdir "build" do

      system "../configure", *args

      system "make", "all-gcc"
      system "make", "install-gcc"
      system "make", "all-target-libgcc", *make_args
      system "make", "install-target-libgcc"

    end
  end
end
