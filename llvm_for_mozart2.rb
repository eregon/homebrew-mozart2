require 'formula'

# Mozart 2 needs a specific LLVM build since it needs to be linked to libc++
# and the headers to access the parser.

class LlvmForMozart2 < Formula
  homepage 'http://llvm.org/'
  url 'http://llvm.org/releases/3.4.2/llvm-3.4.2.src.tar.gz'
  sha1 'c5287384d0b95ecb0fd7f024be2cdfb60cd94bc9'

  resource 'clang' do
    url 'http://llvm.org/releases/3.4.2/cfe-3.4.2.src.tar.gz'
    sha1 'add5420b10c3c3a38c4dc2322f8b64ba0a5def97'
  end

  depends_on 'cmake' => :build

  keg_only :provided_by_osx

  def install
    (buildpath/"tools/clang").install resource("clang")

    cmake_args = std_cmake_args.dup

    # removes default -DCMAKE_BUILD_TYPE=None
    cmake_args.reject! { |arg| /^-DCMAKE_BUILD_TYPE=/ === arg }
    cmake_args << "-DCMAKE_BUILD_TYPE=Release"

    # Set flags to use libc++ and C++0x headers
    cmake_args << "-DCMAKE_CXX_FLAGS=-stdlib=libc++"

    cmake_args << "-DLLVM_TARGETS_TO_BUILD=X86" # try to speed up compilation

    mkdir 'build'
    cd 'build' do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    system "#{bin}/clang", "--version"
  end
end
