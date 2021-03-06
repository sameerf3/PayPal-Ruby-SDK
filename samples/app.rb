# Configure Bundler
require 'bundler/setup'
Bundler.require :default, :sample

# Run Samples on different scope
module RunSample
  def self.logger
    PayPal::SDK::Core::Config.logger
  end

  def self.run(file, variable)
    object_binding = binding
    object_binding.eval(File.read("./#{file}"))
    object_binding.eval(variable)
  end
end

class App < Sinatra::Application
  enable :sessions

  get '/' do
    haml :index
  end

  get "/payment/all" do
    @payment_history  = RunSample.run("payment/all.rb", "@payment_history")
    haml :display_hash, :locals => {
      :header => "Got #{@payment_history.count} matching payments",
      :display_hash => @payment_history }
  end

  get "/payment/find" do
    @payment = RunSample.run("payment/find.rb", "@payment")
    haml :display_hash, :locals => {
      :header => "Retrieving Payment: #{@payment.id}",
      :display_hash => @payment }
  end

  get "/payment/create_with_paypal" do
    @payment, @redirect_url = RunSample.run("payment/create_with_paypal.rb", "[ @payment, @redirect_url ]")
    session[:payment_id] = @payment.id
    redirect @redirect_url
  end

  get "/payment/execute" do
    ENV["PAYMENT_ID"] = session[:payment_id]
    ENV["PAYER_ID"]   = params["PayerID"]
    @payment = RunSample.run("payment/execute.rb", "@payment")
    haml :display_hash, :locals => {
      :header => "Execute Payment: #{@payment.id}",
      :display_hash => @payment }
  end

  [ 'create_with_credit_card', 'create_with_credit_card_token' ].each do |name|
    get "/payment/#{name}" do
      @payment = RunSample.run("payment/#{name}.rb", "@payment")
      haml :display_hash, :locals => {
        :header => "Create Payment: #{@payment.id}",
        :display_hash => @payment }
    end
  end

  get "/sale/find" do
    @sale = RunSample.run("sale/find.rb", "@sale")
    haml :display_hash, :locals => {
      :header => "Retrieving sale: #{@sale.id}",
      :display_hash => @sale }
  end

  get "/sale/refund" do
    @refund = RunSample.run("sale/refund.rb", "@refund")
    haml :display_hash, :locals => {
      :header => "Refunding sale: #{@refund.sale_id}",
      :display_hash => @refund }
  end

  get "/credit_card/find" do
    @credit_card = RunSample.run("credit_card/find.rb", "@credit_card")
    haml :display_hash, :locals => {
      :header => "Retrieving credit card: #{@credit_card.id}",
      :display_hash => @credit_card }
  end

  get "/credit_card/delete" do
      @credit_card = RunSample.run("credit_card/delete.rb", "@credit_card")
      haml :display_hash, :locals => {
        :header => "Deleted credit card: #{@credit_card.id}",
        :display_hash => @credit_card }
  end

  get "/payouts/create" do
    @payout_batch = RunSample.run("payouts/create.rb", "@payout_batch")
    haml :display_hash, :locals => {
                          :header => "Created a Batch Payout: #{@payout_batch.batch_header.payout_batch_id}",
                          :display_hash => @payout_batch }
  end

  get "/payouts/createSync" do
    @payout_batch = RunSample.run("payouts/createSync.rb", "@payout_batch")
    haml :display_hash, :locals => {
                          :header => "Created a Synchronous Payout: #{@payout_batch.batch_header.payout_batch_id}",
                          :display_hash => @payout_batch
                      }
  end

  get "/payouts/get_batch_status" do
    @payout_batch = RunSample.run("payouts/get_batch_status.rb", "@payout_batch")
    haml :display_hash, :locals => {
                          :header => "Got Batch Status of: #{@payout_batch.batch_header.payout_batch_id}",
                          :display_hash => @payout_batch
                      }
  end

  get "/payouts/get_item_status" do
    @payout_item_details = RunSample.run("payouts/get_item_status.rb", "@payout_item_details")
    haml :display_hash, :locals => {
                          :header => "Got Item Status of: #{@payout_item_details.payout_item_id}",
                          :display_hash => @payout_item_details
                      }
  end
  get "/payouts/cancel" do
    @payout_item_detail = RunSample.run("payouts/cancel.rb", "@payout_item_detail")
    haml :display_hash, :locals => {
    :header => "Cancel Unclaimed Payouts of #{@payout_item_detail.payout_item_id}",
        :display_hash => @payout_item_detail
    }
  end

  get "/credit_card/create" do
    @credit_card = RunSample.run("credit_card/create.rb", "@credit_card")
    haml :display_hash, :locals => {
      :header => "Saved a new credit card: #{@credit_card.id}",
      :display_hash => @credit_card }
  end

  get "/authorization/reauthorize" do
    @authorization = RunSample.run("authorization/reauthorize.rb", "@authorization")
    haml :display_hash, :locals => {
      :header => "Reauthorized an authorized payment: #{@authorization.id}",
      :display_hash => @authorization }
  end

  get "/authorization/find" do
    @authorization = RunSample.run("authorization/find.rb", "@authorization")
    haml :display_hash, :locals => {
      :header => "Retrieving an authorization payment: #{@authorization.id}",
      :display_hash => @authorization }
  end

  get "/authorization/void" do
    @authorization = RunSample.run("authorization/void.rb", "@authorization")
    haml :display_hash, :locals => {
      :header => "Void an authorized payment: #{@authorization.id}",
      :display_hash => @authorization }
  end

  get "/authorization/capture" do
    @capture = RunSample.run("authorization/capture.rb", "@capture")
    haml :display_hash, :locals => {
      :header => "Captured an authorized payment: #{@capture.id}",
      :display_hash => @capture }
  end

  get "/capture/find" do
    @capture = RunSample.run("capture/find.rb", "@capture")
    haml :display_hash, :locals => {
      :header => "Retrieving Captured Payment: #{@capture.id}",
      :display_hash => @capture }
  end

  get "/capture/refund" do
    @refund = RunSample.run("capture/refund.rb", "@refund")
    haml :display_hash, :locals => {
      :header => "Refunding Captured Payment: #{@refund.sale_id}",
      :display_hash => @refund }
  end

  Dir["payment/*", "sale/*", "credit_card/*", "authorization/*", "capture/*", "payouts/*"].each do |file_name|
    get "/#{file_name.sub(/rb$/, "html")}" do
      CodeRay.scan(File.read(file_name), "ruby").page :title => "Source: #{file_name}"
    end
  end

end
