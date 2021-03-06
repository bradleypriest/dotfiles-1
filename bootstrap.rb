#!/usr/bin/env ruby
require 'fileutils'

class Bootstrap
  class << self
    def osx?
      RUBY_PLATFORM.downcase.include?("darwin")
    end

    def file_exists? (file)
      File.exists?(file) || File.symlink?(file)
    end

    def dotfiles
      Dir.glob('home/*', File::FNM_DOTMATCH).tap { |a| a.shift(2) }
    end

    def symlink_dotfiles!
      dotfiles.each do | path |
        repofile = File.basename(path)
        hostfile = "#{Dir.home}/#{repofile}"

        # remove the current file if it exists
        FileUtils.rm_f hostfile if file_exists? hostfile

        # symlink the file checked in git to the home path
        FileUtils.ln_sf File.absolute_path(path), File.absolute_path(hostfile)
        print_link File.basename(path), File.absolute_path(hostfile)
      end
    end

    def install_fonts!
      if osx?
        Dir.glob 'fonts/*.otf' do | repofile |
          hostfile = "/Library/#{repofile}"
          unless file_exists? hostfile
            FileUtils.cp repofile, hostfile
          end
        end
      end
    end

    def symlink_vim_directory!
      vim_home = "#{Dir.home}/.vim"
      FileUtils.rm_f vim_home if file_exists? vim_home
      FileUtils.ln_sf File.absolute_path('.vim'), vim_home
      print_link '.vim', vim_home
    end

    def print_link(src, dest)
      printf " %15s -> %s\n", src, dest.gsub!('/Users/aackerman', '~')
    end

    def copy_iterm_profile!
      prefs = "com.googlecode.iterm2.plist"
      repofile = "terminal/#{prefs}"
      hostfile = "#{Dir.home}/Library/Preferences/#{prefs}"

      FileUtils.rm_f hostfile if file_exists? hostfile
      FileUtils.cp repofile, hostfile
      print_link prefs, hostfile
    end

    def symlink_sublime_settings!
      prefs = 'Preferences.sublime-settings'
      repofile = "sublime/#{prefs}"
      hostfile = "#{Dir.home}/Library/Application\ Support/Sublime\ Text\ 2/Packages/User/#{prefs}"
      FileUtils.rm_f hostfile if file_exists? hostfile
      FileUtils.ln_sf File.absolute_path(repofile), hostfile
    end

    def run!
      symlink_dotfiles!
      symlink_sublime_settings!
      symlink_vim_directory!
      copy_iterm_profile!
      install_fonts!
    end
  end
end

Bootstrap.run!
