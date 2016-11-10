require 'spec_helper'

describe 'samanage' do
  # by default the hiera integration uses hiera data from the shared_contexts.rb file
  # but basically to mock hiera you first need to add a key/value pair
  # to the specific context in the spec/shared_contexts.rb file
  # Note: you can only use a single hiera context per describe/context block
  # rspec-puppet does not allow you to swap out hiera data on a per test block
  # include_context :hiera
  let(:node) { 'samanage.example.com' }

  # below is the facts hash that gives you the ability to mock
  # facts on a per describe/context block.  If you use a fact in your
  # manifest you should mock the facts below.
  let(:facts) do
    {}
  end

  # below is a list of the resource parameters that you can override.
  # By default all non-required parameters are commented out,
  # while all required parameters will require you to add a value
  let(:params) do
    {
      #:conf_file => "$::samanage::params::conf_file",
      #:module_file => "$::samanage::params::module_file",
      #:basevardir => "$::samanage::params::basevardir",
      #:ssl => true,
      #:debug => false,
      #:server => "https://inventory.samanage.com/ocsinventory",
      #:ca_path => "$::samanage::params::ca_path",
      #:logfile => "$::samanage::params::logfile",
      #:packages => "$::samanage::params::packages",
      #:enable_cron => true,
      #:use_fqdn => true,
      #:fqdn_file => "$::samanage::params::fqdn_file",
      #:ocs_tag => :undef,

    }
  end
  # add these two lines in a single test block to enable puppet and hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)
  # This will need to get moved
  # it { pp catalogue.resources }
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      case facts[:kernel]
      when 'FreeBSD'
        let(:conf_dir) { '/usr/local/etc/ocsinventory' }
        let(:basevardir) { '/var/ocsinventory-agent' }
        let(:ca_path) { '/usr/local/share/certs/ca-root-nss.crt' }
        let(:logfile) { '/var/log/ocsinventory.log' }
        let(:fqdn_file) { '/usr/local/lib/perl5/site_perl/Ocsinventory/Agent/Backend/OS/Generic/Hostname.pm' }
      else
        let(:conf_dir) { '/etc/ocsinventory' }
        let(:basevardir) { '/var/lib/ocsinventory-agent' }
        let(:ca_path) { '/etc/ssl/certs/' }
        let(:logfile) { '/var/log/ocsinventory-client/ocsinventory.log' }
        let(:fqdn_file) { '/usr/share/perl5/Ocsinventory/Agent/Backend/OS/Generic/Hostname.pm' }
      end
      let(:conf_file) { "#{conf_dir}/ocsinventory-agent.cfg" }
      let(:module_file) { "#{conf_dir}/modules.conf" }
      describe 'check default config' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('samanage') }
        it { is_expected.to contain_class('samanage::params') }
        it { is_expected.to contain_file(basevardir).with_ensure('directory') }
        it { is_expected.to contain_file(conf_dir).with_ensure('directory') }
        it { is_expected.to contain_file(module_file).with_ensure('present') }
        case facts[:kernel]
        when 'FreeBSD'
          it { is_expected.to contain_package('p5-XML-Simple') }
          it { is_expected.to contain_package('p5-libwww') }
          it { is_expected.to contain_package('p5-Net-IP') }
          it { is_expected.to contain_package('p5-Proc-Daemon') }
          it { is_expected.to contain_package('net-mgmt/ocsinventory-agent') }
        else
          it { is_expected.to contain_package('libxml-simple-perl') }
          it { is_expected.to contain_package('libnet-snmp-perl') }
          it { is_expected.to contain_package('libnet-ip-perl') }
          it { is_expected.to contain_package('ocsinventory-agent') }
        end
        it do
          is_expected.to contain_file(conf_file).with_ensure(
            'present'
          ).with_content(
            %r{basevardir=#{basevardir}}
          ).with_content(
            %r{ssl=1}
          ).with_content(
            %r{server=https://inventory.samanage.com/ocsinventory}
          ).with_content(
            %r{ca=#{ca_path}}
          ).with_content(
            %r{logfile=#{logfile}}
          )
        end
        it do
          is_expected.to contain_cron('ocsinventory-agent run').with_command(
            'ocsinventory-agent --lazy &> /dev/null'
          )
        end
        it do
          is_expected.to contain_file_line(
            'patch ociinventory to use the fqdn for NAME'
          ).with(
            'path' => fqdn_file,
            'line' => "  \#$hostname =~ s/\\..*//; # keep just the hostname",
            'match' => '.*keep just the hostname.*'
          )
        end
      end
      describe 'Change Defaults' do
        context 'conf_file' do
          before { params.merge!(conf_file: '/foo') }
          it { is_expected.to compile }
          it { is_expected.to contain_file('/foo').with_ensure('present') }
        end
        context 'module_file' do
          before { params.merge!(module_file: '/foo') }
          it { is_expected.to compile }
          it { is_expected.to contain_file('/foo').with_ensure('present') }
        end
        context 'basevardir' do
          before { params.merge!(basevardir: '/foo') }
          it { is_expected.to compile }
          it { is_expected.to contain_file('/foo').with_ensure('directory') }
          it do
            is_expected.to contain_file(conf_file).with_ensure(
              'present'
            ).with_content(
              %r{basevardir=/foo}
            )
          end
        end
        context 'ssl' do
          before { params.merge!(ssl: false) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(conf_file).with_ensure(
              'present'
            ).without_content(
              %r{ssl=1}
            )
          end
        end
        context 'debug' do
          before { params.merge!(debug: true) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(conf_file).with_ensure(
              'present'
            ).with_content(
              %r{debug=1}
            )
          end
        end
        context 'server' do
          before { params.merge!(server: 'http://foo.com/') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(conf_file).with_ensure(
              'present'
            ).with_content(
              %r{server=http://foo.com/}
            )
          end
        end
        context 'ca_path' do
          before { params.merge!(ca_path: '/foo') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(conf_file).with_ensure(
              'present'
            ).with_content(
              %r{ca=/foo}
            )
          end
        end
        context 'logfile' do
          before { params.merge!(logfile: '/foo') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(conf_file).with_ensure(
              'present'
            ).with_content(
              %r{logfile=/foo}
            )
          end
        end
        context 'packages' do
          before { params.merge!(packages: ['foo']) }
          it { is_expected.to compile }
          it { is_expected.to contain_package('foo') }
        end
        context 'enable_cron' do
          before { params.merge!(enable_cron: false) }
          it { is_expected.to compile }
          it { is_expected.not_to contain_cron('ocsinventory-agent run') }
        end
        context 'use_fqdn' do
          before { params.merge!(use_fqdn: false) }
          it { is_expected.to compile }
          it do
            is_expected.not_to contain_file_line(
              'patch ociinventory to use the fqdn for NAME'
            )
          end
        end
        context 'fqdn_file' do
          before { params.merge!(fqdn_file: '/foo') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file_line(
              'patch ociinventory to use the fqdn for NAME'
            ).with_path('/foo')
          end
        end
        context 'ocs_tag' do
          before { params.merge!(ocs_tag: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(conf_file).with_content(
              %r{tag=foobar}
            )
          end
        end
      end
      describe 'check bad type' do
        context 'conf_file' do
          before { params.merge!(conf_file: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'module_file' do
          before { params.merge!(module_file: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'basevardir' do
          before { params.merge!(basevardir: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'ssl' do
          before { params.merge!(ssl: 'foobar') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'debug' do
          before { params.merge!(debug: 'foobar') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'server' do
          before { params.merge!(server: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'ca_path' do
          before { params.merge!(ca_path: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'logfile' do
          before { params.merge!(logfile: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'packages' do
          before { params.merge!(packages: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'enable_cron' do
          before { params.merge!(enable_cron: 'foobar') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'use_fqdn' do
          before { params.merge!(use_fqdn: 'foobar') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'fqdn_file' do
          before { params.merge!(fqdn_file: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'ocs_tag' do
          before { params.merge!(ocs_tag: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
      end
    end
  end
end
