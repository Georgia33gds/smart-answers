require_relative "../../test_helper"

class AdditionalCommodityCodeIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    stub_content_store_has_item("/additional-commodity-code")
  end

  test "how_much_starch_glucose? question" do
    get "/additional-commodity-code/y"
    assert_select "[data-question-node='how_much_starch_glucose?']"
    assert_select "h1", "How much starch or glucose does the product contain?"
  end

  test "how_much_sucrose_1? question" do
    get "/additional-commodity-code/y/5"
    assert_select "[data-question-node='how_much_sucrose_1?']"
    assert_select "h1", "How much sucrose, invert sugar or isoglucose does the product contain?"
  end

  test "how_much_sucrose_2? question" do
    get "/additional-commodity-code/y/25"
    assert_select "[data-question-node='how_much_sucrose_2?']"
    assert_select "h1", "How much sucrose, invert sugar or isoglucose does the product contain?"
  end

  test "how_much_sucrose_3? question" do
    get "/additional-commodity-code/y/50"
    assert_select "[data-question-node='how_much_sucrose_3?']"
    assert_select "h1", "How much sucrose, invert sugar or isoglucose does the product contain?"
  end

  test "how_much_sucrose_4? question" do
    get "/additional-commodity-code/y/75"
    assert_select "[data-question-node='how_much_sucrose_4?']"
    assert_select "h1", "How much sucrose, invert sugar or isoglucose does the product contain?"
  end

  test "how_much_milk_fat? question" do
    get "/additional-commodity-code/y/0/0"
    assert_select "[data-question-node='how_much_milk_fat?']"
    assert_select "h1", "How much milk fat does the product contain?"
  end

  test "how_much_milk_protein_ab? question" do
    get "/additional-commodity-code/y/0/0/0"
    assert_select "[data-question-node='how_much_milk_protein_ab?']"
    # assert_select "h1", "How much milk fat does the product contain?"
  end

  test "how_much_milk_protein_c? question" do
    get "/additional-commodity-code/y/0/0/3"
    assert_select "[data-question-node='how_much_milk_protein_c?']"
    # assert_select "h1", "How much milk fat does the product contain?"
  end

  test "how_much_milk_protein_d? question" do
    get "/additional-commodity-code/y/0/0/6"
    assert_select "[data-question-node='how_much_milk_protein_d?']"
    # assert_select "h1", "How much milk fat does the product contain?"
  end

  test "how_much_milk_protein_ef? question" do
    get "/additional-commodity-code/y/0/0/9"
    assert_select "[data-question-node='how_much_milk_protein_ef?']"
    # assert_select "h1", "How much milk fat does the product contain?"
  end

  test "how_much_milk_protein_gh? question" do
    get "/additional-commodity-code/y/0/0/18"
    assert_select "[data-question-node='how_much_milk_protein_gh?']"
    # assert_select "h1", "How much milk fat does the product contain?"
  end

  test "commodity_code_result outcome" do
    get "/additional-commodity-code/y/0/0/0/0"
    assert_select "[data-outcome-node='commodity_code_result']"
    # assert_select "h1", "How much milk fat does the product contain?"
  end
end
