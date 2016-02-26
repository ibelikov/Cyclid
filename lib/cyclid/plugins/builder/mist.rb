# Top level module for the core Cyclid code.
module Cyclid
  # Module for the Cyclid API
  module API
    # Module for Cyclid Plugins
    module Plugins
      # Mist build host
      class MistHost < BuildHost
        # SSH is the only acceptable Transport
        def transports
          ['ssh']
        end
      end

      # Mist builder. Calls out to Mist to obtain a build host instance.
      class Mist < Builder
        def initialize(args = {})
          args.symbolize_keys!

          @os = args[:os]
        end

        # Create & return a build host
        def get(_args = {})
          # XXX Just return a random host from these two, for testing
          hosts = %w(r1 r2)
          MistHost.new(hostname: hosts.sample, username: 'sys-ops', password: nil, distro: 'ubuntu')
        end

        # Prepare the build host for the job, if required E.g. install any extra
        # packages that are listed in the 'environment' section of the job definition.
        def prepare(transport, buildhost, env = {})
          distro = buildhost[:distro]

          # XXX This is, clearly, horrible.
          #
          # Might want to abstract all of this stuff into "provioners" which
          # know how to Do Things on a specific operating system; that way
          # Builders do *not* need to know, and any Builder can use any
          # Provisioner during build host creation.
          if env.key? :repos
            if distro == 'ubuntu' || distro == 'debian'
              env[:repos].each do |repo|
                if distro == 'ubuntu'
                  transport.exec "sudo add-apt-repository #{repo}"
                elsif distro == 'debian'
                  # XXX
                end
              end

              transport.exec 'sudo apt-get update'

              env[:packages].each do |package|
                transport.exec "sudo apt-get install -y #{package}"
              end
            elsif distro == 'redhat' || distro == 'fedora'
              env[:packages].each do |package|
                transport.exec "sudo yum install #{package}"
              end
            end
          end
        end

        # Shut destroy the build host
        def release(transport, _buildhost)
          transport.exec 'echo sudo shutdown -h now'
        end

        # Register this plugin
        register_plugin 'mist'
      end
    end
  end
end
