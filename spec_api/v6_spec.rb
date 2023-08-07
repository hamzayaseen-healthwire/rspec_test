require 'rspec'
require 'httparty'
require 'pry'
require 'tty-prompt'

RSpec.describe 'Pharmacy V6' do
  before(:all) do
    @base_url = 'https://healthwire.pk/api/v6'
    @headers = {
      'x-authorization-secret-key' =>  'eyJhbGciOiJSUzI1NiJ9.eyJzdWNjZXNzIjp0cnVlfQ.NDpM9sShHWScsD7zEiBVmMcEdRmk6y-kODDMOavvpgJfve2Tw9A_c9WI5VMmAwXK268bhAqP8Zf7xNwrFM2riyxSEAHXITh60bhXZbPGnTeHvd89b-4wbSip1qBCYOf5DShb2Jlcmv6B2gX61ny13k7Y0bSl9QmBacIzjz1ViJBvLf2b9SIzkhqhJgwrZrBf3K4QbqmjmZk22N02V4TWNUTfAEXUdeHP-bURJaPWFAHq_lGQV7x04aGojX-32nvIpat7emFK9KzMgqlGW4hiVGj8V30WyJrcKOsicIKaf0YRl1e1gSqrNMejz9TGXY29hM7hQJ0V6PkRJ0RV0l7V7enk6wXtuBbuCDbb8qvqNvIIGM-Qri1EDaQNEdi1ih0F8kpMgaE-R9cQ9Zqunt0M2HuTOG7qLNYQfwZoPNlmhPLiNqUlap8nmbqIL6gPhK7Ei3V16wF6IHLfar5kHaDhQJAsQiGez6D2ibxNkGi-oataMyYRK_SYMsZV1F2jVYCfGmpAzr509zGvDdKQNDsB_JInwTVvpg_1or6rBV2d2dWEPrPz19tuL3yoUG-wrq4h-KTOeRhuqdpzOA_5INZwpeXDxFlZIn-xjm4aX2ANk5zuEBTeX-T7YZDvb7WGj-r7LtmXPiRl5u9lTcIX8DCq2ovyPYCM47NmhqXU3XQgJ6Y',
      'x-authorization-public-key' =>  '-----BEGIN PUBLIC KEY-----\nMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAzT5kt2ZPMUu8wMIufapo\nt2DQNnhSgVh8Y16DuAW8VsHj292pSgIpkDhirWcrWc3DbRkYJyUyCUiY9i4tMH0K\nPbx461s8yNK/ZJJ3JH2gM4YZZtnBGZdV5ce+jvx2LFWBkIGIQto34CYAwI5pvgHs\nxuizy7rxZIEMDgFR7LOqA/Lj/K1vCLexc5rDPG5ulohR4pCI69UQ2zxA42dNmTq0\nkthwathZY1DqFGh0chPm61jidpbgdie0r0WXdQlj2+yDQC25Bs8PfGJuZboc/UqK\nws4QzkPVhWHEZ4wrNdy6k5M4J1heGbkPLodVK7OEdaCWzFPRO5C1vkupF2DV25vm\nhdmquid02ZIb7Z9zT63c9k4KuyScNtP1ajcNNmN3D2o2NKgbEhYhsp/RQE6Whj1P\nMzrQSdWeY0/JasnqppmljGLC3oKFheWnBH+SCg3T2+v93SWHfmltV/X5xKzUCWMa\ngoVK6G5fCd3lBDaHy++NfNSb+txNSjMXOdvzjYvbF8oWc3annnhwwVpYW+wdTiTp\neS55wscspmLTPHXXvoVf10l4e4BptPb70wr6IJQA5EIEmYJ/9JTvxXfFfiRJG/+/\nAII3pjzW0j8xQud0oBCWR7T0YrDV5DgFNBuXQiZVGhKgOwBLVfG9ZG6kjAGGhpIB\nk962C0KC+Euc/hL4IYKUFx0CAwEAAQ==\n-----END PUBLIC KEY-----\n'
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
      start_time = Time.now
      response_all = HTTParty.get("#{@base_url}#{endpoint}", headers: @headers)
      end_time = Time.now
      elapsed_time = end_time - start_time
      puts "time: #{elapsed_time} for api #{endpoint}"
      expect(response_all.code).to eq(200)
      expect { JSON.parse(response_all.body) }.not_to raise_error
    end
  end
end
