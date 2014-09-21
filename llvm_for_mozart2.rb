require 'formula'

# Mozart 2 needs a specific LLVM build since it needs to be linked to libc++
# and the headers to access the parser.

class LlvmForMozart2 < Formula
  homepage 'http://llvm.org/'
  url 'http://llvm.org/releases/3.5.0/llvm-3.5.0.src.tar.xz'
  sha1 '58d817ac2ff573386941e7735d30702fe71267d5'

  resource 'clang' do
    url 'http://llvm.org/releases/3.5.0/cfe-3.5.0.src.tar.xz'
    sha1 '834cee2ed8dc6638a486d8d886b6dce3db675ffa'
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
    cpp_headers_dir = if MacOS.version >= :mavericks
      "/Library/Developer/CommandLineTools/usr/lib/c++/v1"
    elsif MacOS.version >= :lion
      "/usr/lib/c++/v1"
    else
      raise "No known C++0x headers in this OS X version: #{MacOS.version}"
    end
    cmake_args << "-DCMAKE_CXX_FLAGS=-stdlib=libc++ -I#{cpp_headers_dir}"

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
