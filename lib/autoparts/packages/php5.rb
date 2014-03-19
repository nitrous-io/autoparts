# Copyright (c) 2013-2014 Application Craft Ltd. Codio
# This software is licensed under the [BSD 2-Clause license](https://raw.github.com/codio/boxparts/master/LICENSE).

module Autoparts
  module Packages
    class Php5 < Package
      name 'php5'
      version '5.5.8-4'
      description 'PHP 5.5: A popular general-purpose scripting language that is especially suited to web development. Prebuild extensions default + mbstring'
      source_url 'http://us1.php.net/get/php-5.5.8.tar.gz/from/this/mirror'
      source_sha1 '19af9180c664c4b8f6c46fc10fbad9f935e07b52'
      source_filetype 'tar.gz'
      category Category::WEB_DEVELOPMENT

      depends_on 'libmcrypt'

      def compile
        Dir.chdir('php-5.5.8') do
          args = [
            "--with-mcrypt=#{get_dependency("libmcrypt").prefix_path}",
            # path
            "--prefix=#{prefix_path}",
            "--bindir=#{bin_path}",
            "--sbindir=#{bin_path}",
            "--with-config-file-path=#{php5_ini_path}",
            "--with-config-file-scan-dir=#{php5_ini_path_additional}",
            "--sysconfdir=#{Path.etc + name}",
            "--libdir=#{lib_path}",
            "--includedir=#{include_path}",
            "--datarootdir=#{share_path}/#{name}",
            "--datadir=#{share_path}/#{name}",
            "--with-mysql-sock=/tmp/mysql.sock",
            "--mandir=#{man_path}",
            "--docdir=#{doc_path}",
            # features
            "--enable-opcache",
            "--enable-pdo",
            "--with-openssl",
            "--with-readline",
            "--enable-mbstring",
          ]
          execute './configure', *args
          execute 'make'
        end
      end

      def install
        Dir.chdir('php-5.5.8') do
          execute 'make install'
          execute 'cp', 'php.ini-development', "#{lib_path}/php.ini"
        end
      end

      def post_install
        # copy php.ini over
        unless php5_ini_path.exist?
          FileUtils.mkdir_p(File.dirname(php5_ini_path))
          execute 'cp', "#{lib_path}/php.ini", "#{php5_ini_path}"
        end
        unless php5_ini_path_additional.exist?
          FileUtils.mkdir_p(php5_ini_path_additional)
        end
      end

      def tips
        <<-EOS.unindent
PHP config file is located at:
  $ #{php5_ini_path}

        EOS
      end

      def php5_ini_path
        Path.etc + "php5" + "php.ini"
      end

      def php5_ini_path_additional
        Path.etc + "php5" + "conf.d"
      end
    end
  end
end
