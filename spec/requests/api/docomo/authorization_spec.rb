RSpec.describe 'Docomo API behavior' do
  before do
    Sbpayment.configure do |x|
      x.sandbox = true
      x.merchant_id = '30132'
      x.service_id  = '103'
      x.basic_auth_user     = '30132103'
      x.basic_auth_password = 'ed679e1c9f90c2ab96b25d5c580b58e25192eb5d'
      x.hashkey             = 'ed679e1c9f90c2ab96b25d5c580b58e25192eb5d'
      x.cipher_code         = 'ed679e1c9f90c2ab96b25d5c'
      x.cipher_iv           = '580b58e2'
    end
  end

  describe 'AuthorizationRequest' do
    around do |e|
      VCR.use_cassette 'docomo-authorization' do
        e.run
      end
    end

    let(:req) do
      req = Sbpayment::API::Docomo::AuthorizationRequest.new
      req.cust_code        = SecureRandom.hex
      req.order_id         = SecureRandom.hex
      req.item_id          = 'item_2'
      req.item_name        = '継続課金購入'
      req.amount           = 980
      req
    end

    describe '#attributes' do
      it 'keys' do
        expected_json_user_keys = %w(
          merchant_id
          service_id
          tracking_id
          cust_code
          order_id
          item_id
          item_name
          tax
          amount
          free1
          free2
          free3
          order_rowno
          request_date
          limit_second
          sps_hashcode
        )
        expect(req.attributes.keys).to eq expected_json_user_keys
      end
    end

    describe '#update_sps_hashcode' do
      it do
        expect(req.sps_hashcode).to eq ''
        hash_code = req.update_sps_hashcode
        expect(req.sps_hashcode).to eq hash_code
      end
    end

    describe '#perform' do
      xcontext 'success' do
        # couldn't implement because tracking_id is nil
      end

      context 'failed' do
        it do
          req.update_sps_hashcode
          res = req.perform
          expect(res.error.class).to eq Sbpayment::API40103Error
        end
      end
    end
  end
end
