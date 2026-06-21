require "test_helper"

class ProducersControllerTest < ActionDispatch::IntegrationTest
  test "lists producers with dynamic table UI" do
    producer = Producer.create!(name: "Château Exemple", email: "info@example.com", website: "https://example.com")
    wine = Wine.create!(name: "Estate Red", producer: producer)
    vintage = Vintage.create!(vintage: "2024", wine: wine)
    Bottle.create!(vintage: vintage, disposal_method: "Drink")

    get producers_url

    assert_response :success
    assert_select "h1", "Producers"
    assert_select "[data-controller='table']"
    assert_select "a[href=?]", producer_path(producer), "Château Exemple"
    assert_select "th", "Bottles on hand"
    assert_select "td", "1"
    assert_select "td.actions", false
  end

  test "show displays a minimal wine table" do
    producer = Producer.create!(name: "Producer")
    wine = Wine.create!(name: "Estate Red", producer: producer, style: "Still", color: "Red", appellation: "Old Mission Peninsula")

    get producer_url(producer)

    assert_response :success
    assert_select "h2", "Wines"
    assert_select "a[href=?]", wine_path(wine), "Estate Red"
    assert_select "a[href=?]", new_wine_path(wine: { producer_id: producer.id }), "New Wine"
  end

  test "new labels name as producer name" do
    get new_producer_url

    assert_response :success
    assert_select "label[for='producer_name']", "Producer Name"
    assert_select "section.producer-wines-form h2", "Wines"
    assert_select "fieldset.producer-wine-fields", count: 2
    assert_select "input[name='producer[wines_attributes][0][name]']"
    assert_select "textarea[name='producer[wines_attributes][0][description]']"
    assert_select "select[name='producer[wines_attributes][0][style]']"
    assert_select "select[name='producer[wines_attributes][0][color]']"
    assert_select "input[name='producer[wines_attributes][0][appellation]']"
    assert_select "input[name='producer[wines_attributes][0][vintage]']"
    assert_select "select[name='producer[wines_attributes][0][producer_id]']", count: 0
    assert_select "button", "Add another wine"
    assert_includes response.body, "NEW_RECORD"
  end

  test "edit shows read only existing wines and wine creation section" do
    producer = Producer.create!(name: "Producer")
    wine = Wine.create!(name: "Estate Red", producer: producer)

    get edit_producer_url(producer)

    assert_response :success
    assert_select "section.producer-wines-form h2", "Wines"
    assert_select ".existing-wines li", "Estate Red"
    assert_select "input[value=?]", wine.name, count: 0
    assert_select "input[name='producer[wines_attributes][0][name]']"
    assert_select "select[name='producer[wines_attributes][0][producer_id]']", count: 0
  end

  test "creates updates and deletes producer" do
    assert_difference("Producer.count", 1) do
      post producers_url, params: { producer: { name: "New Producer", email: "info@example.com", website: "https://example.com" } }
    end

    producer = Producer.order(:created_at).last
    assert_redirected_to producer_url(producer)

    patch producer_url(producer), params: { producer: { name: "Updated Producer" } }
    assert_redirected_to producer_url(producer)
    assert_equal "Updated Producer", producer.reload.name

    assert_difference("Producer.count", -1) do
      delete producer_url(producer)
    end
    assert_redirected_to producers_url
  end

  test "blank wine subforms do not create wines" do
    assert_difference("Producer.count", 1) do
      assert_no_difference("Wine.count") do
        post producers_url, params: { producer: { name: "New Producer", wines_attributes: { "0" => { name: "", description: "", style: "", color: "", appellation: "", vintage: "" } } } }
      end
    end

    producer = Producer.order(:created_at).last
    assert_redirected_to producer_url(producer)
    assert_equal "Producer was successfully created. 0 wines were created.", flash[:notice]
  end

  test "creates producer with one wine and vintage" do
    assert_difference("Producer.count", 1) do
      assert_difference("Wine.count", 1) do
        assert_difference("Vintage.count", 1) do
          post producers_url, params: { producer: { name: "New Producer", wines_attributes: { "0" => { name: "Estate Red", description: "Flagship", style: "Still", color: "Red", appellation: "Old Mission Peninsula", vintage: "2024" } } } }
        end
      end
    end

    producer = Producer.order(:created_at).last
    wine = producer.wines.first
    assert_redirected_to producer_url(producer)
    assert_equal "Producer was successfully created. 1 wine was created.", flash[:notice]
    assert_equal "Estate Red", wine.name
    assert_equal "Flagship", wine.description
    assert_equal "Still", wine.style
    assert_equal "Red", wine.color
    assert_equal "Old Mission Peninsula", wine.appellation
    assert_equal "2024", wine.vintages.first.vintage
  end

  test "creates producer with multiple wines and only creates vintages when present" do
    assert_difference("Producer.count", 1) do
      assert_difference("Wine.count", 2) do
        assert_difference("Vintage.count", 1) do
          post producers_url, params: {
            producer: {
              name: "New Producer",
              wines_attributes: {
                "0" => { name: "Estate Red", style: "Still", color: "Red", vintage: "2024" },
                "1" => { name: "Estate White", style: "Still", color: "White", vintage: "" }
              }
            }
          }
        end
      end
    end

    producer = Producer.order(:created_at).last
    assert_redirected_to producer_url(producer)
    assert_equal "Producer was successfully created. 2 wines were created.", flash[:notice]
    assert_equal [ "Estate Red", "Estate White" ], producer.wines.order(:name).pluck(:name)
    assert_equal [ "2024" ], Vintage.joins(:wine).where(wines: { producer_id: producer.id }).pluck(:vintage)
  end

  test "updates producer and creates submitted wines" do
    producer = Producer.create!(name: "Producer")

    assert_no_difference("Producer.count") do
      assert_difference("Wine.count", 1) do
        assert_difference("Vintage.count", 1) do
          patch producer_url(producer), params: { producer: { name: "Updated Producer", wines_attributes: { "0" => { name: "Estate Red", style: "Still", color: "Red", vintage: "2024" } } } }
        end
      end
    end

    assert_redirected_to producer_url(producer)
    assert_equal "Updated Producer", producer.reload.name
    assert_equal "Producer was successfully updated. 1 wine was created.", flash[:notice]
    assert_equal "Estate Red", producer.wines.first.name
    assert_equal "2024", producer.wines.first.vintages.first.vintage
  end

  test "validation failures do not persist partial producer wine vintage set" do
    assert_no_difference("Producer.count") do
      assert_no_difference("Wine.count") do
        assert_no_difference("Vintage.count") do
          post producers_url, params: {
            producer: {
              name: "New Producer",
              wines_attributes: {
                "0" => { name: "Estate Red", style: "Still", color: "Red", vintage: "2024" },
                "1" => { name: "", style: "Still", color: "White", vintage: "2025" }
              }
            }
          }
        end
      end
    end

    assert_response :unprocessable_entity
    assert_select ".error-messages li", "Name can't be blank"
    assert_select "input[name='producer[wines_attributes][0][name]'][value='Estate Red']"
    assert_select "input[name='producer[wines_attributes][1][vintage]'][value='2025']"
  end

  test "community curated status is preserved for nested wine and vintage creation" do
    basic_user = users(:basic)
    sign_out admin_user
    sign_in basic_user
    Current.user = basic_user

    assert_difference("Producer.pending.count", 1) do
      assert_difference("Wine.pending.count", 1) do
        assert_difference("Vintage.pending.count", 1) do
          post producers_url, params: { producer: { name: "Pending Producer", wines_attributes: { "0" => { name: "Pending Wine", vintage: "2024" } } } }
        end
      end
    end

    producer = Producer.order(:created_at).last
    assert_redirected_to producer_url(producer)
    assert_equal basic_user, producer.created_by_user
    assert_equal "Pending", producer.approval_status
    assert_equal "Pending", producer.wines.first.approval_status
    assert_equal "Pending", producer.wines.first.vintages.first.approval_status
  end
end
