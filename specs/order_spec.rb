require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use!
Minitest::Test.make_my_diffs_pretty!
require 'minitest/skip_dsl'

require_relative '../lib/order'


# Provides tests for initializing Order and the total and add_product methods.
describe "Order Wave 1" do

  # Creates a generic, normal instance of Order to run tests on
  before do
    @normal_products = { "banana" => 1.99, "cracker" => 3.00 }
    @normal_id = 121
    @normal_order = Grocery::Order.new(@normal_id, @normal_products)
  end

  # Forces a hard reset of @@all_orders to sterilize tests
  after do
    Grocery::Order.build_all
  end

  # Tests if a new Order is initialized with attributes of 'id' and 'products'
  describe "#initialize" do
    # The id and products of Order must match the values it was given
    it "Takes an ID and collection of products" do

      # Tests class on normal order
      @normal_order.must_be_kind_of Grocery::Order # assertion

      # Tests id on normal order
      @normal_order.must_respond_to :id # assertion
      @normal_order.id.must_equal @normal_id # assertion
      @normal_order.id.must_be_kind_of Integer # assertion

      # Tests products on normal order
      @normal_order.must_respond_to :products # assertion
      @normal_order.products.must_equal @normal_products # assertion
      @normal_order.products.size.must_equal @normal_products.size # assertion
    end

    it "adds self to all orders" do
      number_of_orders_before = Grocery::Order.all.size
      added_order = Grocery::Order.new(@normal_id + 1, {"banana" => 1.99})
      number_of_orders_after = Grocery::Order.all.size

      Grocery::Order.find(@normal_id + 1).must_equal added_order # assertion
      number_of_orders_after.must_equal number_of_orders_before + 1 # assertion
    end

    it "Requires positive and unique order ID numbers" do
      same_id = 829
      Grocery::Order.new(same_id, {"muffins" => 9.99})

      assert_raises{ Grocery::Order.new(same_id, {"banana" => 1.99}) } # assertion
      assert_raises{ Grocery::Order.new(-2, {"melon" => 4.99}) } # assertion
    end

    it "Does not include negative costs" do
      initial_products = {"melon" => 4.99, "grapes" => -3.23}
      expected_products = {"melon" => 4.99}
      order_with_negative = Grocery::Order.new(9999, initial_products)

      order_with_negative.must_be_kind_of Grocery::Order # assertion
      order_with_negative.products.must_equal expected_products # assertion
    end

  end

  # Tests if total returns the total cost of the order, including tax and
  # rounded to two decimal places.
  describe "#total" do
    it "Returns the total from the collection of products" do
      sum = @normal_order.products.values.inject(0, :+)
      expected_total = sum + (sum * 0.075).round(2)

      # Must be total + tax and rounded to two decimal places
      @normal_order.total.must_equal expected_total
    end

    # Tests if total returns 0.0 if there are no products
    it "Returns a total of zero if there are no products" do
      empty_order = Grocery::Order.new(2222222, {})

      empty_order.total.must_equal 0.0  # assertion
    end
  end

  describe "#add_product" do

    # Tests if add_product increases products size.
    it "Increases the number of products" do
      # Grocery::Order.build_all
      @normal_order.add_product("salad", 4.25)
      expected_count = @normal_products.size + 1

      @normal_order.products.count.must_equal expected_count # assertion
    end

    # Tests if program adds new product to products.
    it "Is added to the collection of products" do
      @normal_order.add_product("sandwich", 4.25)

      @normal_order.products.include?("sandwich").must_equal true # assertion
    end

    it "Returns false if the product is already present" do
      before_total = @normal_order.total
      result_of_add = @normal_order.add_product("banana", 4.25) # already has
      after_total = @normal_order.total

      result_of_add.must_equal false # assertion
      before_total.must_equal after_total # assertion
    end

    it "Returns true if the product is new" do
      result_of_add = @normal_order.add_product("salad", 4.25)

      result_of_add.must_equal true # assertion
    end
  end
end


describe "Order Wave 2" do

  expected_first_id = 1
  expected_first_products = {"Slivered Almonds"=>22.88,
    "Wholewheat flour"=>1.93, "Grape Seed Oil"=>74.9}

  expected_last_id = 100
  expected_last_products = {"Allspice"=>64.74, "Bran"=>14.72,
    "UnbleachedFlour"=>80.59}


  describe "Order.all" do

    it "Returns an array of all orders" do
      all_orders = Grocery::Order.all

      all_orders.must_be_kind_of Array # assertion
      assert all_orders.all? { |order| order.class == Grocery::Order} # assertion
    end

    it "Returns accurate information about the first order" do
      first_order = Grocery::Order.all[0]

      first_order.id.must_be_kind_of Integer # assertion
      first_order.id.must_equal expected_first_id # assertion

      first_order.products.must_be_kind_of Hash # assertion
      first_order.products.must_equal expected_first_products # assertion
    end

    it "Returns accurate information about the last order" do
      # Grocery::Order.build_all
      last_order = Grocery::Order.all.last

      last_order.id.must_be_kind_of Integer # assertion
      last_order.id.must_equal expected_last_id # assertion

      last_order.products.must_be_kind_of Hash # assertion
      last_order.products.must_equal expected_last_products # assertion
    end
  end

  describe "Order.find" do
    it "Can find the first order from the CSV" do
      first_order = Grocery::Order.find(1)

      first_order.must_be_kind_of Grocery::Order # assertion

      first_order.must_respond_to :id # assertion
      first_order.id.must_be_kind_of Integer # assertion
      first_order.id.must_equal expected_first_id # assertion

      first_order.must_respond_to :products # assertion
      first_order.products.must_be_kind_of Hash # assertion
      first_order.products.must_equal expected_first_products # assertion

    end

    it "Can find the last order from the CSV" do
      last_order = Grocery::Order.find(expected_last_id)

      last_order.must_be_kind_of Grocery::Order # assertion

      last_order.must_respond_to :id # assertion
      last_order.id.must_be_kind_of Integer # assertion
      last_order.id.must_equal expected_last_id # assertion

      last_order.must_respond_to :products # assertion
      last_order.products.must_be_kind_of Hash # assertion
      last_order.products.must_equal expected_last_products # assertion
    end

    it "Return nil for an order that doesn't exist" do
      # Returns nil for Strings
      assert_nil Grocery::Order.find("21") # assertion

      # Returns nil for order id's that do not exist
      assert_nil Grocery::Order.find(121) # assertion
    end

  end
end
