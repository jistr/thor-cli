require 'aeolus/cli/config'

describe Aeolus::Cli::Config do
  let(:config_class) { Aeolus::Cli::Config }

  context ".load_config" do
    subject { config_class.load_config(:password => 'pass') }

    before do
      ENV['AEOLUS_CLI_CONF'] = '/myconfig'
      File.stub(:read).with(Aeolus::Cli::Config::DEFAULT_CONFIG_FILE)
          .and_return('
                      :conductor:
                        :url: http://myurl/api
                      '.gsub(/^ {22}/, '')) # strip excessive indentation
      File.stub(:read).with('/myconfig')
          .and_return('
                      :conductor:
                        :username: user
                      '.gsub(/^ {22}/, '')) # strip excessive indentation
    end

    after do
      ENV['AEOLUS_CLI_CONF'] = nil
    end

    it do
      subject.to_hash.should == {
        :conductor => {
          :url => 'http://myurl/api',
          :username => 'user',
          :password => 'pass',
        }
      }
    end
  end

  context ".config_file_to_load" do
    subject { config_class.send(:config_file_to_load) }

    context "set by ENV" do
      before { ENV['AEOLUS_CLI_CONF'] = '/custom-aeolus-cli' }
      after  { ENV['AEOLUS_CLI_CONF'] = nil }

      it { should == '/custom-aeolus-cli' }
    end

    context "global and user's config file exist" do
      before do
        File.stub(:exists?).with("#{ENV['HOME']}/.aeolus-cli").and_return(true)
        File.stub(:exists?).with("/etc/aeolus-cli").and_return(true)
      end

      it { should == "#{ENV['HOME']}/.aeolus-cli" }
    end

    context "global config file exists" do
      before do
        File.stub(:exists?).with("#{ENV['HOME']}/.aeolus-cli").and_return(false)
        File.stub(:exists?).with("/etc/aeolus-cli").and_return(true)
      end

      it { should == "/etc/aeolus-cli" }
    end

    context "no config file exists" do
      before do
        File.stub(:exists?).with("#{ENV['HOME']}/.aeolus-cli").and_return(false)
        File.stub(:exists?).with("/etc/aeolus-cli").and_return(false)
      end

      it { should == nil }
    end
  end

  context ".config_file_hash" do
    subject { config_class.send(:config_file_hash, '/myconfig') }
    before do
      File.stub(:file?).with('/myconfig').and_return(true)
      File.stub(:read).with('/myconfig')
          .and_return('
                      :conductor:
                        :username: user
                      '.gsub(/^ {22}/, '')) # strip excessive indentation
    end

    it do
      should == {
        :conductor => {
          :username => 'user'
        }
      }
    end
  end
end
