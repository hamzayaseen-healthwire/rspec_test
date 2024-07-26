require 'rspec'
require 'httparty'
require 'pry'
require 'tty-prompt'
require 'benchmark'


RSpec.describe 'Pharmacy V6' do
  before(:all) do
    @base_url = ''
    @headers = {
      'x-authorization-secret-key' =>  '',
      'x-authorization-public-key' =>  ''
    }
  end

  it 'Login' do
    response = HTTParty.post(
      "#{@base_url}/sessions/login.json?resend=false&user[phone]=3324769260",
      headers: @headers
    )
    expect(response.code).to eq(200)
  end

  it 'verify otp' do
    prompt = TTY::Prompt.new
    verify = prompt.ask('Please enter OTP: ')
    verify_otp = verify.to_i
    sleep(10)
    response_otp = HTTParty.post(
      "#{@base_url}/sessions?user[phone]=3324769260&user[phone_pin]=#{verify_otp}",
      headers: @headers
    )
    expect(response_otp.code).to eq(200)
    @headers['x-user-token'] = response_otp['data']['auth_token']
    @headers['x-user-email'] = response_otp['data']['email']
  end

  it 'Response of all pharmacy APIs' do
    api_endpoints = [
      '/best-selling-medicines.json',
      '/items',
      '/featured-medicines',
      '/epharmacy-categories.json',
      '/epharmacy-categories-details',
      '/up-selling-items',
      '/a-to-z-items?q=P'
    ]

    api_endpoints.each do |endpoint|
      # start_time = Time.now
      response_all = Benchmark.measure {HTTParty.get("#{@base_url}#{endpoint}", headers: @headers)} 
      response_time = Benchmark.measure { response_all }
      puts response_time
      end_time = Time.now
      elapsed_time = end_time - start_time
      puts "time: #{elapsed_time} for api #{endpoint}"
      expect(response_all.code).to eq(200)
      expect { JSON.parse(response_all.body) }.not_to raise_error
    end
  end
end
