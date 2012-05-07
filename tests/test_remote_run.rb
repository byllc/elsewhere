require 'minitest/autorun'
require 'elsewhere'

class TestRemoteRun < MiniTest::Unit::TestCase
  
  def setup
    @user         = "test_user"
    @hosts        = %w{ www.example.com }
    @gateway      = "www.examplegateway.com"
    @gateway_user = "test_user"
    
    @config = Dir.pwd + "/tests/test_config.yml"
    @remote_run = Elsewhere::RemoteRun.initialize_from_config(@config, 'test', 'test_group')
    @remote_run_with_gateway = Elsewhere::RemoteRun.initialize_from_config(@config, 'test', 'test_group_with_gateway')
    
  end
  
  def test_hosts_are_set_from_initialized_config
    assert_equal @hosts , @remote_run.hosts
  end
  
  def test_user_is_set_from_initialized_config
    assert_equal @user, @remote_run.user
  end
  
  def test_gateway_is_set_from_initialized_config
    assert_equal @gateway, @remote_run_with_gateway.gateway_address
  end
  
  def test_gateway_user_is_set_from_initialized_config
    assert_equal @gateway_user, @remote_run_with_gateway.gateway_user 
  end
  
end